extends CharacterBody2D
## Gojo, le personnage joueur.
##
## Jalon 0 : déplacement en huit directions, roulade et caméra.
## Toutes les valeurs @export se règlent dans l'inspecteur, sans toucher au code.
## Ce sont des points de départ : elles seront toutes fausses au premier test.

enum Etat { MARCHE, ROULADE }

## Le milieu du corps : Gojo fait 24 × 24 pixels, et son origine est à ses pieds.
const CENTRE := Vector2(0, -12)
## Marge pour les arrondis : 15 × (1/60) donne 0,24999… et non 0,25.
const MARGE_ARRONDI := 0.001

@export_group("Marche")
## Vitesse de marche, en pixels par seconde.
@export var vitesse_marche := 80.0
## Temps pour passer de l'arrêt à la pleine vitesse, en secondes.
@export var duree_acceleration := 0.08
## Temps pour passer de la pleine vitesse à l'arrêt, en secondes.
@export var duree_freinage := 0.06

@export_group("Roulade")
## Vitesse pendant la roulade, en pixels par seconde.
@export var vitesse_roulade := 220.0
## Durée de la roulade, en secondes.
@export var duree_roulade := 0.25
## Durée de l'invincibilité, comptée depuis le début de la roulade, en secondes.
@export var duree_invincibilite := 0.2
## Temps d'attente entre la fin d'une roulade et la suivante, en secondes.
@export var recharge_roulade := 0.6

@export_group("Couleurs provisoires")
## Couleur du rectangle quand Gojo marche.
@export var couleur_marche := Color("e8d5b0")
## Couleur du rectangle pendant la roulade.
@export var couleur_roulade := Color("fff8e8")

var etat := Etat.MARCHE
## Vrai au début de la roulade : les coups ne feront rien (servira au jalon 1).
var est_invincible := false
## La dernière direction dans laquelle Gojo a bougé.
## La roulade part par là si le joueur ne tient aucune direction.
var direction_regard := Vector2.DOWN

var _direction_roulade := Vector2.ZERO
var _temps_roulade := 0.0
var _temps_recharge := 0.0

@onready var _corps: ColorRect = $Corps
@onready var _repere_regard: ColorRect = $RepereRegard


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("gauche", "droite", "haut", "bas")

	if etat == Etat.ROULADE and _temps_roulade_ecoule(duree_roulade):
		_finir_roulade()

	if etat == Etat.MARCHE:
		_temps_recharge = maxf(_temps_recharge - delta, 0.0)
		if Input.is_action_just_pressed("roulade") and _temps_recharge <= MARGE_ARRONDI:
			_commencer_roulade(direction)

	if etat == Etat.ROULADE:
		est_invincible = not _temps_roulade_ecoule(duree_invincibilite)
		velocity = _direction_roulade * vitesse_roulade
		_temps_roulade += delta
	else:
		_marcher(direction, delta)

	move_and_slide()
	_mettre_a_jour_apparence()


func _marcher(direction: Vector2, delta: float) -> void:
	var duree := duree_acceleration if direction != Vector2.ZERO else duree_freinage
	var acceleration := vitesse_marche / maxf(duree, 0.001)
	velocity = velocity.move_toward(direction * vitesse_marche, acceleration * delta)
	if direction != Vector2.ZERO:
		direction_regard = direction.normalized()


func _commencer_roulade(direction: Vector2) -> void:
	etat = Etat.ROULADE
	_temps_roulade = 0.0
	if direction != Vector2.ZERO:
		direction_regard = direction.normalized()
	_direction_roulade = direction_regard


func _temps_roulade_ecoule(duree: float) -> bool:
	return _temps_roulade >= duree - MARGE_ARRONDI


func _finir_roulade() -> void:
	etat = Etat.MARCHE
	est_invincible = false
	_temps_recharge = recharge_roulade


func _mettre_a_jour_apparence() -> void:
	_corps.color = couleur_roulade if etat == Etat.ROULADE else couleur_marche
	_corps.modulate.a = 0.5 if est_invincible else 1.0
	_repere_regard.position = CENTRE + direction_regard * 8.0 - _repere_regard.size / 2.0

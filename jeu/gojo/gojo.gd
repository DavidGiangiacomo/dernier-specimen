class_name Gojo
extends CharacterBody2D
## Gojo, le personnage joueur.
##
## Jalon 0 : déplacement en huit directions, roulade et caméra.
## Jalon 1 : coup de bâton, PV, recul et invincibilité après un coup.
## Jalon 2 : le gant, qui analyse au contact en tenant le bouton.
## Toutes les valeurs @export se règlent dans l'inspecteur, sans toucher au code.
## Ce sont des points de départ : elles seront toutes fausses au premier test.

## Émis à chaque fois que les PV changent (pour les cœurs à l'écran).
signal pv_changes(pv: int, pv_max: int)
## Émis quand Gojo tombe à 0 PV. C'est le niveau qui décide de la suite.
signal ko

enum Etat { MARCHE, ROULADE, ATTAQUE, ANALYSE, KO }

## Le milieu du corps : Gojo fait 24 × 24 pixels, et son origine est à ses pieds.
const CENTRE := Vector2(0, -12)
## Marge pour les arrondis : 15 × (1/60) donne 0,24999… et non 0,25.
const MARGE_ARRONDI := 0.001
## Durée du flash blanc quand Gojo est touché, en secondes.
const DUREE_ECLAT := 0.1

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

@export_group("Bâton")
## Temps minimum entre le début de deux coups, en secondes.
@export var cadence_attaque := 0.35
## Durée pendant laquelle le coup fait mal et Gojo reste sur place, en secondes.
@export var duree_coup := 0.12

@export_group("Gant")
## Temps de contact pour réussir une analyse, en secondes.
@export var duree_analyse := 1.0
## Vitesse de marche pendant l'analyse, pour suivre une créature qui bouge, en pixels par seconde.
@export var vitesse_pendant_analyse := 40.0

@export_group("Vie")
## PV de départ. Un cœur vaut 2 PV.
@export var pv_max := 6

@export_group("Couleurs provisoires")
## Couleur du rectangle quand Gojo marche.
@export var couleur_marche := Color("e8d5b0")
## Couleur du rectangle pendant la roulade.
@export var couleur_roulade := Color("fff8e8")
## Couleur du rectangle quand Gojo est K.O.
@export var couleur_ko := Color("6b5f52")

var etat := Etat.MARCHE
var pv := 0
## Vrai au début de la roulade : les coups ne passent pas.
var invincible_en_roulade := false
## La dernière direction dans laquelle Gojo a bougé.
## La roulade et le coup de bâton partent par là.
var direction_regard := Vector2.DOWN

var _direction_roulade := Vector2.ZERO
var _temps_roulade := 0.0
var _temps_recharge := 0.0
var _temps_coup := 0.0
var _temps_avant_coup := 0.0
var _temps_eclat := 0.0
var _progression_analyse := 0.0
var _espece_analysee: Espece
## Après une analyse réussie, il faut relâcher le bouton avant d'en commencer une autre.
var _attendre_relache := false
var _temps_eclat_gant := 0.0

@onready var _corps: ColorRect = $Corps
@onready var _repere_regard: ColorRect = $RepereRegard
@onready var _baton: Node2D = $Baton
@onready var _hitbox_baton: Hitbox = $Baton/Hitbox
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _gant: Node2D = $Gant
@onready var _zone_contact: Area2D = $Gant/ZoneContact
@onready var _main: ColorRect = $Gant/Main
@onready var _barre_analyse: Node2D = $BarreAnalyse


func _ready() -> void:
	pv = pv_max
	_hurtbox.touchee.connect(_on_touchee)
	_ranger_baton()


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("gauche", "droite", "haut", "bas")
	_temps_avant_coup = maxf(_temps_avant_coup - delta, 0.0)
	_temps_eclat = maxf(_temps_eclat - delta, 0.0)
	_temps_eclat_gant = maxf(_temps_eclat_gant - delta, 0.0)
	if not Input.is_action_pressed("analyse"):
		_attendre_relache = false

	if etat == Etat.ROULADE and _temps_ecoule(_temps_roulade, duree_roulade):
		_finir_roulade()
	elif etat == Etat.ATTAQUE and _temps_ecoule(_temps_coup, duree_coup):
		_finir_coup()

	if etat == Etat.MARCHE:
		_temps_recharge = maxf(_temps_recharge - delta, 0.0)
		if Input.is_action_just_pressed("roulade") and _temps_recharge <= MARGE_ARRONDI:
			_commencer_roulade(direction)
		elif Input.is_action_just_pressed("attaque") and _temps_avant_coup <= MARGE_ARRONDI:
			_commencer_coup()
		elif Input.is_action_pressed("analyse") and not _attendre_relache and _cible_au_contact():
			_commencer_analyse(_cible_au_contact().espece)

	match etat:
		Etat.MARCHE:
			_marcher(direction, delta)
		Etat.ROULADE:
			invincible_en_roulade = not _temps_ecoule(_temps_roulade, duree_invincibilite)
			velocity = _direction_roulade * vitesse_roulade
			_temps_roulade += delta
		Etat.ATTAQUE:
			_marcher(Vector2.ZERO, delta)
			_temps_coup += delta
		Etat.ANALYSE:
			_analyser(direction, delta)
		Etat.KO:
			_marcher(Vector2.ZERO, delta)

	_hurtbox.invincible = invincible_en_roulade or etat == Etat.KO
	move_and_slide()
	_mettre_a_jour_apparence()


func _marcher(direction: Vector2, delta: float, vitesse := vitesse_marche) -> void:
	var duree := duree_acceleration if direction != Vector2.ZERO else duree_freinage
	var acceleration := vitesse_marche / maxf(duree, 0.001)
	velocity = velocity.move_toward(direction * vitesse, acceleration * delta)
	if direction != Vector2.ZERO:
		direction_regard = direction.normalized()


func _commencer_roulade(direction: Vector2) -> void:
	etat = Etat.ROULADE
	_temps_roulade = 0.0
	if direction != Vector2.ZERO:
		direction_regard = direction.normalized()
	_direction_roulade = direction_regard


func _finir_roulade() -> void:
	etat = Etat.MARCHE
	invincible_en_roulade = false
	_temps_recharge = recharge_roulade


func _commencer_coup() -> void:
	etat = Etat.ATTAQUE
	_temps_coup = 0.0
	_temps_avant_coup = cadence_attaque
	_baton.visible = true
	_hitbox_baton.active = true


func _finir_coup() -> void:
	etat = Etat.MARCHE
	_ranger_baton()


func _ranger_baton() -> void:
	_baton.visible = false
	_hitbox_baton.active = false


## La première zone analysable touchée par le gant dont la page n'est pas encore complète.
func _cible_au_contact() -> Analysable:
	for zone in _zone_contact.get_overlapping_areas():
		var cible := zone as Analysable
		if cible and cible.espece and not Carnet.est_complete(cible.espece):
			return cible
	return null


func _commencer_analyse(espece: Espece) -> void:
	etat = Etat.ANALYSE
	_espece_analysee = espece
	_progression_analyse = 0.0


## Tant que le bouton est tenu, la barre se remplit au contact et redescend sans contact.
## Bouton relâché : l'analyse est annulée.
func _analyser(direction: Vector2, delta: float) -> void:
	if not Input.is_action_pressed("analyse"):
		_arreter_analyse()
		_marcher(direction, delta)
		return
	var cible := _cible_au_contact()
	var au_contact := cible != null and cible.espece == _espece_analysee
	_progression_analyse += (delta if au_contact else -delta) / maxf(duree_analyse, 0.001)
	_marcher(direction, delta, vitesse_pendant_analyse)
	if _progression_analyse >= 1.0 - MARGE_ARRONDI:
		Carnet.ajouter_analyse(_espece_analysee)
		_temps_eclat_gant = DUREE_ECLAT * 2.0
		_attendre_relache = true
		_arreter_analyse()
	elif _progression_analyse <= 0.0:
		_arreter_analyse()


func _arreter_analyse() -> void:
	etat = Etat.MARCHE
	_progression_analyse = 0.0
	_espece_analysee = null


func _on_touchee(hitbox: Hitbox) -> void:
	if etat == Etat.ANALYSE:
		# Un coup reçu vide la barre : l'analyse est perdue.
		_arreter_analyse()
	pv = maxi(pv - hitbox.degats, 0)
	pv_changes.emit(pv, pv_max)
	velocity = (global_position - hitbox.global_position).normalized() * hitbox.force_recul
	_temps_eclat = DUREE_ECLAT
	if pv == 0:
		etat = Etat.KO
		invincible_en_roulade = false
		_ranger_baton()
		ko.emit()


func _temps_ecoule(temps: float, duree: float) -> bool:
	return temps >= duree - MARGE_ARRONDI


func _mettre_a_jour_apparence() -> void:
	var couleur := couleur_marche
	if etat == Etat.ROULADE:
		couleur = couleur_roulade
	elif etat == Etat.KO:
		couleur = couleur_ko
	if _temps_eclat > MARGE_ARRONDI:
		couleur = Color.WHITE
	_corps.color = couleur

	var opacite := 1.0
	if invincible_en_roulade:
		opacite = 0.5
	elif _hurtbox.vient_d_etre_touchee() and etat != Etat.KO:
		# Gojo clignote tant qu'il est invincible après un coup.
		opacite = 0.25 if posmod(Engine.get_physics_frames(), 10) < 5 else 1.0
	_corps.modulate.a = opacite

	# Le bâton et le gant suivent le regard, pour agir du bon côté dès la première image.
	_baton.rotation = direction_regard.angle()
	_gant.rotation = direction_regard.angle()
	# La main s'allume quand elle touche quelque chose d'analysable, et brille pendant l'analyse.
	_main.visible = etat == Etat.ANALYSE or _temps_eclat_gant > MARGE_ARRONDI or (etat == Etat.MARCHE and _cible_au_contact() != null)
	_main.modulate.a = 1.0 if etat == Etat.ANALYSE or _temps_eclat_gant > MARGE_ARRONDI else 0.4
	_main.color = Color.WHITE if _temps_eclat_gant > MARGE_ARRONDI else Color("8fe3ff")
	_barre_analyse.progression = _progression_analyse
	_repere_regard.position = CENTRE + direction_regard * 8.0 - _repere_regard.size / 2.0

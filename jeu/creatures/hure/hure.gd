extends CharacterBody2D
## La hure des souches, version jalon 1 : un ennemi qui fonce.
##
## Elle erre, repère Gojo, se prépare, puis charge en ligne droite.
## Si elle heurte une souche ou un mur, elle reste étourdie un moment.
## Sa charge ne fait mal que pendant qu'elle fonce.

enum Etat { ERRANCE, PREPARATION, CHARGE, ETOURDIE, REPOS }

## Marge pour les arrondis sur les durées.
const MARGE_ARRONDI := 0.001
## Durée du flash blanc quand elle est touchée, en secondes.
const DUREE_ECLAT := 0.1
## Largeur de la barre de PV au-dessus d'elle, en pixels.
const LARGEUR_BARRE := 16.0

@export_group("Vie")
## PV de départ.
@export var pv_max := 8

@export_group("Errance")
## Vitesse quand elle se promène, en pixels par seconde.
@export var vitesse_errance := 20.0
## Durée de chaque petite marche ou pause pendant l'errance, en secondes.
@export var duree_pas_errance := 1.2
## Distance à laquelle elle repère Gojo, en pixels.
@export var distance_detection := 96.0

@export_group("Charge")
## Temps pendant lequel elle se prépare avant de foncer, en secondes.
@export var duree_preparation := 0.6
## Vitesse de la charge, en pixels par seconde.
@export var vitesse_charge := 200.0
## Durée maximale d'une charge, en secondes.
@export var duree_charge_max := 1.0
## Temps étourdie après avoir heurté une souche ou un mur, en secondes.
@export var duree_etourdissement := 1.5
## Temps de repos après une charge qui n'a rien heurté, en secondes.
@export var duree_repos := 0.8
## À quelle vitesse elle freine, en pixels par seconde, chaque seconde.
@export var freinage := 600.0

@export_group("Couleurs provisoires")
## Couleur du rectangle en temps normal.
@export var couleur_normale := Color("7a5232")
## Couleur pendant qu'elle se prépare à charger : c'est l'avertissement pour le joueur.
@export var couleur_preparation := Color("c0452f")
## Couleur quand elle est étourdie.
@export var couleur_etourdie := Color("a89a8a")

var etat := Etat.ERRANCE
var pv := 0

var _temps_etat := 0.0
var _direction := Vector2.ZERO
var _temps_eclat := 0.0
var _gojo: Node2D

@onready var _corps: ColorRect = $Corps
@onready var _barre_pv: ColorRect = $BarreFond/BarrePv
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _hitbox_charge: Hitbox = $HitboxCharge


func _ready() -> void:
	pv = pv_max
	_hurtbox.touchee.connect(_on_touchee)
	_gojo = get_tree().get_first_node_in_group("gojo")
	_changer_etat(Etat.ERRANCE)


func _physics_process(delta: float) -> void:
	_temps_etat += delta
	_temps_eclat = maxf(_temps_eclat - delta, 0.0)

	match etat:
		Etat.ERRANCE:
			if _voit_gojo():
				_changer_etat(Etat.PREPARATION)
			elif _temps_ecoule(duree_pas_errance):
				_changer_etat(Etat.ERRANCE)
		Etat.PREPARATION:
			if _gojo:
				_direction = global_position.direction_to(_gojo.global_position)
			if _temps_ecoule(duree_preparation):
				_changer_etat(Etat.CHARGE)
		Etat.CHARGE:
			if _temps_ecoule(duree_charge_max):
				_changer_etat(Etat.REPOS)
		Etat.ETOURDIE:
			if _temps_ecoule(duree_etourdissement):
				_changer_etat(Etat.ERRANCE)
		Etat.REPOS:
			if _temps_ecoule(duree_repos):
				_changer_etat(Etat.ERRANCE)

	if etat == Etat.CHARGE:
		velocity = _direction * vitesse_charge
	else:
		var vitesse_visee := _direction * vitesse_errance if etat == Etat.ERRANCE else Vector2.ZERO
		velocity = velocity.move_toward(vitesse_visee, freinage * delta)

	move_and_slide()
	if etat == Etat.CHARGE and get_slide_collision_count() > 0:
		velocity = Vector2.ZERO
		_changer_etat(Etat.ETOURDIE)

	_hitbox_charge.active = etat == Etat.CHARGE
	_mettre_a_jour_apparence()


func _changer_etat(nouvel_etat: Etat) -> void:
	etat = nouvel_etat
	_temps_etat = 0.0
	if etat == Etat.ERRANCE:
		# Une fois sur deux elle s'arrête, sinon elle part dans une direction au hasard.
		_direction = Vector2.ZERO if randf() < 0.5 else Vector2.RIGHT.rotated(randf() * TAU)


func _voit_gojo() -> bool:
	return _gojo != null and global_position.distance_to(_gojo.global_position) <= distance_detection


func _temps_ecoule(duree: float) -> bool:
	return _temps_etat >= duree - MARGE_ARRONDI


func _on_touchee(hitbox: Hitbox) -> void:
	pv = maxi(pv - hitbox.degats, 0)
	_temps_eclat = DUREE_ECLAT
	# Quand elle charge, rien ne la fait reculer.
	if etat != Etat.CHARGE:
		velocity = (global_position - hitbox.global_position).normalized() * hitbox.force_recul
	if pv == 0:
		queue_free()


func _mettre_a_jour_apparence() -> void:
	var couleur := couleur_normale
	_corps.position.x = -_corps.size.x / 2.0
	if etat == Etat.PREPARATION:
		couleur = couleur_preparation
		# Elle tremble avant de foncer.
		_corps.position.x += 1.0 if posmod(Engine.get_physics_frames(), 4) < 2 else -1.0
	elif etat == Etat.ETOURDIE:
		couleur = couleur_etourdie
	if _temps_eclat > MARGE_ARRONDI:
		couleur = Color.WHITE
	_corps.color = couleur
	_barre_pv.size.x = LARGEUR_BARRE * pv / pv_max

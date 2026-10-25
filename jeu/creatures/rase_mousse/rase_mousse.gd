extends CharacterBody2D
## Un rase-mousse : une petite bête du creux humide. Ils vivent en nuée et harcèlent
## sans jamais tenir en place : ils foncent mordre, puis s'enfuient.
##
## Le pollen de fleur-trompette les endort (E, la fleur choisie dans la sacoche) :
## endormis, ils ne bougent plus, et on peut les analyser. C'est aussi leur clé :
## une fois leur page complète, le pollen les apaise pour de bon.

enum Etat { ERRANCE, ATTAQUE, FUITE, ENDORMI, APAISE }

const MARGE_ARRONDI := 0.001
const DUREE_ECLAT := 0.1

@export_group("Vie")
## PV de départ.
@export var pv_max := 2

@export_group("Nuée")
## Distance à laquelle ils repèrent Gojo, en pixels.
@export var distance_detection := 72.0
## Distance maximale à laquelle ils s'éloignent de leur nid, en pixels.
@export var rayon_du_nid := 40.0
## Vitesse quand ils foncent mordre, en pixels par seconde.
@export var vitesse_attaque := 120.0
## Vitesse quand ils voltigent ou s'enfuient, en pixels par seconde.
@export var vitesse_vol := 60.0
## Temps passé à fuir après une morsure, en secondes.
@export var duree_fuite := 0.8
## Après une morsure, temps avant de pouvoir attaquer de nouveau, en secondes.
@export var pause_entre_attaques := 1.5

@export_group("Pollen")
## Durée du sommeil après le pollen, en secondes.
@export var duree_sommeil := 8.0
## Le pollen endort aussi les rase-mousses à cette distance, en pixels.
@export var portee_pollen := 48.0

@export_group("Couleurs provisoires")
@export var couleur_normale := Color("a7b88a")
@export var couleur_endormi := Color("6f7a66")
@export var couleur_apaise := Color("c5d4a3")

var etat := Etat.ERRANCE
var pv := 0

var _nid := Vector2.ZERO
var _direction := Vector2.ZERO
var _temps_etat := 0.0
var _temps_eclat := 0.0
var _temps_avant_attaque := 0.0
var _gojo: Gojo

@onready var _corps: ColorRect = $Corps
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _hitbox: Hitbox = $Hitbox
@onready var _interactif: Interactif = $Interactif
@onready var analysable: Analysable = $Analysable


func _ready() -> void:
	pv = pv_max
	_nid = global_position
	_gojo = get_tree().get_first_node_in_group("gojo")
	_hurtbox.touchee.connect(_on_touchee)
	# Une morsure qui porte : ils s'enfuient aussitôt.
	_hitbox.a_touche.connect(func(_h): _changer_etat(Etat.FUITE))
	_interactif.utilise.connect(_on_utilise)
	_changer_etat(Etat.ERRANCE)


func _physics_process(delta: float) -> void:
	_temps_etat += delta
	_temps_eclat = maxf(_temps_eclat - delta, 0.0)
	_temps_avant_attaque = maxf(_temps_avant_attaque - delta, 0.0)
	var vitesse_visee := Vector2.ZERO
	match etat:
		Etat.ERRANCE, Etat.APAISE:
			# Ils voltigent autour du nid, en changeant souvent de direction.
			if _temps_etat >= 0.4:
				_changer_etat(etat)
			vitesse_visee = _direction * vitesse_vol
			if etat == Etat.ERRANCE and _temps_avant_attaque <= 0.0 and _voit_gojo():
				_changer_etat(Etat.ATTAQUE)
		Etat.ATTAQUE:
			if _gojo:
				vitesse_visee = global_position.direction_to(_gojo.global_position + Vector2(0, -10)) * vitesse_attaque
			if _temps_etat >= 1.5:
				_changer_etat(Etat.FUITE)
		Etat.FUITE:
			if _gojo:
				vitesse_visee = _gojo.global_position.direction_to(global_position) * vitesse_vol
			if _temps_etat >= duree_fuite - MARGE_ARRONDI:
				_changer_etat(Etat.ERRANCE)
		Etat.ENDORMI:
			if _temps_etat >= duree_sommeil - MARGE_ARRONDI:
				_se_reveiller()
	velocity = velocity.move_toward(vitesse_visee, 900.0 * delta)
	move_and_slide()

	_hitbox.active = etat == Etat.ATTAQUE
	_hurtbox.invincible = etat == Etat.APAISE
	var a_la_fleur := _gojo != null and _gojo.sacoche.plante_choisie() != null and _gojo.sacoche.plante_choisie().effet == EspecePlante.Effet.ENDORT
	_interactif.actif = a_la_fleur and etat != Etat.ENDORMI and etat != Etat.APAISE
	_mettre_a_jour_apparence()


func _changer_etat(nouvel_etat: Etat) -> void:
	etat = nouvel_etat
	_temps_etat = 0.0
	if etat == Etat.FUITE:
		_temps_avant_attaque = duree_fuite + pause_entre_attaques
	if etat == Etat.ERRANCE or etat == Etat.APAISE:
		# Retour vers le nid s'ils s'en sont trop éloignés, sinon au hasard.
		var vers_le_nid := global_position.direction_to(_nid)
		var loin := global_position.distance_to(_nid) > rayon_du_nid
		_direction = vers_le_nid if loin else Vector2.RIGHT.rotated(randf() * TAU)


func _voit_gojo() -> bool:
	return _gojo != null and _gojo.etat != Gojo.Etat.KO and global_position.distance_to(_gojo.global_position) <= distance_detection


## Le pollen les endort ; si leur page est complète, ils se réveilleront apaisés.
func endormir() -> void:
	if etat == Etat.APAISE:
		return
	_changer_etat(Etat.ENDORMI)
	velocity = Vector2.ZERO


func _se_reveiller() -> void:
	if Carnet.est_complete(analysable.espece):
		_changer_etat(Etat.APAISE)
		Carnet.marquer_apaisee(analysable.espece)
	else:
		_changer_etat(Etat.ERRANCE)


## Gojo souffle le pollen de fleur-trompette : tous les rase-mousses proches s'endorment.
func _on_utilise(_gojo_qui_souffle: Gojo) -> void:
	for autre in get_tree().get_nodes_in_group("rase_mousses"):
		if autre.global_position.distance_to(global_position) <= portee_pollen:
			autre.endormir()


func _on_touchee(hitbox: Hitbox) -> void:
	pv = maxi(pv - hitbox.degats, 0)
	_temps_eclat = DUREE_ECLAT
	velocity = (global_position - hitbox.global_position).normalized() * hitbox.force_recul
	if pv == 0:
		queue_free()
	elif etat != Etat.ENDORMI:
		_changer_etat(Etat.FUITE)


func _mettre_a_jour_apparence() -> void:
	var couleur := couleur_normale
	if etat == Etat.ENDORMI:
		couleur = couleur_endormi
	elif etat == Etat.APAISE:
		couleur = couleur_apaise
	if _temps_eclat > MARGE_ARRONDI:
		couleur = Color.WHITE
	_corps.color = couleur

class_name Garin
extends CharacterBody2D
## Garin Corbe, chasseur de primes : le boss de la tranche. On le paie pour brûler le camp
## des gobelins ; il n'a rien contre eux en particulier.
##
## Phase 1, l'arbalète : il garde ses distances, vise (un trait rouge, qui se fige juste avant
## le tir), tire, et pose des pièges quand Gojo le serre de près. Il faut fermer la distance.
## Phase 2, à mi-vie : il jette l'arbalète et sort la lame. Plus rapide, plus lisible :
## il lève la lame, frappe, puis souffle un moment. Si des gobelins le frappent, il se retourne
## contre eux : c'est la diversion du renfort.
## À 0 PV, il tombe à genoux. Il ne meurt pas : c'est le déroulé de la zone qui décide de la fin,
## selon que sa page du carnet est complète ou non.
## Le pollen de fleur-trompette l'endort un court moment : de quoi l'analyser sans risque.

## Émis à chaque fois que les PV changent (pour la barre en haut de l'écran).
signal pv_changes(pv: int, pv_max: int)
## Arrivé au bout d'une marche (son entrée dans la lisière).
signal arrive
## À mi-vie : il jette l'arbalète et sort la lame.
signal deuxieme_phase
## À 0 PV : il tombe à genoux.
signal a_terre
## Gojo lui tend le carnet (il est à terre, et sa page est complète).
signal carnet_tendu
## Il a quitté la lisière.
signal parti

enum Etat { ATTENTE, MARCHE, VISEE, LAME_LEVEE, LAME_COUP, SOUFFLE, ENDORMI, A_TERRE, DEPART }

const SCENE_CARREAU := preload("res://creatures/garin/carreau.tscn")
const SCENE_PIEGE := preload("res://creatures/garin/piege.tscn")
## Le milieu du corps, son origine est à ses pieds.
const CENTRE := Vector2(0, -12)
const MARGE_ARRONDI := 0.001
## Durée du flash blanc quand il est touché, en secondes.
const DUREE_ECLAT := 0.1
## À la fin de la visée, le trait se fige : c'est le moment de rouler, en secondes.
const DUREE_VISEE_FIGEE := 0.25
## Vitesse quand il entre dans la lisière ou qu'il s'en va, en pixels par seconde.
const VITESSE_MARCHE := 40.0
## Durée du fondu quand il disparaît entre les arbres, en secondes.
const DUREE_FONDU := 0.6

@export_group("Vie")
## PV de départ. Il passe à la lame à la moitié.
@export var pv_max := 10

@export_group("Phase 1 : l'arbalète")
## Il recule quand Gojo est plus près que ça, en pixels.
@export var distance_de_confort := 96.0
## Vitesse quand il recule ou se replace, en pixels par seconde.
@export var vitesse_recul := 36.0
## Temps pendant lequel il vise avant de tirer, en secondes.
@export var duree_visee := 0.8
## Temps entre deux tirs, en secondes.
@export var recharge_arbalete := 1.4
## Il pose un piège quand Gojo est plus près que ça, en pixels.
@export var distance_piege := 56.0
## Temps minimum entre deux pièges, en secondes.
@export var recharge_piege := 3.0
## Nombre de pièges posés en même temps, au plus.
@export var pieges_max := 3

@export_group("Phase 2 : la lame")
## Vitesse quand il fonce sur sa cible, en pixels par seconde.
@export var vitesse_lame := 55.0
## Il lève la lame quand sa cible est à cette distance, en pixels.
@export var portee_lame := 22.0
## Temps où il lève la lame avant de frapper : le temps pour réagir, en secondes.
@export var duree_lame_levee := 0.4
## Durée du coup (le moment où il fait mal), en secondes.
@export var duree_coup_lame := 0.15
## Après un coup, il souffle : c'est le moment pour l'approcher, en secondes.
@export var duree_souffle := 1.1
## Frappé par un gobelin, il s'occupe de lui pendant ce temps, en secondes.
@export var duree_diversion := 2.5

@export_group("Pollen")
## Durée du sommeil après le pollen de fleur-trompette, en secondes.
@export var duree_sommeil := 3.0
## Après un réveil, le pollen ne marche plus sur lui pendant ce temps, en secondes.
@export var resistance_pollen := 6.0

@export_group("Couleurs provisoires")
@export var couleur_normale := Color("6b3f2f")
@export var couleur_endormi := Color("4a3b36")
@export var couleur_a_terre := Color("57392e")

var etat := Etat.ATTENTE
var phase := 1
var pv := 0
## Vrai une fois à terre, si sa page est complète : Gojo peut lui tendre le carnet.
var attend_le_carnet := false

var _temps_etat := 0.0
var _temps_eclat := 0.0
var _temps_avant_tir := 0.0
var _temps_avant_piege := 0.0
var _temps_resistance := 0.0
var _temps_diversion := 0.0
var _diversion: Node2D
var _destination := Vector2.ZERO
var _en_marche := false
## Où il regarde, et où partira le coup de lame.
var _regard := Vector2.LEFT
var _direction_visee := Vector2.LEFT
var _gojo: Gojo
var _position_arbalete := Vector2.ZERO

@onready var _corps: ColorRect = $Corps
@onready var _repere_regard: ColorRect = $RepereRegard
@onready var _arme: Node2D = $Arme
@onready var _arbalete: Node2D = $Arme/Arbalete
@onready var _visee: Line2D = $Arme/Visee
@onready var _lame: Node2D = $Lame
@onready var _hitbox_lame: Hitbox = $Lame/Hitbox
@onready var _torche: Node2D = $Torche
@onready var _flamme: ColorRect = $Torche/Flamme
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _interactif: Interactif = $Interactif
@onready var analysable: Analysable = $Analysable


func _ready() -> void:
	pv = pv_max
	_gojo = get_tree().get_first_node_in_group("gojo")
	_position_arbalete = _arbalete.position
	_hurtbox.touchee.connect(_on_touchee)
	_interactif.utilise.connect(_on_utilise)
	_mettre_a_jour_apparence()


## Il marche jusqu'à ce point, sans se battre (son entrée dans la lisière) ; émet arrive.
func marcher_vers(point: Vector2) -> void:
	_destination = point
	_en_marche = true


func commencer_combat() -> void:
	phase = 1
	_temps_avant_tir = recharge_arbalete
	_temps_avant_piege = 0.0
	_changer_etat(Etat.MARCHE)


## Tout recommence : Gojo est tombé K.O. pendant le combat.
func reinitialiser(point: Vector2) -> void:
	global_position = point
	reset_physics_interpolation()
	velocity = Vector2.ZERO
	pv = pv_max
	phase = 1
	_en_marche = false
	_temps_diversion = 0.0
	_temps_resistance = 0.0
	_retirer_projectiles()
	# Il a ramassé son arbalète.
	if _arbalete.get_parent() != _arme:
		_arbalete.reparent(_arme, false)
		_arbalete.position = _position_arbalete
		_arbalete.rotation = 0.0
		_arbalete.z_index = 0
	_changer_etat(Etat.ATTENTE)
	pv_changes.emit(pv, pv_max)


## Le pollen de fleur-trompette l'endort, sauf juste après un réveil.
func endormir() -> void:
	if not se_bat() or etat == Etat.ENDORMI or _temps_resistance > MARGE_ARRONDI:
		return
	_changer_etat(Etat.ENDORMI)
	velocity = Vector2.ZERO


func peut_etre_endormi() -> bool:
	return se_bat() and etat != Etat.ENDORMI and _temps_resistance <= MARGE_ARRONDI


## À terre, page complète : il attend que Gojo lui tende le carnet.
func attendre_le_carnet() -> void:
	attend_le_carnet = true


## Il laisse tomber sa torche, éteinte, là où il est.
func lacher_torche() -> void:
	_poser_au_sol(_torche, Vector2(-6, 0))
	_flamme.color = Color("3b302b")


## Il quitte la lisière vers ce point, puis disparaît entre les arbres ; émet parti.
func partir(point: Vector2) -> void:
	attend_le_carnet = false
	_destination = point
	_en_marche = true
	_changer_etat(Etat.DEPART)


func _physics_process(delta: float) -> void:
	_temps_etat += delta
	_temps_eclat = maxf(_temps_eclat - delta, 0.0)
	_temps_avant_tir = maxf(_temps_avant_tir - delta, 0.0)
	_temps_avant_piege = maxf(_temps_avant_piege - delta, 0.0)
	_temps_resistance = maxf(_temps_resistance - delta, 0.0)
	_temps_diversion = maxf(_temps_diversion - delta, 0.0)

	var vitesse_visee := Vector2.ZERO
	match etat:
		Etat.ATTENTE, Etat.DEPART:
			vitesse_visee = _marcher()
		Etat.MARCHE:
			if _gojo and _gojo.etat != Gojo.Etat.KO:
				vitesse_visee = _manoeuvrer_arbalete() if phase == 1 else _manoeuvrer_lame()
		Etat.VISEE:
			# Le trait suit Gojo, puis se fige juste avant le tir.
			if _gojo and _temps_etat < duree_visee - DUREE_VISEE_FIGEE:
				_direction_visee = (global_position + CENTRE).direction_to(_gojo.global_position + Gojo.CENTRE)
				_regard = _direction_visee
			if _temps_ecoule(duree_visee):
				_tirer()
				_changer_etat(Etat.MARCHE)
		Etat.LAME_LEVEE:
			if _temps_ecoule(duree_lame_levee):
				_changer_etat(Etat.LAME_COUP)
		Etat.LAME_COUP:
			if _temps_ecoule(duree_coup_lame):
				_changer_etat(Etat.SOUFFLE)
		Etat.SOUFFLE:
			if _temps_ecoule(duree_souffle):
				_changer_etat(Etat.MARCHE)
		Etat.ENDORMI:
			if _temps_ecoule(duree_sommeil):
				_se_reveiller()
	velocity = velocity.move_toward(vitesse_visee, 500.0 * delta)
	move_and_slide()

	# Chaque coup réactive la hitbox : c'est ce qui lui permet de toucher de nouveau.
	_hitbox_lame.active = etat == Etat.LAME_COUP
	_hurtbox.invincible = not se_bat()
	_mettre_a_jour_interactif()
	_mettre_a_jour_apparence()


## Vrai pendant le combat (endormi compris) ; faux avant son entrée, à terre, ou en partant.
func se_bat() -> bool:
	return etat in [Etat.MARCHE, Etat.VISEE, Etat.LAME_LEVEE, Etat.LAME_COUP, Etat.SOUFFLE, Etat.ENDORMI]


func _marcher() -> Vector2:
	if not _en_marche:
		return Vector2.ZERO
	var trajet := _destination - global_position
	if trajet.length() > 2.0:
		_regard = trajet.normalized()
		return _regard * VITESSE_MARCHE
	_en_marche = false
	if etat == Etat.DEPART:
		_disparaitre()
	else:
		arrive.emit()
	return Vector2.ZERO


## Phase 1 : garder ses distances, poser des pièges quand Gojo serre de près, et tirer.
func _manoeuvrer_arbalete() -> Vector2:
	var vers_gojo := global_position.direction_to(_gojo.global_position)
	var distance := global_position.distance_to(_gojo.global_position)
	_regard = vers_gojo
	if distance <= distance_piege and _temps_avant_piege <= MARGE_ARRONDI and _pieges().size() < pieges_max:
		_poser_piege()
	if _temps_avant_tir <= MARGE_ARRONDI:
		_changer_etat(Etat.VISEE)
		return Vector2.ZERO
	if distance < distance_de_confort:
		return -vers_gojo * vitesse_recul
	if distance > distance_de_confort * 1.5:
		return vers_gojo * vitesse_recul
	return Vector2.ZERO


## Phase 2 : foncer sur sa cible (Gojo, ou le gobelin qui vient de le frapper), et lever la lame.
func _manoeuvrer_lame() -> Vector2:
	var cible := _cible()
	var distance := global_position.distance_to(cible.global_position)
	_regard = global_position.direction_to(cible.global_position)
	if distance <= portee_lame:
		_changer_etat(Etat.LAME_LEVEE)
		return Vector2.ZERO
	return _regard * vitesse_lame


func _cible() -> Node2D:
	if _temps_diversion > MARGE_ARRONDI and is_instance_valid(_diversion) and _diversion.visible:
		return _diversion
	return _gojo


func _changer_etat(nouvel_etat: Etat) -> void:
	etat = nouvel_etat
	_temps_etat = 0.0
	if etat == Etat.VISEE:
		_direction_visee = _regard


func _tirer() -> void:
	var carreau: Hitbox = SCENE_CARREAU.instantiate()
	carreau.direction = _direction_visee
	get_parent().add_child(carreau)
	carreau.global_position = global_position + CENTRE + _direction_visee * 8.0
	_temps_avant_tir = recharge_arbalete


func _poser_piege() -> void:
	var piege: Node2D = SCENE_PIEGE.instantiate()
	get_parent().add_child(piege)
	piege.global_position = global_position
	_temps_avant_piege = recharge_piege


func _pieges() -> Array[Node]:
	return get_tree().get_nodes_in_group("pieges_de_garin")


func _retirer_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("projectiles_de_garin"):
		projectile.queue_free()


func _se_reveiller() -> void:
	_temps_resistance = resistance_pollen
	_changer_etat(Etat.MARCHE)


func _passer_a_la_lame() -> void:
	phase = 2
	_poser_au_sol(_arbalete, Vector2(10, 2))
	_retirer_projectiles()
	_changer_etat(Etat.SOUFFLE)
	deuxieme_phase.emit()


func _tomber() -> void:
	_changer_etat(Etat.A_TERRE)
	velocity = Vector2.ZERO
	_retirer_projectiles()
	a_terre.emit()


func _disparaitre() -> void:
	var fondu := create_tween()
	fondu.tween_property(self, "modulate:a", 0.0, DUREE_FONDU)
	await fondu.finished
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	parti.emit()


## Un objet qu'il tenait reste dans l'herbe, là où il est.
func _poser_au_sol(objet: Node2D, decalage: Vector2) -> void:
	var point := global_position + decalage
	objet.reparent(get_parent())
	objet.global_position = point
	objet.rotation = 0.0
	objet.z_index = 0


func _on_touchee(hitbox: Hitbox) -> void:
	if not se_bat():
		return
	var auteur := hitbox.owner
	# Seul un vrai coup le réveille : les gobelins du renfort ne font presque pas mal.
	if etat == Etat.ENDORMI and hitbox.degats > 0:
		_se_reveiller()
	pv = maxi(pv - hitbox.degats, 0)
	pv_changes.emit(pv, pv_max)
	_temps_eclat = DUREE_ECLAT
	# Lancé dans son coup, il ne recule pas ; et les gobelins le harcèlent sans le bousculer.
	if hitbox.degats > 0 and etat != Etat.LAME_LEVEE and etat != Etat.LAME_COUP:
		velocity = (global_position - hitbox.global_position).normalized() * hitbox.force_recul
	if auteur is Gobelin:
		_diversion = auteur
		_temps_diversion = duree_diversion
	elif auteur == _gojo:
		_temps_diversion = 0.0
	if pv == 0:
		_tomber()
	elif phase == 1 and pv <= pv_max / 2.0:
		_passer_a_la_lame()


func _on_utilise(_gojo_qui_agit: Gojo) -> void:
	if etat == Etat.A_TERRE and attend_le_carnet:
		attend_le_carnet = false
		carnet_tendu.emit()
	elif _gojo_a_la_fleur() and peut_etre_endormi():
		endormir()


func _gojo_a_la_fleur() -> bool:
	var plante := _gojo.sacoche.plante_choisie() if _gojo else null
	return plante != null and plante.effet == EspecePlante.Effet.ENDORT


func _mettre_a_jour_interactif() -> void:
	if etat == Etat.A_TERRE and attend_le_carnet:
		_interactif.verbe = "tendre le carnet"
		_interactif.actif = true
	else:
		_interactif.verbe = "souffler le pollen"
		_interactif.actif = _gojo_a_la_fleur() and peut_etre_endormi()


func _temps_ecoule(duree: float) -> bool:
	return _temps_etat >= duree - MARGE_ARRONDI


func _mettre_a_jour_apparence() -> void:
	var couleur := couleur_normale
	var hauteur := 22.0
	if etat == Etat.ENDORMI:
		couleur = couleur_endormi
	elif etat == Etat.A_TERRE:
		# À genoux.
		couleur = couleur_a_terre
		hauteur = 14.0
	if _temps_eclat > MARGE_ARRONDI:
		couleur = Color.WHITE
	_corps.color = couleur
	_corps.size.y = hauteur
	_corps.position.y = -hauteur
	if etat == Etat.LAME_LEVEE:
		# Il tremble avant de frapper : c'est l'avertissement.
		_corps.position.x = -_corps.size.x / 2.0 + (1.0 if posmod(Engine.get_physics_frames(), 4) < 2 else -1.0)
	else:
		_corps.position.x = -_corps.size.x / 2.0

	_arme.rotation = (_direction_visee if etat == Etat.VISEE else _regard).angle()
	_arbalete.visible = phase == 1 and _arbalete.get_parent() == _arme
	_visee.visible = etat == Etat.VISEE
	_visee.default_color = Color(0.95, 0.25, 0.2, 0.9 if _temps_etat >= duree_visee - DUREE_VISEE_FIGEE else 0.35)
	_lame.visible = phase == 2 and etat != Etat.A_TERRE and etat != Etat.DEPART
	_lame.rotation = _regard.angle()
	_lame.position.y = CENTRE.y - (4.0 if etat == Etat.LAME_LEVEE else 0.0)
	if _torche.get_parent() == self:
		_flamme.color = Color("f0a030") if posmod(Engine.get_physics_frames(), 12) < 6 else Color("e0702a")
	_repere_regard.visible = etat != Etat.A_TERRE
	_repere_regard.position = CENTRE + _regard * 5.0 - _repere_regard.size / 2.0

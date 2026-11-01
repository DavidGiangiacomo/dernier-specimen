class_name Gobelin
extends CharacterBody2D
## Un gobelin du Bois des Souches : Greg, Lila, les villageois, les malades, la meute du fourré.
##
## C'est le déroulé de la zone (bois_des_souches.gd) qui lui dit quoi faire : rester là,
## marcher vers un point, attaquer Gojo, ou attaquer Garin quand il vient en renfort.
## Un gobelin n'a pas de PV. Dans le fourré, les coups le font seulement reculer ; au camp,
## il n'a pas de hurtbox : on ne frappe pas ses alliés.

## Arrivé au bout de sa marche.
signal arrive
## Touché par le bâton (seulement quand il est frappable : Greg et la meute, dans le fourré).
signal frappe
## Gojo lui tend la plante choisie (seulement un malade).
signal plante_proposee(gobelin: Gobelin, gojo: Gojo)

enum Etat { IMMOBILE, MARCHE_VERS, ATTAQUE }

## Distance au-delà de laquelle un gobelin qui guide Gojo s'arrête pour l'attendre, en pixels.
const DISTANCE_ATTENTE := 72.0
## Durée du flash blanc quand il est touché, en secondes.
const DUREE_ECLAT := 0.1
## Distance à laquelle un gobelin qui attaque lance son coup, en pixels.
const PORTEE_COUP := 18.0

## Son nom, s'il en a un (Greg, Lila).
@export var nom := ""
## Ce qu'il dit quand on lui parle. Une ligne par réplique, écrite « Nom : texte ».
@export var repliques: Array[String] = []
## Vitesse de marche, en pixels par seconde.
@export var vitesse := 50.0
## Vitesse quand il attaque Gojo, en pixels par seconde.
@export var vitesse_attaque := 72.0
## Durée d'un coup (le moment où il fait mal), en secondes.
@export var duree_coup := 0.2
## Temps entre deux coups, en secondes.
@export var recharge_coup := 0.6
## Couleur du rectangle, en attendant les dessins.
@export var couleur := Color("6f9a4a")
## Où il regarde quand il ne bouge pas (au début, Greg et Lila tournent le dos à Gojo).
@export var regard := Vector2.DOWN
## Un bébé est plus petit.
@export var bebe := false
## Greg, de dos dans le fourré : l'invite propose de le frapper. C'est l'invitation du GDD au réflexe.
@export var provoque_l_attaque := false

@export_group("Malade")
## Le malade a de la fièvre (se soigne avec la mousse-de-lune).
@export var fievre := false
## Le malade a des taches noires (se soignent avec le capuchon gris).
@export var taches := false

var etat := Etat.IMMOBILE
## Pendant une marche : s'arrêter pour attendre Gojo s'il traîne (Greg qui guide).
var attendre_gojo := false
## Ce qu'il attaque : Gojo pendant le réflexe, Garin pendant le renfort.
var cible_attaque: Node2D

var _destination := Vector2.ZERO
var _temps_eclat := 0.0
var _temps_toux := 0.0
var _temps_coup := 0.0
var _temps_avant_coup := 0.0
var _gojo: Gojo
var _calque_des_coups := 0
var _degats_des_coups := 0
var _masque_de_la_hurtbox := 0

@onready var _corps: ColorRect = $Corps
@onready var _taches: Control = $Corps/Taches
@onready var _repere_regard: ColorRect = $RepereRegard
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _hitbox: Hitbox = $Hitbox
@onready var _interactif: Interactif = $Interactif
@onready var analysable: Analysable = $Analysable


func _ready() -> void:
	_gojo = get_tree().get_first_node_in_group("gojo")
	_calque_des_coups = _hitbox.collision_layer
	_degats_des_coups = _hitbox.degats
	_masque_de_la_hurtbox = _hurtbox.collision_mask
	_hurtbox.touchee.connect(_on_touchee)
	_interactif.utilise.connect(_on_utilise)
	analysable.toujours_analysable = est_malade()


func est_malade() -> bool:
	return fievre or taches


func marcher_vers(point: Vector2, guider := false) -> void:
	etat = Etat.MARCHE_VERS
	_destination = point
	attendre_gojo = guider


func attaquer(cible: Node2D = null) -> void:
	etat = Etat.ATTAQUE
	cible_attaque = cible if cible else _gojo


func s_arreter() -> void:
	etat = Etat.IMMOBILE


## Dans le fourré, le bâton le touche (sans lui faire de dégâts) ; au camp, non.
func rendre_frappable(frappable: bool) -> void:
	_hurtbox.set_deferred("monitoring", frappable)


## En renfort contre Garin : ses coups touchent Garin (ils ne font presque pas mal, mais
## Garin se retourne contre lui), et la lame de Garin le fait reculer.
func passer_en_renfort(degats: int) -> void:
	# Les calques s'échangent : ses coups deviennent des « coups de Gojo », et il reçoit
	# les « coups des créatures ».
	_hitbox.collision_layer = _masque_de_la_hurtbox
	_hitbox.degats = degats
	_hurtbox.collision_mask = _calque_des_coups
	rendre_frappable(true)


func quitter_le_renfort() -> void:
	_hitbox.collision_layer = _calque_des_coups
	_hitbox.degats = _degats_des_coups
	_hurtbox.collision_mask = _masque_de_la_hurtbox
	rendre_frappable(false)
	s_arreter()


func tousser() -> void:
	_temps_toux = 0.8


func soigner_fievre() -> void:
	fievre = false
	_apres_soin()


func soigner_taches() -> void:
	taches = false
	_apres_soin()


func _apres_soin() -> void:
	analysable.toujours_analysable = false
	if not est_malade():
		regard = Vector2.DOWN


func _physics_process(delta: float) -> void:
	_temps_eclat = maxf(_temps_eclat - delta, 0.0)
	_temps_toux = maxf(_temps_toux - delta, 0.0)
	_temps_coup = maxf(_temps_coup - delta, 0.0)
	_temps_avant_coup = maxf(_temps_avant_coup - delta, 0.0)

	var vitesse_visee := Vector2.ZERO
	match etat:
		Etat.MARCHE_VERS:
			var trajet := _destination - global_position
			var gojo_traine := attendre_gojo and _gojo and global_position.distance_to(_gojo.global_position) > DISTANCE_ATTENTE
			if trajet.length() <= 2.0:
				etat = Etat.IMMOBILE
				arrive.emit()
			elif not gojo_traine:
				regard = trajet.normalized()
				vitesse_visee = regard * vitesse
		Etat.ATTAQUE:
			if is_instance_valid(cible_attaque):
				regard = global_position.direction_to(cible_attaque.global_position)
				vitesse_visee = regard * vitesse_attaque
				# Assez près : il lance un coup, puis souffle un peu avant le suivant.
				if _temps_avant_coup <= 0.0 and global_position.distance_to(cible_attaque.global_position) <= PORTEE_COUP:
					_temps_coup = duree_coup
					_temps_avant_coup = duree_coup + recharge_coup
	velocity = velocity.move_toward(vitesse_visee, 600.0 * delta)
	move_and_slide()

	# Chaque coup réactive la hitbox : c'est ce qui lui permet de toucher Gojo de nouveau.
	_hitbox.active = etat == Etat.ATTAQUE and _temps_coup > 0.0
	_mettre_a_jour_interactif()
	_mettre_a_jour_apparence()


func _mettre_a_jour_interactif() -> void:
	if provoque_l_attaque:
		_interactif.touche = "J"
		_interactif.verbe = "frapper"
		_interactif.actif = _gojo != null and _gojo.a_le_baton
		return
	_interactif.touche = "E"
	var a_une_plante := _gojo != null and _gojo.sacoche.plante_choisie() != null
	if est_malade() and a_une_plante:
		_interactif.verbe = "donner la plante"
		_interactif.actif = true
	else:
		_interactif.verbe = "parler"
		_interactif.actif = not repliques.is_empty() and etat != Etat.ATTAQUE


func _on_utilise(gojo: Gojo) -> void:
	if provoque_l_attaque:
		return
	if est_malade() and gojo.sacoche.plante_choisie():
		plante_proposee.emit(self, gojo)
	elif not repliques.is_empty():
		Dialogue.dire(repliques)


func _on_touchee(hitbox: Hitbox) -> void:
	_temps_eclat = DUREE_ECLAT
	velocity = (global_position - hitbox.global_position).normalized() * hitbox.force_recul
	frappe.emit()


func _mettre_a_jour_apparence() -> void:
	# Couché s'il est malade, plus petit si c'est un bébé.
	var taille := Vector2(20, 10) if est_malade() else (Vector2(8, 9) if bebe else Vector2(16, 18))
	_corps.size = taille
	_corps.position = Vector2(-taille.x / 2.0, -taille.y)
	if _temps_toux > 0.0:
		_corps.position.x += 1.0 if posmod(Engine.get_physics_frames(), 4) < 2 else -1.0
	var teinte := couleur.lerp(Color("c0563c"), 0.45) if fievre else couleur
	if _temps_coup > 0.0:
		teinte = teinte.darkened(0.35)
	_corps.color = Color.WHITE if _temps_eclat > 0.0 else teinte
	_taches.visible = taches
	_repere_regard.visible = not est_malade()
	_repere_regard.position = Vector2(0, -taille.y / 2.0) + regard * (taille.x / 2.0 - 2.0) - _repere_regard.size / 2.0

extends Control
## Le carnet ouvert, en plein écran. Tab (ou I, ou Select à la manette) l'ouvre et le ferme ;
## le jeu est en pause pendant ce temps. Gauche et droite tournent les pages.
##
## Une page montre le nom, le croquis, une description, une ligne par analyse réussie,
## puis la clé avec la dernière observation. Tant que l'espèce n'a pas été apaisée,
## Gojo écrit en savant, à l'encre froide ; ensuite, en langage humain, à l'encre chaude.

## Encre du savant, avant d'avoir compris.
@export var encre_avant := Color("2d3a4a")
## Encre de Gojo, une fois qu'il a compris.
@export var encre_apres := Color("6b3a17")
## Couleur des lignes pas encore découvertes.
@export var encre_effacee := Color("b3a585")
## Couleur de la clé.
@export var encre_cle := Color("9a6a0c")

var _page := 0

@onready var _croquis_image: TextureRect = $Papier/Croquis
@onready var _croquis_provisoire: ColorRect = $Papier/CroquisProvisoire
@onready var _titre: Label = $Papier/Titre
@onready var _description: Label = $Papier/Description
@onready var _apaisee: Label = $Papier/Apaisee
@onready var _observations: VBoxContainer = $Papier/Observations
@onready var _cle: Label = $Papier/Cle
@onready var _pied: Label = $Papier/Pied
@onready var _vide: Label = $Papier/Vide


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func _process(_delta: float) -> void:
	if Dialogue.en_cours:
		return
	if Input.is_action_just_pressed("carnet"):
		if visible:
			fermer()
		else:
			ouvrir()
	elif visible:
		if Input.is_action_just_pressed("gauche"):
			_tourner(-1)
		elif Input.is_action_just_pressed("droite"):
			_tourner(1)


func ouvrir() -> void:
	visible = true
	get_tree().paused = true
	# On ouvre sur la dernière espèce rencontrée.
	_page = Carnet.especes().size() - 1
	_afficher()


func fermer() -> void:
	visible = false
	get_tree().paused = false


func _tourner(sens: int) -> void:
	var nombre := Carnet.especes().size()
	if nombre > 1:
		_page = posmod(_page + sens, nombre)
		_afficher()


func _afficher() -> void:
	var especes := Carnet.especes()
	var vide := especes.is_empty()
	_vide.visible = vide
	for noeud in [_croquis_image, _croquis_provisoire, _titre, _description, _apaisee, _observations, _cle]:
		noeud.visible = not vide
	if vide:
		_pied.text = "Tab : fermer"
		return

	var espece: Espece = especes[_page]
	var apaisee := Carnet.est_apaisee(espece)
	var encre := encre_apres if apaisee else encre_avant
	var analyses := Carnet.analyses(espece)

	_croquis_image.texture = espece.croquis
	_croquis_image.visible = espece.croquis != null
	_croquis_provisoire.visible = espece.croquis == null
	_croquis_provisoire.color = espece.couleur

	_titre.text = espece.nom_veritable if apaisee else espece.nom_de_terrain
	_description.text = espece.description_apres if apaisee else espece.description_avant
	_apaisee.visible = apaisee
	for etiquette in [_titre, _description]:
		etiquette.add_theme_color_override("font_color", encre)

	var lignes := _lignes_observation(Carnet.analyses_requises(espece))
	for i in lignes.size():
		var decouverte := i < analyses and i < espece.observations.size()
		lignes[i].text = "%d. %s" % [i + 1, espece.observations[i] if decouverte else "· · ·"]
		lignes[i].add_theme_color_override("font_color", encre if decouverte else encre_effacee)

	# Les plantes de l'herbier n'ont pas de clé.
	_cle.visible = not (espece is EspecePlante)
	if Carnet.est_complete(espece):
		_cle.text = "Clé : " + espece.cle
		_cle.add_theme_color_override("font_color", encre_cle)
	else:
		_cle.text = "Clé : ?"
		_cle.add_theme_color_override("font_color", encre_effacee)

	var navigation := "   < %d / %d >" % [_page + 1, especes.size()] if especes.size() > 1 else ""
	_pied.text = "Tab : fermer" + navigation


## Les étiquettes d'observation : une par analyse de la page, créées au besoin.
func _lignes_observation(nombre: int) -> Array[Label]:
	while _observations.get_child_count() < nombre:
		_observations.add_child(_observations.get_child(0).duplicate())
	var lignes: Array[Label] = []
	for i in _observations.get_child_count():
		var ligne: Label = _observations.get_child(i)
		ligne.visible = i < nombre
		if i < nombre:
			lignes.append(ligne)
	return lignes

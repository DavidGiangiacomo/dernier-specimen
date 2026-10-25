extends CanvasLayer
## La boîte de dialogue : une ligne à la fois, pas d'arbre, pas de choix.
##
## Chaque ligne s'écrit « Nom : texte » ; une ligne sans nom est une description.
## E (ou Entrée, ou Y à la manette) passe à la ligne suivante. Le jeu est en pause pendant ce temps.
## C'est un « autoload » : on l'appelle de partout avec await Dialogue.dire([...]).

signal termine

var en_cours := false
## Vrai juste après un dialogue, tant que la touche n'est pas relâchée :
## sans ça, la touche qui ferme la boîte relancerait aussitôt la conversation.
var attendre_relache := false

var _lignes: Array[String] = []
var _index := 0
var _image_debut := 0

@onready var _boite: Control = $Boite
@onready var _nom: Label = $Boite/Nom
@onready var _texte: Label = $Boite/Texte


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_boite.visible = false


func dire(lignes: Array[String]) -> void:
	if lignes.is_empty() or en_cours:
		return
	_lignes = lignes.duplicate()
	_index = 0
	en_cours = true
	_image_debut = Engine.get_process_frames()
	get_tree().paused = true
	_afficher()
	_boite.visible = true
	await termine


func _process(_delta: float) -> void:
	if not Input.is_action_pressed("interagir"):
		attendre_relache = false
	if not en_cours or Engine.get_process_frames() == _image_debut:
		return
	if Input.is_action_just_pressed("interagir"):
		_index += 1
		if _index < _lignes.size():
			_afficher()
		else:
			_finir()


func _afficher() -> void:
	var ligne := _lignes[_index]
	var separation := ligne.find(" : ")
	_nom.text = ligne.substr(0, separation) if separation > 0 else ""
	_texte.text = ligne.substr(separation + 3) if separation > 0 else ligne


func _finir() -> void:
	en_cours = false
	attendre_relache = true
	_boite.visible = false
	get_tree().paused = false
	termine.emit()

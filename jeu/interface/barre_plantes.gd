extends Control
## La barre des quatre cases de la sacoche, en bas à gauche, visible en permanence.
## La case choisie (R pour changer) est encadrée ; son nom s'écrit à côté.

## Côté d'une case, en pixels.
const TAILLE := 12
## Espace entre deux cases, en pixels.
const ECART := 2

@export var gojo: Gojo
@export var couleur_case := Color(0.0, 0.0, 0.0, 0.45)
@export var couleur_choix := Color("f2c14e")

@onready var _nom: Label = $Nom


func _ready() -> void:
	if gojo:
		gojo.sacoche.changee.connect(_mettre_a_jour)
	Carnet.page_changee.connect(func(_e, _a): _mettre_a_jour())
	_mettre_a_jour()


func _mettre_a_jour() -> void:
	var plante := gojo.sacoche.plante_choisie() if gojo else null
	_nom.text = _nom_de(plante) if plante else ""
	queue_redraw()


func _nom_de(plante: EspecePlante) -> String:
	return plante.nom_de_terrain if Carnet.est_complete(plante) else plante.nom_apparent


func _draw() -> void:
	if not gojo:
		return
	var sacoche := gojo.sacoche
	for i in sacoche.cases:
		var case := Rect2(i * (TAILLE + ECART), 0, TAILLE, TAILLE)
		if i == sacoche.choix and i < sacoche.plantes.size():
			draw_rect(case.grow(1), couleur_choix)
		draw_rect(case, couleur_case)
		if i < sacoche.plantes.size():
			var plante := sacoche.plantes[i]
			var couleur := plante.couleur if Carnet.est_complete(plante) else plante.couleur_apparente
			draw_rect(case.grow(-3), couleur)

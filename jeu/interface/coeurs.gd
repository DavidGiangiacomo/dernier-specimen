extends Control
## Les cœurs de Gojo, en haut à gauche de l'écran. Un cœur vaut 2 PV.

## Côté d'un cœur, en pixels.
const TAILLE := 8
## Espace entre deux cœurs, en pixels.
const ECART := 3

@export var gojo: Gojo
@export var couleur_plein := Color("d94a3d")
@export var couleur_vide := Color("3a2420")

var _pv := 0
var _pv_max := 0


func _ready() -> void:
	if gojo:
		gojo.pv_changes.connect(_on_pv_changes)
		_on_pv_changes(gojo.pv, gojo.pv_max)


func _on_pv_changes(pv: int, pv_max: int) -> void:
	_pv = pv
	_pv_max = pv_max
	queue_redraw()


func _draw() -> void:
	for i in ceili(_pv_max / 2.0):
		var case := Rect2(i * (TAILLE + ECART), 0, TAILLE, TAILLE)
		draw_rect(case, couleur_vide)
		var rempli := clampi(_pv - i * 2, 0, 2)
		if rempli > 0:
			draw_rect(Rect2(case.position, Vector2(TAILLE * rempli / 2.0, TAILLE)), couleur_plein)

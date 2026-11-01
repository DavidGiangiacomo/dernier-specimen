extends Control
## La vie de Garin Corbe pendant le combat, en haut de l'écran, sous son nom.

## Largeur de la barre, en pixels.
const LARGEUR := 120
## Hauteur de la barre, en pixels.
const HAUTEUR := 4
## La barre est sous le nom, à cette hauteur, en pixels.
const HAUT_DE_LA_BARRE := 13

@export var garin: Garin
@export var couleur_vide := Color("3a2420")
@export var couleur_pleine := Color("c9a24a")

var _pv := 0
var _pv_max := 1


func _ready() -> void:
	visible = false
	if garin:
		garin.pv_changes.connect(_on_pv_changes)
		_on_pv_changes(garin.pv, garin.pv_max)


func _on_pv_changes(pv: int, pv_max: int) -> void:
	_pv = pv
	_pv_max = maxi(pv_max, 1)
	queue_redraw()


func _draw() -> void:
	var gauche := (size.x - LARGEUR) / 2.0
	draw_rect(Rect2(gauche, HAUT_DE_LA_BARRE, LARGEUR, HAUTEUR), couleur_vide)
	draw_rect(Rect2(gauche, HAUT_DE_LA_BARRE, LARGEUR * float(_pv) / _pv_max, HAUTEUR), couleur_pleine)

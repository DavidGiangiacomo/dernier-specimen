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
## Les trois dessins d'un cœur. Nuls tant que les images ne sont pas là, et
## les rectangles provisoires continuent alors de s'afficher.
var _dessins: Array[Texture2D] = []


func _ready() -> void:
	_charger_les_dessins()
	if gojo:
		gojo.pv_changes.connect(_on_pv_changes)
		_on_pv_changes(gojo.pv, gojo.pv_max)


func _on_pv_changes(pv: int, pv_max: int) -> void:
	_pv = pv
	_pv_max = pv_max
	queue_redraw()


## Un cœur vide, un cœur à moitié, un cœur plein — dans cet ordre, pour que
## le nombre de PV restants dans le cœur serve directement d'indice.
func _charger_les_dessins() -> void:
	var trouves: Array[Texture2D] = []
	for nom in ["vide", "demi", "plein"]:
		var chemin := "res://interface/sprites/coeur_%s.png" % nom
		if not ResourceLoader.exists(chemin):
			return
		trouves.append(load(chemin))
	_dessins = trouves


func _draw() -> void:
	for i in ceili(_pv_max / 2.0):
		var coin := Vector2(i * (TAILLE + ECART), 0)
		var rempli := clampi(_pv - i * 2, 0, 2)
		if not _dessins.is_empty():
			draw_texture(_dessins[rempli], coin)
			continue
		# Pas de dessins : les rectangles provisoires font le travail.
		var case := Rect2(coin, Vector2(TAILLE, TAILLE))
		draw_rect(case, couleur_vide)
		if rempli > 0:
			draw_rect(Rect2(case.position, Vector2(TAILLE * rempli / 2.0, TAILLE)), couleur_plein)

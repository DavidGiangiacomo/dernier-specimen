extends Control
## La page du carnet en cours, en haut à droite de l'écran : une ligne d'encre par analyse réussie.
##
## Version provisoire du jalon 2. Le vrai carnet, avec ses textes et la clé, arrive au jalon 3.

## Largeur de la page, en pixels.
const LARGEUR := 28
## Durée du flash quand une ligne s'ajoute, en secondes.
const DUREE_ECLAT := 0.3

@export var couleur_papier := Color("efe4c8")
@export var couleur_ligne_vide := Color("d6c7a4")
@export var couleur_encre := Color("2c211a")
## Couleur du cadre quand la page est complète.
@export var couleur_complete := Color("d99413")

var _espece: Espece
var _analyses := 0
var _temps_eclat := 0.0


func _ready() -> void:
	Carnet.page_changee.connect(_on_page_changee)
	visible = false


func _process(delta: float) -> void:
	if _temps_eclat > 0.0:
		_temps_eclat = maxf(_temps_eclat - delta, 0.0)
		queue_redraw()


func _on_page_changee(espece: Espece, analyses: int) -> void:
	_espece = espece
	_analyses = analyses
	_temps_eclat = DUREE_ECLAT
	visible = true
	queue_redraw()


func _draw() -> void:
	if _espece == null:
		return
	var lignes := Carnet.analyses_requises(_espece)
	var page := Rect2(0, 0, LARGEUR, 10 + lignes * 4)
	if _analyses >= lignes:
		draw_rect(page.grow(1), couleur_complete)
	draw_rect(page, couleur_papier.lerp(Color.WHITE, _temps_eclat / DUREE_ECLAT))
	# Le croquis, en attendant les dessins : un carré de la couleur de l'espèce.
	draw_rect(Rect2(3, 3, 5, 5), _espece.couleur)
	for i in lignes:
		draw_rect(Rect2(3, 10 + i * 4, LARGEUR - 6, 1), couleur_encre if i < _analyses else couleur_ligne_vide)

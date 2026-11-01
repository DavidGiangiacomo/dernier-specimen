class_name SpriteDirectionnel
extends Sprite2D
## Le dessin d'un personnage, qui suit la direction qu'il regarde.
##
## Les huit images doivent porter le nom de leur direction, dans un même
## dossier : gojo_south.png, gojo_south-east.png, gojo_east.png, et ainsi de
## suite. On renseigne ici le dossier et le début du nom.
##
## Tant qu'une des huit images manque, ce nœud reste invisible et le rectangle
## de couleur provisoire continue de s'afficher : le jeu marche comme avant.
## C'est voulu — le code ne doit jamais attendre l'art.

## Les huit directions, dans l'ordre des angles en partant de la droite.
const DIRECTIONS: Array[String] = [
	"east", "south-east", "south", "south-west",
	"west", "north-west", "north", "north-east",
]

## Le dossier qui contient les huit images.
@export var dossier := ""
## Le début du nom des fichiers, avant la direction.
@export var prefixe := ""
## La couleur du rectangle provisoire que ce dessin remplace. Les scripts
## continuent de calculer des couleurs d'état ; on en déduit une teinte.
@export var couleur_de_reference := Color.WHITE
## Le rectangle provisoire, à masquer dès que les huit dessins sont là.
@export var provisoire: NodePath

## Au-dessus de ce seuil sur les trois canaux, la couleur demandée est un éclat
## blanc, pas une teinte : on blanchit alors franchement tout le dessin.
const SEUIL_ECLAT := 0.98
## De combien on multiplie pour que même les pixels sombres virent au blanc.
const FORCE_ECLAT := 6.0

var _images := {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for direction in DIRECTIONS:
		var chemin := "%s/%s_%s.png" % [dossier, prefixe, direction]
		if ResourceLoader.exists(chemin):
			_images[direction] = load(chemin)
	if _images.size() < DIRECTIONS.size():
		# Il manque des dessins : on laisse le rectangle provisoire travailler.
		visible = false
		return
	var rectangle := get_node_or_null(provisoire)
	if rectangle:
		rectangle.visible = false
	regarder(Vector2.DOWN)


## Montre l'image qui correspond à la direction. Une direction nulle ne change rien :
## un personnage à l'arrêt garde le dessin de sa dernière direction.
func regarder(direction: Vector2) -> void:
	if not visible or direction.is_zero_approx():
		return
	var huitieme := posmod(roundi(direction.angle() / (TAU / 8.0)), 8)
	texture = _images[DIRECTIONS[huitieme]]


## Reprend la couleur d'état que le script du personnage calcule déjà, et la
## traduit en teinte. Le blanc d'un coup reçu blanchit donc le dessin, et le
## rouge de la hure qui se prépare le rougit — sans rien changer au code qui
## décide de ces couleurs.
func teinter(couleur: Color) -> void:
	if not visible:
		return
	var a := modulate.a
	if couleur.r >= SEUIL_ECLAT and couleur.g >= SEUIL_ECLAT and couleur.b >= SEUIL_ECLAT:
		# Un éclat blanc. Une teinte multiplicative laisserait les pixels sombres
		# sombres, et le joueur ne verrait pas qu'il a été touché.
		modulate = Color(FORCE_ECLAT, FORCE_ECLAT, FORCE_ECLAT)
		modulate.a = a
		return
	modulate = Color(
		couleur.r / maxf(couleur_de_reference.r, 0.01),
		couleur.g / maxf(couleur_de_reference.g, 0.01),
		couleur.b / maxf(couleur_de_reference.b, 0.01),
	)
	modulate.a = a

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
## Les états qui ont leur propre jeu de huit dessins, nommés
## <prefixe>_<etat>_<direction>.png — par exemple « apaisee » pour la hure
## sans son épine, « a_terre » pour Garin à genoux. Un état dont il manque
## une image est ignoré : on garde le jeu normal plutôt que d'afficher un trou.
@export var etats: Array[String] = []
## Parmi eux, ceux dont le dessin se suffit : on ne les teinte plus. Une
## couleur d'état réglée pour remplacer un rectangle délave un dessin qui dit
## déjà la même chose. Mais une teinte qui ajoute une information — la fièvre
## du gobelin, qui se cumule avec ses taches — doit continuer de passer.
@export var etats_sans_teinte: Array[String] = []

## Au-dessus de ce seuil sur les trois canaux, la couleur demandée est un éclat
## blanc, pas une teinte : on blanchit alors franchement tout le dessin.
const SEUIL_ECLAT := 0.98
## De combien on multiplie pour que même les pixels sombres virent au blanc.
const FORCE_ECLAT := 6.0

var _images := {}
## Un jeu de huit images par état ; la chaîne vide est l'état normal.
var _jeux := {}
var _etat := ""
var _derniere := "south"


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_images = _charger("")
	if _images.size() < DIRECTIONS.size():
		# Il manque des dessins : on laisse le rectangle provisoire travailler.
		visible = false
		return
	_jeux[""] = _images
	for nom in etats:
		var jeu := _charger(nom)
		if jeu.size() == DIRECTIONS.size():
			_jeux[nom] = jeu
	var rectangle := get_node_or_null(provisoire)
	if rectangle:
		rectangle.visible = false
	regarder(Vector2.DOWN)


## Charge les huit images d'un état. Nom vide : l'état normal.
func _charger(nom: String) -> Dictionary:
	var jeu := {}
	var milieu := "" if nom == "" else nom + "_"
	for direction in DIRECTIONS:
		var chemin := "%s/%s_%s%s.png" % [dossier, prefixe, milieu, direction]
		if ResourceLoader.exists(chemin):
			jeu[direction] = load(chemin)
	return jeu


## Bascule sur le jeu de dessins d'un état, ou sur le jeu normal avec "".
## Un état dont le jeu manque ne change rien : mieux vaut le mauvais dessin
## que pas de dessin du tout.
func etat(nom: String) -> void:
	if not visible or nom == _etat or not _jeux.has(nom):
		return
	_etat = nom
	_images = _jeux[nom]
	texture = _images[_derniere]


## Montre l'image qui correspond à la direction. Une direction nulle ne change rien :
## un personnage à l'arrêt garde le dessin de sa dernière direction.
func regarder(direction: Vector2) -> void:
	if not visible or direction.is_zero_approx():
		return
	var huitieme := posmod(roundi(direction.angle() / (TAU / 8.0)), 8)
	_derniere = DIRECTIONS[huitieme]
	texture = _images[_derniere]


## Reprend la couleur d'état que le script du personnage calcule déjà, et la
## traduit en teinte. Le blanc d'un coup reçu blanchit donc le dessin, et le
## rouge de la hure qui se prépare le rougit — sans rien changer au code qui
## décide de ces couleurs.
func teinter(couleur: Color) -> void:
	if not visible:
		return
	var a := modulate.a
	if etats_sans_teinte.has(_etat) and not _est_un_eclat(couleur):
		# L'état a son propre dessin : il dit déjà ce qu'il a à dire, et le
		# teinter par-dessus ne ferait que délaver une image déjà juste.
		# Seul l'éclat d'un coup reçu passe encore.
		modulate = Color(1, 1, 1, a)
		return
	if _est_un_eclat(couleur):
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


## Vrai si la couleur demandée est un éclat blanc, et non une teinte d'état.
func _est_un_eclat(couleur: Color) -> bool:
	return couleur.r >= SEUIL_ECLAT and couleur.g >= SEUIL_ECLAT and couleur.b >= SEUIL_ECLAT

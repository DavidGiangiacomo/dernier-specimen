extends Node2D
## Une plante du Bois des Souches, qu'on peut analyser (une fois) puis cueillir.
##
## Avant l'analyse, elle a l'air de ce qu'elle a l'air : la mousse-de-lune et la ronce-rouge
## se ressemblent beaucoup. Une fois son espèce dans l'herbier, Gojo voit la différence.

@export var espece: EspecePlante

## Les deux dessins d'une plante : ce qu'on en voit avant de l'avoir analysée,
## et ce qu'on en voit après. Nuls tant que les images ne sont pas là, et le
## rectangle provisoire continue alors de s'afficher.
var _dessin_apparent: Texture2D
var _dessin_connu: Texture2D

@onready var _visuel: ColorRect = $Visuel
@onready var _dessin: Sprite2D = get_node_or_null("Dessin")
@onready var _analysable: Analysable = $Analysable
@onready var _interactif: Interactif = $Interactif


func _ready() -> void:
	_analysable.espece = espece
	_charger_les_dessins()
	_interactif.utilise.connect(_on_utilise)
	Carnet.page_changee.connect(func(_e, _a): _mettre_a_jour())
	_mettre_a_jour()


## Les images portent le nom du fichier d'espèce : mousse_de_lune.png pour ce
## que Gojo voit une fois l'espèce dans son herbier, mousse_de_lune_apparent.png
## pour avant. Celle de la ronce-rouge est volontairement identique à celle de
## la mousse-de-lune : c'est toute l'énigme.
func _charger_les_dessins() -> void:
	if _dessin == null or espece == null or espece.resource_path == "":
		if _dessin:
			_dessin.visible = false
		return
	var base := espece.resource_path.get_file().get_basename()
	var connu := "res://plantes/sprites/%s.png" % base
	var apparent := "res://plantes/sprites/%s_apparent.png" % base
	if not (ResourceLoader.exists(connu) and ResourceLoader.exists(apparent)):
		# Il manque un dessin : le rectangle provisoire reprend la main.
		_dessin.visible = false
		return
	_dessin_connu = load(connu)
	_dessin_apparent = load(apparent)
	_visuel.visible = false


func _mettre_a_jour() -> void:
	var connue := Carnet.est_complete(espece)
	_visuel.color = espece.couleur if connue else espece.couleur_apparente
	if _dessin and _dessin.visible:
		_dessin.texture = _dessin_connu if connue else _dessin_apparent
	_interactif.verbe = "cueillir " + (espece.nom_de_terrain if connue else espece.nom_apparent).to_lower()


func _on_utilise(gojo: Gojo) -> void:
	if gojo.sacoche.ajouter(espece):
		queue_free()
	else:
		Dialogue.dire(["La sacoche est pleine : quatre plantes, pas une de plus."])

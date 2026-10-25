extends Node2D
## Une plante du Bois des Souches, qu'on peut analyser (une fois) puis cueillir.
##
## Avant l'analyse, elle a l'air de ce qu'elle a l'air : la mousse-de-lune et la ronce-rouge
## se ressemblent beaucoup. Une fois son espèce dans l'herbier, Gojo voit la différence.

@export var espece: EspecePlante

@onready var _visuel: ColorRect = $Visuel
@onready var _analysable: Analysable = $Analysable
@onready var _interactif: Interactif = $Interactif


func _ready() -> void:
	_analysable.espece = espece
	_interactif.utilise.connect(_on_utilise)
	Carnet.page_changee.connect(func(_e, _a): _mettre_a_jour())
	_mettre_a_jour()


func _mettre_a_jour() -> void:
	var connue := Carnet.est_complete(espece)
	_visuel.color = espece.couleur if connue else espece.couleur_apparente
	_interactif.verbe = "cueillir " + (espece.nom_de_terrain if connue else espece.nom_apparent).to_lower()


func _on_utilise(gojo: Gojo) -> void:
	if gojo.sacoche.ajouter(espece):
		queue_free()
	else:
		Dialogue.dire(["La sacoche est pleine : quatre plantes, pas une de plus."])

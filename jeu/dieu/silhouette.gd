extends Node2D
## Le Dieu des monstres, aperçu en lisière de forêt : une silhouette immobile et muette,
## qui s'efface quand Gojo s'approche, et ne revient pas.
##
## Aucune mécanique : on ne peut ni lui parler, ni le toucher. C'est de l'ambiance, et la
## dernière phrase du pitch : « Et le Dieu des monstres le regarde. »

## Gojo à cette distance : elle s'efface, en pixels.
@export var distance_disparition := 80.0
## Durée du fondu, en secondes.
@export var duree_fondu := 0.6
## Faux pour une silhouette qui n'apparaît qu'à un moment du déroulé (après le départ de Garin).
@export var visible_au_depart := true

var _effacee := false
var _gojo: Node2D


func _ready() -> void:
	visible = visible_au_depart
	_gojo = get_tree().get_first_node_in_group("gojo")


func apparaitre() -> void:
	if not _effacee:
		visible = true


## Vrai une fois qu'elle s'est effacée.
func est_effacee() -> bool:
	return _effacee


func _physics_process(_delta: float) -> void:
	if visible and not _effacee and _gojo and global_position.distance_to(_gojo.global_position) <= distance_disparition:
		_effacer()


func _effacer() -> void:
	_effacee = true
	var fondu := create_tween()
	fondu.tween_property(self, "modulate:a", 0.0, duree_fondu)
	await fondu.finished
	visible = false

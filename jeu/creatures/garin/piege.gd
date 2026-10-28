extends Hitbox
## Un piège à mâchoires que Garin pose derrière lui quand Gojo le serre de près.
##
## Il se voit, et il ne sert qu'une fois : il se referme sur le premier qui marche dessus.
## Une roulade passe par-dessus sans le déclencher.

## Temps pendant lequel on voit le piège refermé, avant qu'il disparaisse, en secondes.
@export var duree_referme := 0.5

@onready var _machoires: Node2D = $Machoires


func _ready() -> void:
	a_touche.connect(_on_a_touche)


func _on_a_touche(_hurtbox: Hurtbox) -> void:
	active = false
	_machoires.scale.x = 0.4
	await get_tree().create_timer(duree_referme, false).timeout
	queue_free()

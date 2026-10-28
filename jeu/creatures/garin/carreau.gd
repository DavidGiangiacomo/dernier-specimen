extends Hitbox
## Un carreau d'arbalète de Garin : il file tout droit, et se perd dans le premier arbre.
##
## On l'esquive en se décalant, ou en roulant au travers : la roulade rend invincible.

## Vitesse du carreau, en pixels par seconde.
@export var vitesse := 150.0
## Au-delà, le carreau tombe dans l'herbe, en secondes.
@export var duree_de_vol := 2.0

## Réglée par Garin au moment du tir.
var direction := Vector2.RIGHT

var _temps := 0.0


func _ready() -> void:
	rotation = direction.angle()
	a_touche.connect(func(_h): queue_free())
	body_entered.connect(func(_corps): queue_free())


func _physics_process(delta: float) -> void:
	position += direction * vitesse * delta
	_temps += delta
	if _temps >= duree_de_vol:
		queue_free()

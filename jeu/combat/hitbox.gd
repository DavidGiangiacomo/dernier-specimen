class_name Hitbox
extends Area2D
## Une zone qui fait mal : le bâton de Gojo, la charge de la hure…
##
## Elle ne touche que les hurtbox dont le masque contient son calque :
## « coups de Gojo » pour Gojo, « coups des créatures » pour les créatures.
## Chaque cible n'est touchée qu'une fois par coup, même si le coup dure longtemps.

## PV retirés à ce qui est touché.
@export var degats := 1
## Vitesse donnée à la cible pour la faire reculer, en pixels par seconde.
@export var force_recul := 120.0
## Une hitbox inactive ne fait pas mal. La réactiver commence un nouveau coup.
@export var active := true:
	set(valeur):
		if valeur and not active:
			_deja_touchees.clear()
		active = valeur

var _deja_touchees: Array[Hurtbox] = []


## Vrai si ce coup peut encore toucher cette hurtbox.
func peut_toucher(hurtbox: Hurtbox) -> bool:
	return active and not _deja_touchees.has(hurtbox)


func noter_touchee(hurtbox: Hurtbox) -> void:
	_deja_touchees.append(hurtbox)

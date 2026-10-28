class_name Hurtbox
extends Area2D
## Une zone qui peut être touchée. Elle prévient son propriétaire quand une hitbox active la touche.
##
## Après un coup, elle ne peut plus être touchée pendant un moment :
## c'est ce qui évite de perdre tous ses PV d'un seul contact. Un coup qui ne fait pas mal
## (les gobelins du renfort sur Garin) ne la protège pas.

signal touchee(hitbox: Hitbox)

## Marge pour les arrondis : 48 × (1/60) ne tombe pas pile sur 0,8.
const MARGE_ARRONDI := 0.001

## Après un coup, temps pendant lequel on ne peut plus être touché, en secondes.
@export var invincibilite_apres_coup := 0.8
## Mis à vrai par le propriétaire, par exemple pendant le début de la roulade.
var invincible := false

var _temps_invincibilite := 0.0


## Vrai tant qu'aucun coup ne peut passer : roulade, ou juste après un coup.
func est_invincible() -> bool:
	return invincible or vient_d_etre_touchee()


## Vrai pendant l'invincibilité qui suit un coup (pas celle de la roulade).
func vient_d_etre_touchee() -> bool:
	return _temps_invincibilite > MARGE_ARRONDI


func _physics_process(delta: float) -> void:
	_temps_invincibilite = maxf(_temps_invincibilite - delta, 0.0)
	# Une hurtbox désactivée (un gobelin du camp, par exemple) ne peut pas être touchée.
	if est_invincible() or not monitoring:
		return
	for zone in get_overlapping_areas():
		var hitbox := zone as Hitbox
		if hitbox and hitbox.peut_toucher(self):
			hitbox.noter_touchee(self)
			if hitbox.degats > 0:
				_temps_invincibilite = invincibilite_apres_coup
			touchee.emit(hitbox)
			return

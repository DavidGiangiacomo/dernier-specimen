class_name Analysable
extends Area2D
## Une zone que le gant de Gojo peut analyser : une créature, une plante, un mécanisme…
##
## Elle est sur le calque « analysable ». Le gant la détecte quand il la touche.
## Une fois la page de l'espèce complète, le gant y applique la clé à la place de l'analyse.

## Émis quand Gojo a appliqué la clé : c'est à la créature de réagir (se calmer, partir…).
signal cle_appliquee

## L'espèce dont la page se remplit quand on analyse cette zone.
@export var espece: Espece
## Faux une fois la clé appliquée : on ne calme pas deux fois la même créature.
var cle_disponible := true


func appliquer_cle() -> void:
	if not cle_disponible:
		return
	cle_disponible = false
	cle_appliquee.emit()

class_name Analysable
extends Area2D
## Une zone que le gant de Gojo peut analyser : une créature, une plante, un mécanisme…
##
## Elle est sur le calque « analysable ». Le gant la détecte quand il la touche.

## L'espèce dont la page se remplit quand on analyse cette zone.
@export var espece: Espece

class_name Interactif
extends Area2D
## Quelque chose avec quoi Gojo peut agir en s'approchant : parler, cueillir, ramasser, donner…
##
## Elle est sur le calque « interactif ». Quand Gojo est assez près, l'invite s'affiche
## en bas de l'écran (« E : cueillir ») ; sa touche déclenche le signal utilise.

signal utilise(gojo: Gojo)

## Ce qui s'affiche après la touche dans l'invite.
@export var verbe := "parler"
## La touche à montrer dans l'invite.
@export var touche := "E"
## Inactif, il n'apparaît plus dans l'invite.
@export var actif := true


func invite() -> String:
	return "%s : %s" % [touche, verbe]


func utiliser(gojo: Gojo) -> void:
	utilise.emit(gojo)

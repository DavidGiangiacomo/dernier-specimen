class_name Sacoche
extends Node
## La sacoche de Gojo : quatre cases pour les plantes, et rien d'autre.
## Pas d'inventaire général : la barre des quatre cases est visible en permanence.

signal changee

## Nombre de cases.
@export var cases := 4

var plantes: Array[EspecePlante] = []
## La case choisie : c'est cette plante que Gojo donne.
var choix := 0


func est_pleine() -> bool:
	return plantes.size() >= cases


func ajouter(plante: EspecePlante) -> bool:
	if est_pleine():
		return false
	plantes.append(plante)
	# La plante qu'on vient de cueillir devient la plante choisie.
	choix = plantes.size() - 1
	changee.emit()
	return true


func plante_choisie() -> EspecePlante:
	return plantes[choix] if choix < plantes.size() else null


func retirer_choisie() -> EspecePlante:
	var plante := plante_choisie()
	if plante:
		plantes.remove_at(choix)
		choix = clampi(choix, 0, maxi(plantes.size() - 1, 0))
		changee.emit()
	return plante


func choisir_suivante() -> void:
	if plantes.size() > 1:
		choix = (choix + 1) % plantes.size()
		changee.emit()

extends Node2D
## La barre circulaire au-dessus de Gojo : elle se remplit pendant l'analyse.

## Rayon du cercle, en pixels.
const RAYON := 5.0
## Épaisseur du trait, en pixels.
const EPAISSEUR := 2.0

@export var couleur_fond := Color(0.0, 0.0, 0.0, 0.5)
## Couleur de la partie remplie (Gojo la change : bleue pour une analyse, dorée pour une clé).
@export var couleur_remplie := Color("8fe3ff"):
	set(valeur):
		if valeur != couleur_remplie:
			couleur_remplie = valeur
			queue_redraw()

## De 0 (vide) à 1 (analyse réussie).
var progression := 0.0:
	set(valeur):
		valeur = clampf(valeur, 0.0, 1.0)
		if valeur != progression:
			progression = valeur
			queue_redraw()


func _draw() -> void:
	if progression <= 0.0:
		return
	draw_arc(Vector2.ZERO, RAYON, 0.0, TAU, 24, couleur_fond, EPAISSEUR)
	draw_arc(Vector2.ZERO, RAYON, -PI / 2.0, -PI / 2.0 + TAU * progression, 24, couleur_remplie, EPAISSEUR)

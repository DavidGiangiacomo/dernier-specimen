@tool
extends Node2D
## Terrain de test du jalon 0 : un damier de tuiles de 16 × 16 pixels, entouré de murs.
##
## Ce n'est pas un décor, seulement un repère pour sentir le déplacement.
## Il sera remplacé par la TileMap du Bois des Souches au jalon 4.

const TAILLE_TUILE := 16

@export var largeur_en_tuiles := 40:
	set(valeur):
		largeur_en_tuiles = maxi(valeur, 1)
		queue_redraw()
@export var hauteur_en_tuiles := 24:
	set(valeur):
		hauteur_en_tuiles = maxi(valeur, 1)
		queue_redraw()
@export var couleur_claire := Color("4f6346"):
	set(valeur):
		couleur_claire = valeur
		queue_redraw()
@export var couleur_foncee := Color("475a3f"):
	set(valeur):
		couleur_foncee = valeur
		queue_redraw()
@export var couleur_mur := Color("23291f"):
	set(valeur):
		couleur_mur = valeur
		queue_redraw()
## La caméra qui doit s'arrêter aux murs.
@export var camera: Camera2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_construire_murs()
	if camera:
		_limiter_camera()


func _draw() -> void:
	var interieur := _interieur()
	draw_rect(interieur.grow(TAILLE_TUILE), couleur_mur)
	for x in largeur_en_tuiles:
		for y in hauteur_en_tuiles:
			var couleur := couleur_claire if (x + y) % 2 == 0 else couleur_foncee
			draw_rect(Rect2(x * TAILLE_TUILE, y * TAILLE_TUILE, TAILLE_TUILE, TAILLE_TUILE), couleur)


func _interieur() -> Rect2:
	return Rect2(0, 0, largeur_en_tuiles * TAILLE_TUILE, hauteur_en_tuiles * TAILLE_TUILE)


func _construire_murs() -> void:
	var murs := StaticBody2D.new()
	murs.name = "Murs"
	add_child(murs)
	var interieur := _interieur()
	var t := TAILLE_TUILE
	var cotes := [
		Rect2(-t, -t, interieur.size.x + 2 * t, t),
		Rect2(-t, interieur.size.y, interieur.size.x + 2 * t, t),
		Rect2(-t, 0, t, interieur.size.y),
		Rect2(interieur.size.x, 0, t, interieur.size.y),
	]
	for cote: Rect2 in cotes:
		var forme := RectangleShape2D.new()
		forme.size = cote.size
		var collision := CollisionShape2D.new()
		collision.shape = forme
		collision.position = cote.get_center()
		murs.add_child(collision)


func _limiter_camera() -> void:
	var limites := _interieur().grow(TAILLE_TUILE)
	camera.limit_left = int(limites.position.x)
	camera.limit_top = int(limites.position.y)
	camera.limit_right = int(limites.end.x)
	camera.limit_bottom = int(limites.end.y)

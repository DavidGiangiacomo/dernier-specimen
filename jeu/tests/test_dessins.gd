extends "res://tests/base_de_test.gd"
## Vérifie que les dessins remplacent bien les rectangles provisoires :
## les huit images se chargent, le rectangle s'efface, la direction regardée
## choisit la bonne image, les pieds tombent au même endroit, et les couleurs
## d'état — qui sont des signaux de jeu — survivent au passage au dessin.

const PERSONNAGES := [
	{"scene": "res://gojo/gojo.tscn", "nom": "Gojo"},
	{"scene": "res://creatures/rase_mousse/rase_mousse.tscn", "nom": "Rase-mousse"},
]


func lancer() -> void:
	for p in PERSONNAGES:
		await un_personnage(p["scene"], p["nom"])
	await ancrage_de_gojo()
	await couleurs_d_etat()


## Pose la scène dans l'arbre et rend son nœud Dessin.
func _poser(chemin: String) -> Array:
	var scene: Node = load(chemin).instantiate()
	root.add_child(scene)
	await attendre(2)
	return [scene, scene.get_node_or_null("Dessin")]


func un_personnage(chemin: String, nom: String) -> void:
	section(nom)
	var paire := await _poser(chemin)
	var scene: Node = paire[0]
	var dessin = paire[1]
	verifier("le nœud Dessin existe", dessin != null)
	if dessin == null:
		scene.queue_free()
		return
	verifier("les huit images se sont chargées", dessin.visible)
	verifier("une image est affichée", dessin.texture != null)

	var provisoire: ColorRect = scene.get_node_or_null("Corps")
	verifier("le rectangle provisoire est masqué", provisoire != null and not provisoire.visible)

	# Chaque direction doit donner une image différente, et la bonne.
	var vues := {
		Vector2.DOWN: "_south.png", Vector2.RIGHT: "_east.png",
		Vector2.UP: "_north.png", Vector2.LEFT: "_west.png",
		Vector2(1, 1): "_south-east.png", Vector2(-1, -1): "_north-west.png",
	}
	var toutes := {}
	for direction in vues:
		dessin.regarder(direction)
		var chemin_image: String = dessin.texture.resource_path
		toutes[chemin_image] = true
		verifier("regard %s : %s" % [direction, vues[direction]],
			chemin_image.ends_with(vues[direction]), chemin_image.get_file())
	verifier("six directions, six images distinctes", toutes.size() == 6, "%d" % toutes.size())

	# Une direction nulle ne doit rien changer : à l'arrêt, on garde la dernière.
	dessin.regarder(Vector2.DOWN)
	var avant: Texture2D = dessin.texture
	dessin.regarder(Vector2.ZERO)
	verifier("à l'arrêt, le dessin ne change pas", dessin.texture == avant)
	scene.queue_free()
	await attendre(2)


func ancrage_de_gojo() -> void:
	section("Ancrage : les pieds au même endroit qu'avant")
	var paire := await _poser("res://gojo/gojo.tscn")
	var scene: Node = paire[0]
	var dessin = paire[1]
	dessin.regarder(Vector2.DOWN)
	var image: Image = dessin.texture.get_image()
	var bas := -1
	for y in range(image.get_height() - 1, -1, -1):
		for x in image.get_width():
			if image.get_pixel(x, y).a > 0.5:
				bas = y
				break
		if bas >= 0:
			break
	verifier("le dessin a des pixels opaques", bas >= 0, "dernière ligne : %d" % bas)
	# Le rectangle provisoire allait de offset_top à offset_bottom : son dernier
	# pixel dessiné est juste au-dessus de offset_bottom.
	var provisoire: ColorRect = scene.get_node("Corps")
	var attendu := provisoire.offset_bottom - 1.0
	var obtenu: float = dessin.offset.y + bas
	verifier("les pieds du dessin tombent où finissait le rectangle",
		is_equal_approx(obtenu, attendu), "dessin %.0f, rectangle %.0f" % [obtenu, attendu])
	scene.queue_free()
	await attendre(2)


func couleurs_d_etat() -> void:
	section("Les couleurs d'état deviennent des teintes")
	var paire := await _poser("res://gojo/gojo.tscn")
	var scene: Node = paire[0]
	var dessin = paire[1]

	dessin.teinter(dessin.couleur_de_reference)
	verifier("la couleur normale ne teinte pas le dessin",
		dessin.modulate.is_equal_approx(Color(1, 1, 1, dessin.modulate.a)),
		str(dessin.modulate))

	dessin.teinter(Color.WHITE)
	verifier("un coup reçu blanchit franchement, même les pixels sombres",
		dessin.modulate.r >= 2.0 and dessin.modulate.g >= 2.0 and dessin.modulate.b >= 2.0,
		str(dessin.modulate))

	# Une couleur plus rouge que la référence doit rougir le dessin.
	var rouge := Color(dessin.couleur_de_reference.r, dessin.couleur_de_reference.g * 0.5,
		dessin.couleur_de_reference.b * 0.5)
	dessin.teinter(rouge)
	verifier("une couleur d'alerte rougit le dessin",
		dessin.modulate.r > dessin.modulate.g and dessin.modulate.r > dessin.modulate.b,
		str(dessin.modulate))

	# L'opacité, elle, ne doit pas être écrasée par une teinte : c'est le
	# clignotement d'invincibilité.
	dessin.modulate.a = 0.25
	dessin.teinter(dessin.couleur_de_reference)
	verifier("teinter ne perd pas l'opacité du clignotement",
		is_equal_approx(dessin.modulate.a, 0.25), "%.2f" % dessin.modulate.a)
	scene.queue_free()
	await attendre(2)

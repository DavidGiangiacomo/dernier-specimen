extends "res://tests/base_de_test.gd"
## Vérifie que les dessins remplacent bien les rectangles provisoires :
## les huit images se chargent, le rectangle s'efface, la direction regardée
## choisit la bonne image, les pieds tombent au même endroit, et les couleurs
## d'état — qui sont des signaux de jeu — survivent au passage au dessin.

const PERSONNAGES := [
	{"scene": "res://gojo/gojo.tscn", "nom": "Gojo"},
	{"scene": "res://creatures/rase_mousse/rase_mousse.tscn", "nom": "Rase-mousse"},
	{"scene": "res://creatures/hure/hure.tscn", "nom": "Hure"},
	{"scene": "res://creatures/garin/garin.tscn", "nom": "Garin"},
	{"scene": "res://creatures/gobelin/gobelin.tscn", "nom": "Gobelin"},
]

## Les états qui ont leur propre jeu de dessins, et comment les reconnaître.
const ETATS := [
	{"scene": "res://creatures/hure/hure.tscn", "nom": "Hure apaisée", "etat": "apaisee"},
	{"scene": "res://creatures/garin/garin.tscn", "nom": "Garin à terre", "etat": "a_terre"},
	{"scene": "res://creatures/gobelin/gobelin.tscn", "nom": "Gobelin couché", "etat": "malade"},
	{"scene": "res://creatures/gobelin/gobelin.tscn", "nom": "Gobelin taché", "etat": "malade_taches"},
	{"scene": "res://creatures/gobelin/gobelin.tscn", "nom": "Bébé gobelin", "etat": "bebe"},
]


func lancer() -> void:
	for p in PERSONNAGES:
		await un_personnage(p["scene"], p["nom"])
	for e in ETATS:
		await un_etat(e["scene"], e["nom"], e["etat"])
	await les_plantes()
	await teinte_selon_l_etat()
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


## Un état a son propre jeu de huit dessins : basculer dessus doit changer
## l'image, et revenir doit la rendre.
func un_etat(chemin: String, nom: String, nom_etat: String) -> void:
	section(nom)
	var paire := await _poser(chemin)
	var scene: Node = paire[0]
	var dessin = paire[1]
	if dessin == null or not dessin.visible:
		verifier("le dessin est là", false)
		scene.queue_free()
		return

	dessin.regarder(Vector2.DOWN)
	var normal: String = dessin.texture.resource_path
	dessin.etat(nom_etat)
	var special: String = dessin.texture.resource_path
	verifier("l'état « %s » a son propre dessin" % nom_etat,
		special != normal and special.contains("_%s_" % nom_etat), special.get_file())

	# Changer de direction doit rester dans l'état.
	dessin.regarder(Vector2.RIGHT)
	verifier("on tourne sans quitter l'état",
		dessin.texture.resource_path.contains("_%s_" % nom_etat),
		dessin.texture.resource_path.get_file())

	dessin.etat("")
	dessin.regarder(Vector2.DOWN)
	verifier("revenir à l'état normal rend le dessin normal",
		dessin.texture.resource_path == normal, dessin.texture.resource_path.get_file())

	# Un état qu'on n'a pas dessiné ne doit rien casser : mieux vaut le
	# mauvais dessin que pas de dessin du tout.
	dessin.etat("etat_qui_n_existe_pas")
	verifier("un état sans dessins ne change rien",
		dessin.texture.resource_path == normal, dessin.texture.resource_path.get_file())
	scene.queue_free()
	await attendre(2)


## La règle de teinte n'est pas la même pour tous les états, et c'est voulu.
## La hure apaisée ne se teinte plus : son dessin dit déjà tout, et sa couleur
## d'état le délavait. Le gobelin malade, lui, doit encore se teinter : la
## fièvre est un second symptôme, qui se cumule avec les taches.
func teinte_selon_l_etat() -> void:
	section("Teinte : seulement là où elle ajoute quelque chose")
	for cas in [{"scene": "res://creatures/hure/hure.tscn", "nom": "hure apaisée",
				 "etat": "apaisee", "teinte_attendue": false},
				{"scene": "res://creatures/gobelin/gobelin.tscn", "nom": "gobelin malade",
				 "etat": "malade", "teinte_attendue": true}]:
		var paire := await _poser(cas["scene"])
		var scene: Node = paire[0]
		var dessin = paire[1]
		dessin.etat(cas["etat"])
		# Une couleur franchement différente de la référence.
		var autre := Color(dessin.couleur_de_reference.r, dessin.couleur_de_reference.g * 0.5,
			dessin.couleur_de_reference.b * 0.5)
		dessin.teinter(autre)
		var teinte: bool = not dessin.modulate.is_equal_approx(Color(1, 1, 1, dessin.modulate.a))
		verifier("%s : teintée = %s" % [cas["nom"], cas["teinte_attendue"]],
			teinte == cas["teinte_attendue"], str(dessin.modulate))
		# L'éclat d'un coup reçu doit passer dans les deux cas.
		dessin.teinter(Color.WHITE)
		verifier("%s : l'éclat d'un coup passe quand même" % cas["nom"],
			dessin.modulate.r >= 2.0, str(dessin.modulate))
		scene.queue_free()
		await attendre(2)


## Les plantes changent de dessin une fois analysées — « une fois son espèce
## dans l'herbier, Gojo voit la différence ». Et surtout : avant analyse, la
## mousse-de-lune et la ronce-rouge doivent être INDISCERNABLES. C'est l'énigme
## des malades : l'une soigne, l'autre empoisonne, et rien ne les distingue
## tant qu'on n'a pas pris le temps d'analyser.
func les_plantes() -> void:
	section("Les plantes : avant et après l'herbier")
	root.get_node("Carnet").effacer()
	var scene_plante := load("res://plantes/plante.tscn")
	var avant := {}
	var apres := {}
	for nom in ["mousse_de_lune", "ronce_rouge", "capuchon_gris", "fleur_trompette"]:
		var plante: Node2D = scene_plante.instantiate()
		plante.espece = load("res://plantes/%s.tres" % nom)
		root.add_child(plante)
		await attendre(2)
		var dessin: Sprite2D = plante.get_node_or_null("Dessin")
		if dessin == null or not dessin.visible:
			verifier("%s : le dessin est là" % nom, false)
			plante.queue_free()
			continue
		var visuel: ColorRect = plante.get_node("Visuel")
		verifier("%s : le rectangle provisoire est masqué" % nom, not visuel.visible)
		# On garde les PIXELS, pas le chemin : ce qui compte est ce que le
		# joueur voit. Deux fichiers distincts au contenu identique sont
		# indiscernables pour lui, et c'est tout ce qui est demandé.
		avant[nom] = dessin.texture.get_image().get_data()
		verifier("%s : avant analyse, le dessin apparent" % nom,
			dessin.texture.resource_path.ends_with("_apparent.png"),
			dessin.texture.resource_path.get_file())

		# On remplit sa page : une seule analyse suffit pour une plante.
		var carnet = root.get_node("Carnet")
		for i in 5:
			if carnet.est_complete(plante.espece):
				break
			carnet.ajouter_analyse(plante.espece)
		await attendre(2)
		apres[nom] = dessin.texture.get_image().get_data()
		verifier("%s : une fois connue, le dessin change" % nom,
			apres[nom] != avant[nom] and not dessin.texture.resource_path.ends_with("_apparent.png"),
			dessin.texture.resource_path.get_file())
		plante.queue_free()
		await attendre(2)
		carnet.effacer()

	verifier("mousse-de-lune et ronce-rouge : mêmes pixels avant analyse",
		avant.has("mousse_de_lune") and avant["mousse_de_lune"] == avant.get("ronce_rouge"))
	verifier("et des pixels différents une fois analysées",
		apres.has("mousse_de_lune") and apres["mousse_de_lune"] != apres.get("ronce_rouge"))

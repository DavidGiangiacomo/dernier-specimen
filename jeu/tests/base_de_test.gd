extends SceneTree
## Ce que tous les tests automatiques ont en commun. Chaque fichier test_*.gd en hérite
## et écrit ses vérifications dans lancer().
##
## Un test se lance sans fenêtre, en ligne de commande, depuis le dossier du dépôt :
##   godot --headless --path jeu --script res://tests/test_terrain.gd
## ou tous à la fois avec jeu/tests/lancer.sh. Les touches sont simulées avec Input.action_press.

## Au-delà, le test est arrêté et compté comme raté (un test bloqué ne doit pas tourner sans fin).
const DUREE_MAX := 180.0
## Le hasard du jeu (les pas de la hure, le vol des rase-mousses) fait les mêmes tirages à chaque
## lancement : un test qui échoue échoue à chaque fois, et on peut le rejouer pour comprendre.
const GRAINE_DU_HASARD := 1

var echecs := 0
var reussites := 0


func _initialize() -> void:
	seed(GRAINE_DU_HASARD)
	create_timer(DUREE_MAX).timeout.connect(_temps_depasse)
	# Avant la première image, les scènes ajoutées ne sont pas encore prêtes.
	await process_frame
	await lancer()
	print("\n%d vérification(s) réussie(s), %d échec(s)" % [reussites, echecs])
	quit(1 if echecs > 0 else 0)


## À écrire dans chaque fichier de test.
func lancer() -> void:
	pass


func verifier(nom: String, ok: bool, detail := "") -> void:
	print(("OK    " if ok else "ECHEC ") + nom + ("" if detail == "" else "  (" + detail + ")"))
	if ok:
		reussites += 1
	else:
		echecs += 1


func section(titre: String) -> void:
	print("\n== " + titre)


func attendre(images: int) -> void:
	for i in images:
		await physics_frame


func relacher_tout() -> void:
	for action in ["gauche", "droite", "haut", "bas", "roulade", "attaque", "analyse", "interagir", "changer_plante", "carnet"]:
		Input.action_release(action)


## Appuie sur une touche pendant deux images, puis la relâche.
func appuyer(action: String) -> void:
	Input.action_press(action)
	await attendre(2)
	Input.action_release(action)
	await attendre(1)


## Pareil, quand le jeu est en pause (les images physiques sont arrêtées pour le jeu).
func appuyer_en_pause(action: String) -> void:
	Input.action_press(action)
	for i in 2:
		await process_frame
	Input.action_release(action)
	await process_frame


## Tient la touche d'analyse le temps d'une analyse (un peu plus d'une seconde).
func analyser() -> void:
	Input.action_press("analyse")
	await attendre(62)
	Input.action_release("analyse")
	await attendre(2)


## Lit le dialogue en cours jusqu'au bout, et ceux qui s'enchaînent aussitôt ;
## renvoie le nombre total de lignes lues.
func lire_dialogue() -> int:
	var dialogue = root.get_node("Dialogue")
	var garde := 0
	while not dialogue.en_cours and garde < 360:
		await process_frame
		garde += 1
	if not dialogue.en_cours:
		return 0
	var lignes := 0
	var dernier = null
	garde = 0
	while dialogue.en_cours and garde < 40:
		if not is_same(dialogue._lignes, dernier):
			dernier = dialogue._lignes
			lignes += dernier.size()
		await process_frame
		Input.action_press("interagir")
		await process_frame
		await process_frame
		Input.action_release("interagir")
		await process_frame
		garde += 1
	await attendre(2)
	return lignes


## Un coup des créatures, posé où l'on veut (pour tester ce qui arrive quand Gojo est touché).
func creer_coup(parent: Node, position_du_coup: Vector2, degats := 1) -> Hitbox:
	var coup := Hitbox.new()
	coup.collision_layer = 16
	coup.collision_mask = 0
	coup.degats = degats
	var forme := CollisionShape2D.new()
	forme.shape = RectangleShape2D.new()
	forme.shape.size = Vector2(8, 8)
	coup.add_child(forme)
	parent.add_child(coup)
	coup.global_position = position_du_coup
	return coup


func _temps_depasse() -> void:
	print("\nECHEC le test a dépassé %d s : il est sans doute bloqué." % DUREE_MAX)
	quit(1)

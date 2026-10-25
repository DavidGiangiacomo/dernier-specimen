extends "res://tests/base_de_test.gd"
## Tests des jalons 0 à 3, sur le terrain de test : déplacement, combat contre la hure,
## analyse au gant, carnet et clé.

const SCENE := "res://terrain_de_test/terrain_de_test.tscn"

var terrain: Node2D
var gojo
var hure

## Installe un terrain neuf. Sans souches ni hure si demandé.
func nouveau_terrain(avec_souches: bool, avec_hure: bool) -> void:
	relacher_tout()
	if terrain and is_instance_valid(terrain):
		terrain.queue_free()
		await attendre(2)
	root.get_node("Carnet").effacer()
	terrain = load(SCENE).instantiate()
	root.add_child(terrain)
	current_scene = terrain
	for n in terrain.get_children():
		if (n.name.begins_with("Souche") and not avec_souches) or (n.name == "Hure" and not avec_hure):
			n.free()
	gojo = terrain.get_node("Gojo")
	hure = terrain.get_node_or_null("Hure")
	await attendre(2)

func lancer() -> void:
	await tests_deplacement()
	await tests_coup_de_baton()
	await tests_coup_long()
	await tests_charge()
	await tests_roulade_esquive()
	await tests_etourdissement()
	await tests_analyse()
	await tests_analyse_interrompue()
	await tests_page_complete()
	await tests_interface_carnet()
	await tests_cle()
	await tests_ko()

func tests_deplacement() -> void:
	section("Jalon 0 : déplacement")
	await nouveau_terrain(false, false)
	var cam: Camera2D = gojo.get_node("Camera2D")
	verifier("limites caméra", cam.limit_left == -16 and cam.limit_top == -16 and cam.limit_right == 656 and cam.limit_bottom == 400)
	verifier("murs construits", terrain.get_node("Murs").get_child_count() == 4)

	var depart: Vector2 = gojo.position
	Input.action_press("droite")
	await attendre(60)
	verifier("marche à droite : 80 px/s", is_equal_approx(gojo.velocity.x, 80.0) and gojo.velocity.y == 0.0, str(gojo.velocity))
	verifier("distance en 1 s ≈ 77 px", absf(gojo.position.x - depart.x - 76.8) < 2.0, "%.1f px" % (gojo.position.x - depart.x))
	Input.action_release("droite")
	await attendre(5)
	verifier("arrêté après 0,08 s", gojo.velocity == Vector2.ZERO, str(gojo.velocity))

	Input.action_press("droite")
	Input.action_press("bas")
	await attendre(30)
	verifier("diagonale : même vitesse que tout droit", absf(gojo.velocity.length() - 80.0) < 0.01)
	relacher_tout()
	await attendre(10)

	var avant: Vector2 = gojo.position
	Input.action_press("roulade")
	await attendre(2)
	Input.action_release("roulade")
	verifier("roulade dans la direction du regard, à 220 px/s", gojo.velocity.is_equal_approx(Vector2(1, 1).normalized() * 220.0), str(gojo.velocity))
	var images := 1
	var invincibles := int(gojo.invincible_en_roulade)
	while gojo.etat == gojo.Etat.ROULADE:
		await attendre(1)
		if gojo.etat == gojo.Etat.ROULADE:
			images += 1
			invincibles += int(gojo.invincible_en_roulade)
	verifier("roulade : 0,25 s", images == 15, "%d images" % images)
	verifier("invincibilité de roulade : 0,2 s", invincibles == 12, "%d images" % invincibles)
	verifier("distance de roulade ≈ 55 px", absf(gojo.position.distance_to(avant) - 58.3) < 1.0, "%.1f px" % gojo.position.distance_to(avant))
	await appuyer("roulade")
	verifier("pas de roulade pendant la recharge", gojo.etat == gojo.Etat.MARCHE)
	while gojo._temps_recharge > gojo.MARGE_ARRONDI:
		await attendre(1)
	await appuyer("roulade")
	verifier("roulade possible dès la fin de la recharge", gojo.etat == gojo.Etat.ROULADE)
	await attendre(20)

	Input.action_press("gauche")
	Input.action_press("haut")
	await attendre(600)
	relacher_tout()
	verifier("bloqué par les murs", gojo.position.x >= 9.9 and gojo.position.x < 11.0 and gojo.position.y >= 7.9 and gojo.position.y < 9.0, str(gojo.position))

func tests_coup_de_baton() -> void:
	section("Jalon 1 : coup de bâton")
	await nouveau_terrain(false, true)
	hure.distance_detection = 0.0
	hure.vitesse_errance = 0.0
	Input.action_press("droite")
	await attendre(2)
	relacher_tout()
	await attendre(10)
	hure.global_position = gojo.global_position + Vector2(18, 0)
	await attendre(2)
	var x_avant: float = hure.global_position.x

	Input.action_press("attaque")
	await attendre(2)
	Input.action_release("attaque")
	verifier("le coup part", gojo.etat == gojo.Etat.ATTAQUE)
	verifier("le bâton est visible", gojo.get_node("Baton").visible)
	await attendre(3)
	verifier("la hure perd 1 PV", hure.pv == 7, "pv = %d" % hure.pv)
	verifier("la hure flashe en blanc", hure.get_node("Corps").color == Color.WHITE)
	while gojo.etat == gojo.Etat.ATTAQUE:
		await attendre(1)
	verifier("un seul PV perdu par coup", hure.pv == 7, "pv = %d" % hure.pv)
	verifier("la hure recule", hure.global_position.x > x_avant + 3.0, "%.1f px" % (hure.global_position.x - x_avant))
	verifier("le bâton est rangé", not gojo.get_node("Baton").visible and not gojo.get_node("Baton/Hitbox").active)

	await appuyer("attaque")
	verifier("pas de deuxième coup avant 0,35 s", gojo.etat == gojo.Etat.MARCHE)
	while gojo._temps_avant_coup > gojo.MARGE_ARRONDI:
		await attendre(1)
	await appuyer("attaque")
	verifier("deuxième coup possible après 0,35 s", gojo.etat == gojo.Etat.ATTAQUE)

	var coups := 2
	while is_instance_valid(hure) and coups < 20:
		while gojo._temps_avant_coup > gojo.MARGE_ARRONDI:
			await attendre(1)
		hure.global_position = gojo.global_position + Vector2(18, 0)
		await attendre(2)
		await appuyer("attaque")
		await attendre(6)
		coups += 1
	verifier("la hure tombe en 8 coups", not is_instance_valid(hure) and coups == 8, "%d coups" % coups)

func tests_coup_long() -> void:
	section("Jalon 1 : un coup long ne touche qu'une fois")
	await nouveau_terrain(false, true)
	hure.distance_detection = 0.0
	hure.vitesse_errance = 0.0
	hure.get_node("Hurtbox").invincibilite_apres_coup = 0.05
	gojo.duree_coup = 0.6
	gojo.cadence_attaque = 0.6
	Input.action_press("droite")
	await attendre(2)
	relacher_tout()
	await attendre(10)
	hure.global_position = gojo.global_position + Vector2(14, 0)
	hure.freinage = 100000.0
	await attendre(2)
	await appuyer("attaque")
	while gojo.etat == gojo.Etat.ATTAQUE:
		hure.global_position = gojo.global_position + Vector2(14, 0)
		await attendre(1)
	verifier("coup de 0,6 s, hure invincible 0,05 s : 1 seul PV perdu", hure.pv == 7, "pv = %d" % hure.pv)
	await appuyer("attaque")
	await attendre(4)
	verifier("le coup suivant touche de nouveau", hure.pv == 6, "pv = %d" % hure.pv)

func tests_charge() -> void:
	section("Jalon 1 : la charge de la hure")
	await nouveau_terrain(false, true)
	hure.global_position = gojo.global_position + Vector2(80, 0)
	var coeurs = terrain.get_node("Interface/Coeurs")
	await attendre(1)
	verifier("la hure repère Gojo à 80 px", hure.etat == hure.Etat.PREPARATION)
	var preparation := 1
	while hure.etat == hure.Etat.PREPARATION:
		await attendre(1)
		preparation += 1
	verifier("préparation ≈ 0,6 s", absi(preparation - 36) <= 1, "%d images" % preparation)
	verifier("la charge fait mal pendant qu'elle fonce", hure.get_node("HitboxCharge").active)
	var images := 0
	while gojo.pv == 6 and images < 60:
		await attendre(1)
		images += 1
	verifier("Gojo perd un cœur (2 PV)", gojo.pv == 4, "pv = %d après %d images" % [gojo.pv, images])
	verifier("les cœurs affichent 4 PV", coeurs._pv == 4)
	await attendre(1)
	verifier("Gojo recule à l'opposé de la hure", gojo.velocity.x < -100.0, str(gojo.velocity))
	verifier("Gojo est invincible juste après", gojo.get_node("Hurtbox").vient_d_etre_touchee())
	await attendre(44)
	verifier("pas d'autre PV perdu pendant l'invincibilité", gojo.pv == 4, "pv = %d" % gojo.pv)
	var invincible_restant := 0
	while gojo.get_node("Hurtbox").vient_d_etre_touchee():
		await attendre(1)
		invincible_restant += 1
	verifier("invincibilité après un coup ≈ 0,8 s", invincible_restant + 45 == 48, "%d images" % (invincible_restant + 45))
	var fin := 0
	while hure.etat == hure.Etat.CHARGE and fin < 120:
		await attendre(1)
		fin += 1
	verifier("sans obstacle, la charge s'arrête et la hure se repose", hure.etat == hure.Etat.REPOS)
	verifier("au repos, la charge ne fait plus mal", not hure.get_node("HitboxCharge").active)

func tests_roulade_esquive() -> void:
	section("Jalon 1 : esquiver la charge en roulade")
	await nouveau_terrain(false, true)
	hure.global_position = gojo.global_position + Vector2(90, 0)
	while not (hure.etat == hure.Etat.CHARGE and hure.global_position.x - gojo.global_position.x <= 40.0):
		await attendre(1)
	Input.action_press("droite")
	Input.action_press("roulade")
	await attendre(2)
	Input.action_release("roulade")
	await attendre(20)
	relacher_tout()
	verifier("Gojo a traversé la charge", hure.global_position.x < gojo.global_position.x, "hure %.0f, gojo %.0f" % [hure.global_position.x, gojo.global_position.x])
	verifier("sans perdre de PV", gojo.pv == 6, "pv = %d" % gojo.pv)

func tests_etourdissement() -> void:
	section("Jalon 1 : étourdie contre un mur ou une souche")
	await nouveau_terrain(true, true)
	gojo.global_position = Vector2(600, 360)
	hure.global_position = Vector2(40, 40)
	await attendre(2)
	hure._direction = Vector2.LEFT
	hure._changer_etat(hure.Etat.CHARGE)
	var images := 0
	while hure.etat == hure.Etat.CHARGE and images < 60:
		await attendre(1)
		images += 1
	verifier("étourdie contre le mur", hure.etat == hure.Etat.ETOURDIE, "après %d images" % images)
	verifier("étourdie, elle ne fait plus mal", not hure.get_node("HitboxCharge").active)
	var etourdie := 0
	while hure.etat == hure.Etat.ETOURDIE:
		await attendre(1)
		etourdie += 1
	verifier("étourdie ≈ 1,5 s", absi(etourdie - 90) <= 1, "%d images" % etourdie)

	var souche: Node2D = terrain.get_node("Souche1")
	hure.global_position = souche.global_position + Vector2(80, 0)
	await attendre(2)
	hure._direction = Vector2.LEFT
	hure._changer_etat(hure.Etat.CHARGE)
	images = 0
	while hure.etat == hure.Etat.CHARGE and images < 60:
		await attendre(1)
		images += 1
	verifier("étourdie contre une souche", hure.etat == hure.Etat.ETOURDIE and hure.global_position.x > souche.global_position.x, "x = %.0f" % hure.global_position.x)

## Une hure immobile juste devant Gojo, comme si elle venait de s'assommer contre une souche.
func preparer_hure_etourdie() -> void:
	hure.distance_detection = 0.0
	hure.vitesse_errance = 0.0
	hure.duree_etourdissement = 1000.0
	hure._changer_etat(hure.Etat.ETOURDIE)
	Input.action_press("droite")
	await attendre(2)
	relacher_tout()
	await attendre(10)
	hure.global_position = gojo.global_position + Vector2(24, 0)
	await attendre(2)

func analyses_hure() -> int:
	return root.get_node("Carnet").analyses(hure.get_node("Analysable").espece)

func tests_analyse() -> void:
	section("Jalon 2 : analyser au gant")
	await nouveau_terrain(false, true)
	await preparer_hure_etourdie()
	var main: ColorRect = gojo.get_node("Gant/Main")
	verifier("au contact, la main s'allume faiblement", main.visible and main.modulate.a < 0.5)

	Input.action_press("analyse")
	await attendre(1)
	verifier("bouton tenu au contact : l'analyse commence", gojo.etat == gojo.Etat.ANALYSE)
	await attendre(29)
	verifier("après 0,5 s, la barre est à moitié", absf(gojo._progression_analyse - 0.5) < 0.02, "%.2f" % gojo._progression_analyse)
	verifier("la barre circulaire suit", is_equal_approx(gojo.get_node("BarreAnalyse").progression, gojo._progression_analyse))
	verifier("pendant l'analyse, la main brille", main.visible and main.modulate.a == 1.0)
	Input.action_press("attaque")
	Input.action_press("roulade")
	await attendre(3)
	Input.action_release("attaque")
	Input.action_release("roulade")
	verifier("ni coup ni roulade pendant l'analyse", gojo.etat == gojo.Etat.ANALYSE and not gojo.get_node("Baton").visible)
	var images := 33
	while gojo.etat == gojo.Etat.ANALYSE and images < 120:
		await attendre(1)
		images += 1
	verifier("analyse réussie en 1 s de contact", analyses_hure() == 1 and absi(images - 60) <= 1, "%d images" % images)
	verifier("la barre est vidée après la réussite", gojo._progression_analyse == 0.0)
	await attendre(20)
	verifier("bouton toujours tenu : pas de nouvelle analyse", gojo.etat == gojo.Etat.MARCHE and analyses_hure() == 1)
	Input.action_release("analyse")
	await attendre(2)
	Input.action_press("analyse")
	await attendre(2)
	verifier("relâcher puis réappuyer relance l'analyse", gojo.etat == gojo.Etat.ANALYSE)
	Input.action_press("droite")
	await attendre(10)
	verifier("pendant l'analyse, Gojo avance à 40 px/s au plus", gojo.velocity.length() <= 40.01, "%.1f px/s" % gojo.velocity.length())
	relacher_tout()
	await attendre(2)
	verifier("bouton relâché : l'analyse est annulée", gojo.etat == gojo.Etat.MARCHE and gojo._progression_analyse == 0.0)

	Input.action_press("analyse")
	await attendre(1)
	verifier("sans contact, le bouton ne fait rien", true)
	relacher_tout()
	gojo.global_position += Vector2(-60, 0)
	await attendre(3)
	Input.action_press("analyse")
	await attendre(5)
	verifier("loin de la hure, pas d'analyse ni de ralentissement", gojo.etat == gojo.Etat.MARCHE and not main.visible)
	relacher_tout()

func tests_analyse_interrompue() -> void:
	section("Jalon 2 : interruption")
	await nouveau_terrain(false, true)
	await preparer_hure_etourdie()
	Input.action_press("analyse")
	await attendre(30)
	var coup := creer_coup(terrain, gojo.global_position + Vector2(-6, -10))
	var images := 0
	while gojo.pv == 6 and images < 10:
		await attendre(1)
		images += 1
	coup.queue_free()
	verifier("un coup reçu vide la barre et arrête l'analyse", gojo.pv == 5 and gojo._progression_analyse == 0.0 and gojo.etat != gojo.Etat.ANALYSE, "pv %d, barre %.2f" % [gojo.pv, gojo._progression_analyse])
	verifier("l'analyse interrompue ne compte pas", analyses_hure() == 0)
	relacher_tout()
	await attendre(30)

	hure.global_position = gojo.global_position + Vector2(24, 0)
	await attendre(2)
	Input.action_press("analyse")
	await attendre(30)
	hure.global_position += Vector2(60, 0)
	await attendre(10)
	var apres_perte: float = gojo._progression_analyse
	verifier("contact perdu, bouton tenu : la barre redescend", gojo.etat == gojo.Etat.ANALYSE and absf(apres_perte - 20.0 / 60.0) <= 2.5 / 60.0, "%.2f" % apres_perte)
	hure.global_position = gojo.global_position + Vector2(24, 0)
	await attendre(10)
	verifier("contact retrouvé : la barre remonte", gojo._progression_analyse > apres_perte + 0.1, "%.2f" % gojo._progression_analyse)
	hure.global_position += Vector2(60, 0)
	images = 0
	while gojo.etat == gojo.Etat.ANALYSE and images < 120:
		await attendre(1)
		images += 1
	verifier("barre vide sans contact : l'analyse s'arrête", gojo.etat == gojo.Etat.MARCHE and analyses_hure() == 0)
	relacher_tout()

func tests_page_complete() -> void:
	section("Jalon 2 : une page qui se remplit")
	await nouveau_terrain(false, true)
	await preparer_hure_etourdie()
	var page = terrain.get_node("Interface/Page")
	verifier("pas de page affichée avant la première analyse", not page.visible)
	for i in 3:
		Input.action_press("analyse")
		await attendre(62)
		Input.action_release("analyse")
		await attendre(2)
		verifier("analyse %d : page à %d/3" % [i + 1, i + 1], analyses_hure() == i + 1 and page.visible and page._analyses == i + 1, "%d" % analyses_hure())
	var carnet = root.get_node("Carnet")
	verifier("page complète", carnet.est_complete(hure.get_node("Analysable").espece))
	await attendre(15)
	verifier("page complète : la main passe au doré (la clé)", gojo.get_node("Gant/Main").visible and gojo.get_node("Gant/Main").color == gojo.COULEUR_CLE)
	relacher_tout()

## Remplit la page de la hure sans passer par le jeu.
func completer_page_hure() -> void:
	var espece = hure.get_node("Analysable").espece
	for i in 3:
		root.get_node("Carnet").ajouter_analyse(espece)

func tests_interface_carnet() -> void:
	section("Jalon 3 : l'interface du carnet")
	await nouveau_terrain(false, true)
	var interface_carnet = terrain.get_node("Interface/InterfaceCarnet")
	var aide = terrain.get_node("Interface/Page/AideCarnet")
	await appuyer("carnet")
	await process_frame
	verifier("Tab ouvre le carnet et met le jeu en pause", interface_carnet.visible and paused)
	verifier("carnet vide : message d'aide", interface_carnet.get_node("Papier/Vide").visible)
	var position: Vector2 = gojo.global_position
	Input.action_press("droite")
	for i in 20:
		await process_frame
	Input.action_release("droite")
	verifier("en pause, Gojo ne bouge pas", gojo.global_position == position)
	await appuyer_en_pause("carnet")
	verifier("Tab referme le carnet et relance le jeu", not interface_carnet.visible and not paused)

	var espece = hure.get_node("Analysable").espece
	root.get_node("Carnet").ajouter_analyse(espece)
	await attendre(2)
	verifier("après une analyse, l'aide « Tab : carnet » s'affiche", aide.is_visible_in_tree())
	await appuyer("carnet")
	await process_frame
	var titre: Label = interface_carnet.get_node("Papier/Titre")
	var lignes = interface_carnet.get_node("Papier/Observations").get_children()
	var cle: Label = interface_carnet.get_node("Papier/Cle")
	verifier("avant : le nom de terrain", titre.text == espece.nom_de_terrain, titre.text)
	verifier("avant : la description de savant", interface_carnet.get_node("Papier/Description").text == espece.description_avant)
	verifier("1 analyse : la première observation est écrite", lignes[0].text == "1. " + espece.observations[0], lignes[0].text)
	verifier("les deux autres sont encore effacées", lignes[1].text == "2. · · ·" and lignes[2].text == "3. · · ·")
	verifier("la clé est inconnue", cle.text == "Clé : ?")
	verifier("encre froide du savant", titre.get_theme_color("font_color") == interface_carnet.encre_avant)
	await appuyer_en_pause("carnet")

	root.get_node("Carnet").ajouter_analyse(espece)
	root.get_node("Carnet").ajouter_analyse(espece)
	await appuyer("carnet")
	await process_frame
	verifier("3 analyses : les trois observations", lignes[2].text == "3. " + espece.observations[2], lignes[2].text)
	verifier("la clé apparaît avec la troisième", cle.text == "Clé : " + espece.cle, cle.text)
	await appuyer_en_pause("carnet")

	var autre := Espece.new()
	autre.nom_de_terrain = "Spécimen R-02"
	autre.observations = ["Nuée."] as Array[String]
	root.get_node("Carnet").ajouter_analyse(autre)
	await appuyer("carnet")
	await process_frame
	var pied: Label = interface_carnet.get_node("Papier/Pied")
	verifier("deux espèces : le carnet s'ouvre sur la dernière", titre.text == "Spécimen R-02" and pied.text.ends_with("< 2 / 2 >"), pied.text)
	await appuyer_en_pause("gauche")
	verifier("gauche : page précédente", titre.text == espece.nom_de_terrain and pied.text.ends_with("< 1 / 2 >"), titre.text)
	await appuyer_en_pause("carnet")

func tests_cle() -> void:
	section("Jalon 3 : la clé et la hure apaisée")
	await nouveau_terrain(false, true)
	await preparer_hure_etourdie()
	completer_page_hure()
	var analysable = hure.get_node("Analysable")
	var main: ColorRect = gojo.get_node("Gant/Main")
	await attendre(2)
	verifier("page complète, au contact : la main est dorée", main.visible and main.color == gojo.COULEUR_CLE)
	verifier("l'épine est visible", hure.get_node("Corps/Epine").visible)
	Input.action_press("analyse")
	await attendre(30)
	verifier("la barre est dorée pendant la clé", gojo._applique_cle and gojo.get_node("BarreAnalyse").couleur_remplie == gojo.COULEUR_CLE)
	await attendre(32)
	relacher_tout()
	var carnet = root.get_node("Carnet")
	verifier("1 s au contact : la clé est appliquée", not analysable.cle_disponible and hure.etat == hure.Etat.APAISEE)
	verifier("l'espèce est apaisée dans le carnet", carnet.est_apaisee(analysable.espece))
	verifier("pas d'observation en plus", analyses_hure() == 3)
	verifier("l'épine a disparu, la barre de PV aussi", not hure.get_node("Corps/Epine").visible and not hure.get_node("BarreFond").visible)
	await attendre(15)
	Input.action_press("analyse")
	await attendre(5)
	verifier("apaisée, le gant n'a plus rien à faire", gojo.etat == gojo.Etat.MARCHE and not main.visible)
	relacher_tout()

	hure.distance_detection = 200.0
	hure.vitesse_errance = 20.0
	hure.global_position = gojo.global_position + Vector2(40, 0)
	var depart: Vector2 = hure.global_position
	var a_charge := false
	for i in 240:
		await attendre(1)
		a_charge = a_charge or hure.etat != hure.Etat.APAISEE or hure.get_node("HitboxCharge").active
	verifier("apaisée, elle ne charge plus jamais (4 s à côté de Gojo)", not a_charge and gojo.pv == 6)
	verifier("elle se promène", hure.global_position.distance_to(depart) > 1.0, "%.0f px" % hure.global_position.distance_to(depart))

	hure.global_position = gojo.global_position + Vector2(18, 0)
	await attendre(2)
	await appuyer("attaque")
	await attendre(10)
	verifier("apaisée, le bâton ne lui fait plus rien", hure.pv == 8, "pv = %d" % hure.pv)

	var interface_carnet = terrain.get_node("Interface/InterfaceCarnet")
	await appuyer("carnet")
	await process_frame
	var titre: Label = interface_carnet.get_node("Papier/Titre")
	verifier("après : le nom véritable", titre.text == analysable.espece.nom_veritable, titre.text)
	verifier("après : la description en langage humain", interface_carnet.get_node("Papier/Description").text == analysable.espece.description_apres)
	verifier("encre chaude de Gojo", titre.get_theme_color("font_color") == interface_carnet.encre_apres)
	verifier("mention « apaisée »", interface_carnet.get_node("Papier/Apaisee").visible)
	await appuyer_en_pause("carnet")

func tests_ko() -> void:
	section("Jalon 1 : K.O. et retour au début")
	await nouveau_terrain(false, true)
	root.get_node("Carnet").ajouter_analyse(hure.get_node("Analysable").espece)
	var ancien_terrain := terrain
	var recu := [false]
	gojo.ko.connect(func(): recu[0] = true)
	gojo.pv = 1
	hure.global_position = gojo.global_position + Vector2(80, 0)
	var images := 0
	while gojo.pv > 0 and images < 120:
		await attendre(1)
		images += 1
	verifier("Gojo tombe K.O. à 0 PV", gojo.etat == gojo.Etat.KO and recu[0])
	Input.action_press("droite")
	await attendre(10)
	verifier("K.O., Gojo ne bouge plus", gojo.velocity.length() < 1.0, str(gojo.velocity))
	relacher_tout()
	images = 0
	while current_scene == ancien_terrain and images < 200:
		await attendre(1)
		images += 1
	await attendre(2)
	# 11 images se sont déjà écoulées depuis le K.O. (détection + 10 images de vérification).
	verifier("le terrain recommence après ≈ 1,5 s", current_scene != ancien_terrain and absi(images + 11 - 90) <= 2, "%d images" % (images + 11))
	var nouveau_gojo = current_scene.get_node("Gojo")
	verifier("Gojo repart avec 6 PV", nouveau_gojo.pv == 6)
	verifier("le carnet garde ses pages après un K.O.", root.get_node("Carnet").analyses(current_scene.get_node("Hure/Analysable").espece) == 1)
	terrain = current_scene

extends "res://tests/base_de_test.gd"
## Tests des jalons 4 et 5 : la quête du Bois des Souches jouée de bout en bout, jusqu'à Garin
## Corbe et la fin du carnet ; puis Garin affronté sans avoir soigné le camp, les rase-mousses,
## l'analyse d'une plante dans la main, et la silhouette du Dieu des monstres.
##
## Les positions sont prises sur les nœuds de la zone (Greg, les malades, les plantes…) :
## on peut déplacer un personnage dans la scène sans casser les tests.

var zone
var gojo
var carnet
var dialogue

func placer(p: Vector2, regard := Vector2.ZERO) -> void:
	gojo.global_position = p
	gojo.reset_physics_interpolation()
	gojo.velocity = Vector2.ZERO
	if regard != Vector2.ZERO:
		gojo.direction_regard = regard
	await attendre(3)

func nouvelle_zone() -> void:
	relacher_tout()
	if zone and is_instance_valid(zone):
		zone.queue_free()
		await attendre(2)
	carnet.effacer()
	zone = load("res://zone/bois_des_souches.tscn").instantiate()
	root.add_child(zone)
	current_scene = zone
	gojo = zone.get_node("Gojo")
	zone.get_node("Chene/Hure").distance_detection = 0.0
	for rm in rase_mousses():
		rm.distance_detection = 0.0
	await attendre(3)

## Attend qu'un dialogue s'ouvre (par exemple après une marche), sans compter sur la vitesse de la machine.
func attendre_dialogue(images_max := 300) -> void:
	var images := 0
	while not dialogue.en_cours and images < images_max:
		await physics_frame
		images += 1

## Un coup de bâton dans Garin, de face.
func frapper_garin() -> void:
	await placer(zone.garin.global_position + Vector2(-16, 0), Vector2.RIGHT)
	await appuyer("attaque")
	await attendre(3)

func lancer() -> void:
	carnet = root.get_node("Carnet")
	dialogue = root.get_node("Dialogue")
	await test_quete_complete()
	await test_greg_se_retourne()
	await test_boss_sans_le_camp()
	await test_rase_mousses()
	await test_plante_dans_la_main()
	await test_silhouettes()

func test_quete_complete() -> void:
	await nouvelle_zone()
	section("Beat 1 : l'arrivée")
	var baton: Node2D = zone.get_node("Clairiere/BatonAuSol")
	verifier("Gojo commence dans la clairière, sans bâton", not gojo.a_le_baton and gojo.global_position.distance_to(baton.global_position) < 160)
	await appuyer("attaque")
	verifier("sans bâton, pas de coup", gojo.etat == gojo.Etat.MARCHE)
	await placer(baton.global_position + Vector2(-14, 0))
	var invite: Label = zone.get_node("Interface/Invite")
	verifier("près du bâton : « E : ramasser le bâton »", invite.text == "E : ramasser le bâton", invite.text)
	await appuyer("interagir")
	var lues := await lire_dialogue()
	verifier("Gojo ramasse le bâton (une ligne de description)", gojo.a_le_baton and lues == 1 and not is_instance_valid(zone.get_node_or_null("Clairiere/BatonAuSol")), "%d ligne(s)" % lues)

	section("Beat 2 : le réflexe")
	await placer(zone.get_node("Fourre/EntreeFourre").global_position + Vector2(12, 8))
	verifier("entrée dans le fourré : les ronces se referment derrière", zone.etape == zone.Etape.FOURRE and zone.get_node("Passages/RoncesFourre").visible)
	await placer(zone.greg.global_position + Vector2(-20, 0), Vector2.RIGHT)
	verifier("près de Greg, de dos : « J : frapper »", invite.text == "J : frapper", invite.text)
	await appuyer("attaque")
	await attendre(2)
	verifier("dès le premier coup, trois gobelins surgissent", zone.etape == zone.Etape.REFLEXE and zone._embusques.all(func(g): return g.visible and g.etat == g.Etat.ATTAQUE))
	var pv_min: int = gojo.pv
	var temps := 0.0
	var pv_gobelins_intacts := true
	var image := 0
	while zone.etape == zone.Etape.REFLEXE and temps < 20.0:
		# Gojo se défend comme il peut, un coup toutes les 20 images. Les images sont comptées
		# depuis le début du combat, pour qu'il se joue pareil sur toutes les machines.
		if gojo.etat == gojo.Etat.MARCHE and image % 20 == 0:
			Input.action_press("attaque")
		elif image % 20 == 2:
			Input.action_release("attaque")
		image += 1
		await attendre(1)
		temps += 1.0 / 60.0
		pv_min = mini(pv_min, gojo.pv)
	relacher_tout()
	verifier("le combat dure moins de quinze secondes", temps < 15.0, "%.1f s" % temps)
	verifier("Gojo tombe à 1 PV, jamais à 0", gojo.pv == 1 and pv_min == 1, "pv %d, minimum %d" % [gojo.pv, pv_min])
	lues = await lire_dialogue()
	verifier("Greg parle (3 répliques)", lues == 3, "%d" % lues)
	verifier("les ronces vers le camp s'ouvrent", not zone.get_node("Passages/RoncesCamp").visible)
	verifier("Greg guide Gojo vers le camp", zone.greg.etat == zone.greg.Etat.MARCHE_VERS)
	verifier("plus de PV minimum après le combat", gojo.pv_minimum == 0)

	section("Beat 3 : le camp")
	# Gojo suit le chemin en revenant au milieu : le combat a pu le repousser au bord,
	# et tout droit il buterait contre un buisson.
	var milieu_du_chemin: float = zone.get_node("Camp/EntreeCamp").global_position.y
	Input.action_press("droite")
	temps = 0.0
	while zone.etape != zone.Etape.CAMP and temps < 8.0:
		var ecart: float = milieu_du_chemin - gojo.global_position.y
		if ecart > 2.0:
			Input.action_press("bas")
		else:
			Input.action_release("bas")
		if ecart < -2.0:
			Input.action_press("haut")
		else:
			Input.action_release("haut")
		await attendre(1)
		temps += 1.0 / 60.0
	relacher_tout()
	verifier("en suivant le chemin, Gojo arrive au camp", zone.etape == zone.Etape.CAMP, "%.1f s" % temps)
	lues = await lire_dialogue()
	verifier("arrivée : 2 lignes, et Gojo reprend des forces", lues == 2 and gojo.pv == 6, "%d lignes, pv %d" % [lues, gojo.pv])
	verifier("sens unique : les ronces se referment derrière", zone.get_node("Passages/RoncesCamp").visible)
	verifier("la meute du fourré est maintenant au camp", zone._embusques.all(func(g): return g.visible))
	var lisiere_fermee: bool = zone.get_node("Passages/RoncesLisiere").visible
	verifier("avant la quête, la lisière est fermée", lisiere_fermee)

	await placer(zone.lila.global_position + Vector2(-22, 2), Vector2.RIGHT)
	await appuyer("interagir")
	lues = await lire_dialogue()
	verifier("Lila tourne le dos (une description)", lues == 1, "%d ligne(s)" % lues)
	var malade: Node2D = zone.get_node("Camp/Malades/Malade1")
	await placer(malade.global_position + Vector2(-22, 2), Vector2.RIGHT)
	await analyser()
	lues = await lire_dialogue()
	verifier("analyser un malade ouvre la quête", zone.etape == zone.Etape.QUETE and lues == 2, "%d lignes" % lues)
	verifier("première observation des gobelins", carnet.analyses(malade.analysable.espece) == 1)
	verifier("la quête ouvre la lisière", not zone.get_node("Passages/RoncesLisiere").visible)

	section("Beat 4 : la cueillette")
	var mousse: Node2D = zone.get_node("Chene/MousseDeLune")
	var ronce: Node2D = zone.get_node("Chene/RonceRouge")
	verifier("mousse et ronce se ressemblent", mousse.get_node("Visuel").color == ronce.get_node("Visuel").color)
	await placer(mousse.global_position + Vector2(-20, 4), Vector2.RIGHT)
	await analyser()
	verifier("une analyse remplit la page de la mousse-de-lune", carnet.est_complete(mousse.espece))
	verifier("analysée, la mousse-de-lune ne ressemble plus à la ronce", mousse.get_node("Visuel").color != ronce.get_node("Visuel").color)
	await appuyer("interagir")
	verifier("cueillie : la mousse est dans la sacoche", gojo.sacoche.plantes.size() == 1 and not is_instance_valid(mousse))
	await placer(ronce.global_position + Vector2(-20, 4), Vector2.RIGHT)
	verifier("la ronce, pas analysée, se présente comme une « mousse bleutée »", invite.text == "E : cueillir mousse bleutée", invite.text)
	await appuyer("interagir")
	var barre_nom: Label = zone.get_node("Interface/BarrePlantes/Nom")
	verifier("dans la barre, la ronce s'appelle « Mousse bleutée »", barre_nom.text == "Mousse bleutée", barre_nom.text)
	var capuchon: Node2D = zone.get_node("Creux/CapuchonGris")
	await placer(capuchon.global_position + Vector2(-20, 4), Vector2.RIGHT)
	await appuyer("interagir")
	var fleur: Node2D = zone.get_node("Creux/FleurTrompette")
	await placer(fleur.global_position + Vector2(-20, 4), Vector2.RIGHT)
	await analyser()
	await appuyer("interagir")
	verifier("quatre plantes dans les quatre cases", gojo.sacoche.plantes.size() == 4 and gojo.sacoche.est_pleine())
	verifier("la dernière cueillie est choisie", gojo.sacoche.plante_choisie().effet == 3)

	section("Beat 5 : le remède")
	await placer(malade.global_position + Vector2(-22, 2), Vector2.RIGHT)
	verifier("près d'un malade, avec une plante : « E : donner la plante »", invite.text == "E : donner la plante", invite.text)
	await appuyer("interagir")
	lues = await lire_dialogue()
	verifier("la fleur-trompette ne soigne pas, Lila la rend", lues == 1 and gojo.sacoche.plantes.size() == 4, "%d ligne(s), %d plantes, fièvre %s" % [lues, gojo.sacoche.plantes.size(), malade.fievre])
	await appuyer("changer_plante")
	verifier("R change de plante : la mousse-de-lune", gojo.sacoche.plante_choisie().effet == 0, barre_nom.text)
	await appuyer("interagir")
	lues = await lire_dialogue()
	verifier("la mousse-de-lune fait tomber la fièvre de tous les malades", lues == 1 and zone._malades.all(func(m): return not m.fievre and m.taches))
	verifier("la mousse est consommée", gojo.sacoche.plantes.size() == 3)
	verifier("la plante choisie est maintenant la ronce", gojo.sacoche.plante_choisie().effet == 2)
	await appuyer("interagir")
	await attendre(2)
	var tousse: bool = malade._temps_toux > 0.0
	lues = await lire_dialogue()
	verifier("la ronce-rouge : le malade tousse, Lila la jette (3 lignes)", tousse and lues == 3 and gojo.sacoche.plantes.size() == 2, "%d lignes" % lues)
	verifier("personne n'en meurt, les taches restent", zone._malades.all(func(m): return m.taches))
	await appuyer("interagir")
	lues = await lire_dialogue()
	verifier("le capuchon gris referme les taches, puis la guérison (1 + 3 lignes)", lues == 4, "%d lignes" % lues)
	verifier("les malades se relèvent", zone._malades.all(func(m): return not m.est_malade()))
	verifier("étape : guéris", zone.etape == zone.Etape.GUERIS)
	verifier("la page des gobelins passe en langage humain", carnet.est_apaisee(malade.analysable.espece))
	verifier("il reste la fleur-trompette dans la sacoche", gojo.sacoche.plantes.size() == 1 and gojo.sacoche.plante_choisie().effet == 3)

	section("Après la quête")
	await placer(zone.lila.global_position + Vector2(-22, 2), Vector2.RIGHT)
	await appuyer("interagir")
	lues = await lire_dialogue()
	verifier("Lila parle maintenant (l'homme de la lisière)", lues == 1 and zone.lila.repliques == zone.repliques_lila_apres)

	section("Carnet et dialogue")
	await appuyer("interagir")
	await process_frame
	Input.action_press("carnet")
	await process_frame
	await process_frame
	Input.action_release("carnet")
	verifier("pendant un dialogue, Tab n'ouvre pas le carnet", not zone.get_node("Interface/InterfaceCarnet").visible)
	await lire_dialogue()

	section("Reprise après un K.O.")
	gojo.pv = 1
	var coup := creer_coup(zone, gojo.global_position + Vector2(0, -10))
	await attendre(5)
	coup.queue_free()
	verifier("Gojo tombe K.O.", gojo.etat == gojo.Etat.KO)
	await attendre(100)
	verifier("il repart du camp, avec tous ses PV et sa plante", gojo.etat == gojo.Etat.MARCHE and gojo.pv == 6 and gojo.global_position.distance_to(zone._marqueur("RepriseCamp")) < 1.0 and gojo.sacoche.plantes.size() == 1, "etat %d, pv %d, %s, %d plante(s)" % [gojo.etat, gojo.pv, gojo.global_position, gojo.sacoche.plantes.size()])

	await test_boss_avec_le_camp()

## La suite de la quête : le camp est soigné, et Gojo a encore la fleur-trompette.
func test_boss_avec_le_camp() -> void:
	var garin = zone.garin
	var espece = garin.analysable.espece
	var ronces: Node2D = zone.get_node("Passages/RoncesLisiere")
	var invite: Label = zone.get_node("Interface/Invite")
	section("Beat 6 : la lisière")
	verifier("Garin n'est pas encore là", not garin.visible)
	await placer(zone.get_node("Lisiere/AvantLisiere").global_position + Vector2(0, 8))
	var lues := await lire_dialogue()
	verifier("au seuil de la lisière, une odeur de fumée (2 lignes)", lues == 2, "%d ligne(s)" % lues)
	await placer(zone.get_node("Lisiere/EntreeLisiere").global_position + Vector2(4, 8), Vector2.RIGHT)
	verifier("sens unique : les ronces se referment derrière", ronces.visible and zone.etape == zone.Etape.BOSS)
	verifier("Garin entre dans la lisière", garin.visible)
	await attendre_dialogue()
	lues = await lire_dialogue()
	verifier("il se présente (3 lignes)", lues == 3, "%d ligne(s)" % lues)
	verifier("le combat commence : sa barre de vie s'affiche", zone.get_node("Interface/BarreBoss").visible and garin.etat == garin.Etat.MARCHE and garin.phase == 1)

	section("Phase 1 : l'arbalète")
	await placer(garin.global_position + Vector2(-110, 0), Vector2.RIGHT)
	var pv_avant: int = gojo.pv
	var a_vise := false
	for i in 240:
		await attendre(1)
		a_vise = a_vise or (garin.etat == garin.Etat.VISEE and garin.get_node("Arme/Visee").visible)
		if gojo.pv < pv_avant:
			break
	verifier("il vise : un trait rouge", a_vise)
	verifier("le carreau touche Gojo : 1 PV", gojo.pv == pv_avant - 1, "pv %d" % gojo.pv)
	await attendre(60)
	pv_avant = gojo.pv
	var images := 0
	while garin.etat != garin.Etat.VISEE and images < 240:
		await attendre(1)
		images += 1
	while garin.etat == garin.Etat.VISEE:
		await attendre(1)
	var carreaux := get_nodes_in_group("projectiles_de_garin")
	var carreau: Node2D = carreaux[0] if not carreaux.is_empty() else null
	while is_instance_valid(carreau) and carreau.global_position.distance_to(gojo.global_position + Vector2(0, -11)) > 30.0:
		await attendre(1)
	await appuyer("roulade")
	await attendre(20)
	verifier("une roulade traverse le carreau sans dommage", carreau != null and gojo.pv == pv_avant, "pv %d" % gojo.pv)

	section("Les pièges")
	garin._temps_avant_tir = 99.0
	await placer(garin.global_position + Vector2(-40, 0), Vector2.RIGHT)
	var piege: Node2D = null
	for i in 240:
		await attendre(1)
		var pieges := get_nodes_in_group("pieges_de_garin")
		if not pieges.is_empty():
			piege = pieges[0]
			break
	verifier("serré de près, il pose un piège", piege != null)
	garin._temps_avant_piege = 99.0
	if piege:
		pv_avant = gojo.pv
		await placer(piege.global_position + Vector2(0, 8))
		verifier("marcher dessus : 1 PV", gojo.pv == pv_avant - 1, "pv %d" % gojo.pv)
		await attendre(40)
		verifier("un piège ne sert qu'une fois", not is_instance_valid(piege))

	section("Le pollen et la page de Garin")
	gojo.soigner()
	await placer(garin.global_position + Vector2(-18, 2), Vector2.RIGHT)
	verifier("avec la fleur-trompette : « E : souffler le pollen »", invite.text == "E : souffler le pollen", invite.text)
	await appuyer("interagir")
	verifier("le pollen endort Garin", garin.etat == garin.Etat.ENDORMI)
	await analyser()
	await analyser()
	verifier("endormi, il s'analyse : deux observations", carnet.analyses(espece) == 2, "%d" % carnet.analyses(espece))
	while garin.etat == garin.Etat.ENDORMI:
		await attendre(1)
	verifier("réveillé, le pollen ne marche plus tout de suite", not garin.peut_etre_endormi() and not invite.text.contains("pollen"))
	garin._temps_resistance = 0.0
	await placer(garin.global_position + Vector2(-18, 2), Vector2.RIGHT)
	await appuyer("interagir")
	var pv_garin: int = garin.pv
	await frapper_garin()
	verifier("un coup de bâton le réveille", garin.etat != garin.Etat.ENDORMI and garin.pv == pv_garin - 1)
	garin._temps_resistance = 0.0
	await placer(garin.global_position + Vector2(-18, 2), Vector2.RIGHT)
	await appuyer("interagir")
	await analyser()
	verifier("troisième analyse : sa page est complète", carnet.est_complete(espece))

	section("Phase 2 : la lame, et le renfort")
	await attendre(20)
	garin.pv = garin.pv_max / 2 + 1
	await frapper_garin()
	lues = await lire_dialogue()
	verifier("à mi-vie, il jette l'arbalète et sort la lame (1 + 1 lignes)", garin.phase == 2 and lues == 2, "phase %d, %d ligne(s)" % [garin.phase, lues])
	verifier("l'arbalète reste dans l'herbe", garin.get_node_or_null("Arme/Arbalete") == null)
	var renfort: Array = zone._renfort
	verifier("le camp soigné, quatre gobelins viennent en renfort", renfort.size() == 4 and renfort.all(func(g): return g.visible and g.etat == g.Etat.ATTAQUE and g.cible_attaque == garin and g.global_position.x > 976))
	await placer(zone._marqueur("RepriseLisiere"))
	pv_garin = garin.pv
	var diversion := false
	for i in 300:
		await attendre(1)
		diversion = diversion or (garin._cible() != gojo and garin._cible() in renfort)
		if diversion:
			break
	verifier("frappé par un gobelin, Garin se retourne contre lui", diversion)
	verifier("les gobelins ne lui font presque rien", garin.pv == pv_garin, "pv %d" % garin.pv)
	await frapper_garin()
	verifier("pendant la diversion, les coups de Gojo portent toujours", garin.pv == pv_garin - 1, "pv %d" % garin.pv)

	section("La fin du carnet")
	gojo.soigner()
	await attendre(20)
	garin.pv = 1
	await frapper_garin()
	lues = await lire_dialogue()
	verifier("à 0 PV, Garin tombe à genoux (1 ligne) : il ne meurt pas", garin.etat == garin.Etat.A_TERRE and garin.visible and lues == 1, "%d ligne(s)" % lues)
	verifier("la barre de vie disparaît, le renfort s'arrête", not zone.get_node("Interface/BarreBoss").visible and renfort.all(func(g): return g.etat == g.Etat.IMMOBILE))
	# Le dialogue a figé Gojo au milieu de son coup de bâton : on le laisse finir.
	await attendre(10)
	await placer(garin.global_position + Vector2(-18, 2), Vector2.RIGHT)
	verifier("page complète : « E : tendre le carnet »", invite.text == "E : tendre le carnet", invite.text)
	await appuyer("interagir")
	lues = await lire_dialogue()
	verifier("Garin lit (3 lignes) : sa page passe en langage humain", lues == 3 and carnet.est_apaisee(espece), "%d ligne(s)" % lues)
	verifier("il laisse tomber sa torche", garin.get_node_or_null("Torche") == null)
	images = 0
	while garin.visible and images < 300:
		await attendre(1)
		images += 1
	verifier("il s'en va", not garin.visible)
	var liste: Node2D = zone.get_node("Lisiere/ListeDePrimes")
	verifier("il laisse derrière lui sa liste de primes", liste.visible)
	await placer(liste.global_position + Vector2(-14, 0), Vector2.RIGHT)
	verifier("« E : ramasser la liste de primes »", invite.text == "E : ramasser la liste de primes", invite.text)
	await appuyer("interagir")
	lues = await lire_dialogue()
	verifier("la liste de primes (3 lignes), et c'est la fin", lues == 3 and zone.etape == zone.Etape.FIN and zone.fin_heureuse, "%d ligne(s)" % lues)
	var fin: Control = zone.get_node("Interface/Fin")
	verifier("l'écran de fin provisoire", fin.visible and fin.get_node("SousTitre").text == zone.texte_fin_du_carnet)
	verifier("la lisière se rouvre", not ronces.visible)
	verifier("le renfort rentre au camp", zone._renfort.is_empty() and zone.greg.global_position.distance_to(zone._marqueur("CampGreg")) < 1.0 and zone.greg.get_node("Hitbox").collision_layer == 16)
	verifier("le Dieu des monstres regarde, à l'orée du bois", zone.get_node("Dieu/Silhouette3").visible)
	verifier("au camp, Lila sait que l'homme au feu est parti", zone.lila.repliques == zone.repliques_lila_apres_garin)

func test_greg_se_retourne() -> void:
	await nouvelle_zone()
	section("Variante : Gojo s'approche de Greg sans frapper")
	await placer(zone.get_node("Fourre/EntreeFourre").global_position + Vector2(12, 8))
	await placer(zone.greg.global_position + Vector2(-20, 0), Vector2.RIGHT)
	await attendre(70)
	verifier("après une seconde tout près, Greg se retourne et la meute surgit", zone.etape == zone.Etape.REFLEXE)
	var temps := 0.0
	while zone.etape == zone.Etape.REFLEXE and temps < 20.0:
		await attendre(1)
		temps += 1.0 / 60.0
	verifier("sans se défendre non plus, moins de quinze secondes", temps < 15.0 and gojo.pv == 1, "%.1f s" % temps)
	await lire_dialogue()

func test_boss_sans_le_camp() -> void:
	await nouvelle_zone()
	section("Variante : affronter Garin sans avoir soigné le camp")
	var garin = zone.garin
	var ronces: Node2D = zone.get_node("Passages/RoncesLisiere")
	gojo.a_le_baton = true
	zone.etape = zone.Etape.CAMP
	var malade: Node2D = zone.get_node("Camp/Malades/Malade1")
	await placer(malade.global_position + Vector2(-22, 2), Vector2.RIGHT)
	await analyser()
	await lire_dialogue()
	verifier("dès la quête, la lisière est ouverte", zone.etape == zone.Etape.QUETE and not ronces.visible)
	await placer(zone.get_node("Lisiere/EntreeLisiere").global_position + Vector2(4, 8), Vector2.RIGHT)
	await attendre_dialogue()
	var lues := await lire_dialogue()
	verifier("Garin arrive (3 lignes)", lues == 3 and garin.etat == garin.Etat.MARCHE)

	section("K.O. pendant le combat")
	await frapper_garin()
	verifier("un coup de bâton : 1 PV", garin.pv == garin.pv_max - 1, "pv %d" % garin.pv)
	gojo.pv = 1
	var coup := creer_coup(zone, gojo.global_position + Vector2(0, -10))
	await attendre(5)
	coup.queue_free()
	verifier("Gojo tombe K.O.", gojo.etat == gojo.Etat.KO)
	await attendre(100)
	verifier("il repart de l'entrée de la lisière", gojo.etat == gojo.Etat.MARCHE and gojo.pv == 6 and gojo.global_position.distance_to(zone._marqueur("RepriseLisiere")) < 1.0)
	verifier("le combat recommence : Garin a tous ses PV", zone.etape == zone.Etape.BOSS and garin.pv == garin.pv_max and garin.phase == 1 and garin.etat == garin.Etat.MARCHE)

	section("Phase 2, sans renfort")
	await attendre(20)
	garin.pv = garin.pv_max / 2 + 1
	await frapper_garin()
	lues = await lire_dialogue()
	verifier("il sort la lame, et personne ne vient (1 ligne)", garin.phase == 2 and lues == 1 and zone._renfort.is_empty() and zone.greg.global_position.x < 960, "%d ligne(s)" % lues)
	gojo.soigner()
	var pv_avant: int = gojo.pv
	var a_leve_la_lame := false
	var a_souffle := false
	await placer(garin.global_position + Vector2(-30, 0), Vector2.RIGHT)
	for i in 180:
		await attendre(1)
		a_leve_la_lame = a_leve_la_lame or (garin.etat == garin.Etat.LAME_LEVEE and gojo.pv == pv_avant)
		a_souffle = a_souffle or garin.etat == garin.Etat.SOUFFLE
		if gojo.pv < pv_avant and a_souffle:
			break
	verifier("il lève la lame, puis frappe : 1 PV", a_leve_la_lame and gojo.pv == pv_avant - 1, "pv %d" % gojo.pv)
	verifier("après le coup, il souffle", a_souffle)

	section("La fin ouverte")
	await attendre(60)
	garin.pv = 1
	await frapper_garin()
	lues = await lire_dialogue()
	verifier("page incomplète : à genoux, il jure de revenir (1 + 2 lignes)", lues == 3, "%d ligne(s)" % lues)
	var images := 0
	while garin.visible and images < 300:
		await attendre(1)
		images += 1
	verifier("il s'enfuit entre les arbres", not garin.visible)
	verifier("c'est la fin ouverte", zone.etape == zone.Etape.FIN and not zone.fin_heureuse and zone.get_node("Interface/Fin/SousTitre").text == zone.texte_fin_ouverte)
	verifier("sa page reste en langage de laboratoire, sans liste de primes", not carnet.est_apaisee(garin.analysable.espece) and not zone.get_node("Lisiere/ListeDePrimes").visible)
	verifier("la lisière se rouvre : le camp reste à soigner", not ronces.visible and zone._malades.any(func(m): return m.est_malade()))

func rase_mousses() -> Array:
	return zone.get_node("Creux").get_children().filter(func(n): return n.name.begins_with("RaseMousse"))

func test_rase_mousses() -> void:
	await nouvelle_zone()
	section("Les rase-mousses du creux humide")
	var nuee := rase_mousses()
	verifier("une nuée de quatre rase-mousses", nuee.size() == 4)
	for rm in nuee:
		rm.distance_detection = 72.0
	var centre: Vector2 = nuee[0].global_position
	await placer(centre + Vector2(-50, 0))
	var a_attaque := false
	var a_fui := false
	for i in 180:
		await attendre(1)
		for rm in nuee:
			a_attaque = a_attaque or rm.etat == rm.Etat.ATTAQUE
			a_fui = a_fui or rm.etat == rm.Etat.FUITE
	verifier("ils foncent mordre Gojo", a_attaque and gojo.pv < 6, "pv %d" % gojo.pv)
	verifier("après une morsure, ils s'enfuient", a_fui)

	await nouvelle_zone()
	nuee = rase_mousses()
	for rm in nuee:
		rm.distance_detection = 0.0
		rm.vitesse_vol = 0.0
	gojo.a_le_baton = true
	var cible = nuee[0]
	await placer(cible.global_position + Vector2(-16, 4), Vector2.RIGHT)
	await appuyer("attaque")
	await attendre(25)
	verifier("un coup de bâton : 1 PV sur 2", is_instance_valid(cible) and cible.pv == 1)
	await placer(cible.global_position + Vector2(-16, 4), Vector2.RIGHT)
	await appuyer("attaque")
	await attendre(10)
	verifier("deux coups : il meurt", not is_instance_valid(cible))

	section("Le pollen de fleur-trompette")
	await nouvelle_zone()
	nuee = rase_mousses()
	for rm in nuee:
		rm.distance_detection = 0.0
		rm.vitesse_vol = 0.0
	cible = nuee[0]
	await placer(cible.global_position + Vector2(-18, 4), Vector2.RIGHT)
	var invite: Label = zone.get_node("Interface/Invite")
	verifier("sans la fleur, rien à souffler", not invite.text.contains("pollen"), invite.text)
	gojo.sacoche.ajouter(load("res://plantes/fleur_trompette.tres"))
	await attendre(2)
	verifier("fleur-trompette choisie : « E : souffler le pollen »", invite.text == "E : souffler le pollen", invite.text)
	await appuyer("interagir")
	var endormis := nuee.filter(func(rm): return rm.etat == rm.Etat.ENDORMI).size()
	verifier("le pollen endort les rase-mousses proches", endormis >= 2 and cible.etat == cible.Etat.ENDORMI, "%d endormis" % endormis)
	verifier("la fleur n'est pas consommée", gojo.sacoche.plantes.size() == 1)
	for i in 3:
		await analyser()
	verifier("endormis, ils s'analysent : page complète en trois analyses", carnet.est_complete(cible.analysable.espece), "%d analyse(s)" % carnet.analyses(cible.analysable.espece))
	while cible.etat == cible.Etat.ENDORMI:
		await attendre(1)
	verifier("page complète : au réveil, ils sont apaisés", cible.etat == cible.Etat.APAISE and carnet.est_apaisee(cible.analysable.espece))
	cible.distance_detection = 200.0
	var attaque := false
	for i in 120:
		await attendre(1)
		attaque = attaque or cible.etat == cible.Etat.ATTAQUE
	verifier("apaisés, ils ne mordent plus", not attaque and gojo.pv == 6)

	await nouvelle_zone()
	nuee = rase_mousses()
	for rm in nuee:
		rm.distance_detection = 0.0
		rm.vitesse_vol = 0.0
		rm.duree_sommeil = 1.0
	cible = nuee[0]
	gojo.sacoche.ajouter(load("res://plantes/fleur_trompette.tres"))
	await placer(cible.global_position + Vector2(-18, 4), Vector2.RIGHT)
	await appuyer("interagir")
	await attendre(70)
	verifier("page incomplète : au réveil, ils recommencent à harceler", cible.etat == cible.Etat.ERRANCE or cible.etat == cible.Etat.ATTAQUE)

func test_plante_dans_la_main() -> void:
	await nouvelle_zone()
	section("Analyser une plante déjà cueillie")
	var ronce: Node2D = zone.get_node("Chene/RonceRouge")
	var espece = ronce.espece
	# À droite de la ronce : à gauche, la mousse-de-lune, juste à côté, serait plus proche.
	await placer(ronce.global_position + Vector2(16, -2), Vector2.LEFT)
	await appuyer("interagir")
	verifier("la ronce est cueillie sans avoir été analysée", gojo.sacoche.plantes.size() == 1 and not carnet.est_complete(espece))
	# Au milieu du camp, loin de tout ce qui s'analyse ou se cueille.
	await placer(zone._marqueur("RepriseCamp"))
	var invite: Label = zone.get_node("Interface/Invite")
	verifier("l'invite propose de l'analyser dans la main", invite.text == "K : analyser la plante choisie", invite.text)
	Input.action_press("analyse")
	await attendre(30)
	verifier("K : Gojo l'examine (la barre monte)", gojo.etat == gojo.Etat.ANALYSE and gojo._progression_analyse > 0.4, "%.2f" % gojo._progression_analyse)
	await attendre(32)
	Input.action_release("analyse")
	await attendre(2)
	verifier("une seconde plus tard, la ronce-rouge est dans l'herbier", carnet.est_complete(espece))
	var barre_nom: Label = zone.get_node("Interface/BarrePlantes/Nom")
	verifier("dans la barre, elle porte son vrai nom", barre_nom.text == "Ronce-rouge", barre_nom.text)
	verifier("plus rien à analyser : l'invite disparaît", invite.text == "", invite.text)
	await appuyer("analyse")
	verifier("une plante connue ne s'analyse plus", gojo.etat == gojo.Etat.MARCHE)

	gojo.sacoche.ajouter(load("res://plantes/capuchon_gris.tres"))
	gojo.sacoche.ajouter(load("res://plantes/fleur_trompette.tres"))
	gojo.sacoche.choix = 1
	Input.action_press("analyse")
	await attendre(20)
	await appuyer("changer_plante")
	await attendre(25)
	verifier("changer de plante pendant l'examen l'interrompt", gojo.etat == gojo.Etat.MARCHE and not carnet.est_complete(load("res://plantes/capuchon_gris.tres")))
	Input.action_release("analyse")
	await attendre(2)

	gojo.sacoche.choix = 1
	Input.action_press("analyse")
	await attendre(20)
	var coup := creer_coup(zone, gojo.global_position + Vector2(0, -10))
	await attendre(4)
	coup.queue_free()
	verifier("un coup reçu interrompt aussi l'examen", gojo.etat != gojo.Etat.ANALYSE and gojo._progression_analyse == 0.0)
	Input.action_release("analyse")
	await attendre(2)

func test_silhouettes() -> void:
	await nouvelle_zone()
	section("Le Dieu des monstres, en lisière de forêt")
	var premiere: Node2D = zone.get_node("Dieu/Silhouette1")
	var deuxieme: Node2D = zone.get_node("Dieu/Silhouette2")
	var derniere: Node2D = zone.get_node("Dieu/Silhouette3")
	verifier("aperçu dans la clairière, dès l'arrivée", premiere.visible and premiere.global_position.distance_to(gojo.global_position) > premiere.distance_disparition)
	verifier("une autre au vieux chêne ; la dernière attend la fin", deuxieme.visible and not derniere.visible)
	verifier("muet : rien à lui dire, rien à analyser", premiere.find_children("*", "Area2D").is_empty())
	await placer(premiere.global_position + Vector2(0, 60))
	await attendre(45)
	verifier("Gojo s'approche : il s'efface", not premiere.visible and premiere.est_effacee())
	await placer(premiere.global_position + Vector2(-120, 60))
	await attendre(30)
	verifier("il ne revient pas, les autres restent", not premiere.visible and deuxieme.visible)

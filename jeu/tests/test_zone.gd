extends "res://tests/base_de_test.gd"
## Tests du jalon 4 : la quête du Bois des Souches jouée de bout en bout, puis les rase-mousses
## et l'analyse d'une plante dans la main.
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

func lancer() -> void:
	carnet = root.get_node("Carnet")
	dialogue = root.get_node("Dialogue")
	await test_quete_complete()
	await test_greg_se_retourne()
	await test_rase_mousses()
	await test_plante_dans_la_main()

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
	while zone.etape == zone.Etape.REFLEXE and temps < 20.0:
		# Gojo se défend comme il peut.
		if gojo.etat == gojo.Etat.MARCHE and Engine.get_physics_frames() % 20 == 0:
			Input.action_press("attaque")
		elif Engine.get_physics_frames() % 20 == 2:
			Input.action_release("attaque")
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
	Input.action_press("droite")
	temps = 0.0
	while zone.etape != zone.Etape.CAMP and temps < 8.0:
		await attendre(1)
		temps += 1.0 / 60.0
	Input.action_release("droite")
	verifier("en suivant le chemin, Gojo arrive au camp", zone.etape == zone.Etape.CAMP, "%.1f s" % temps)
	lues = await lire_dialogue()
	verifier("arrivée : 2 lignes, et Gojo reprend des forces", lues == 2 and gojo.pv == 6, "%d lignes, pv %d" % [lues, gojo.pv])
	verifier("sens unique : les ronces se referment derrière", zone.get_node("Passages/RoncesCamp").visible)
	verifier("la meute du fourré est maintenant au camp", zone._embusques.all(func(g): return g.visible))
	var lisiere_fermee: bool = zone.get_node("Passages/RoncesLisiere").visible
	verifier("la lisière reste fermée (jalon 5)", lisiere_fermee)

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

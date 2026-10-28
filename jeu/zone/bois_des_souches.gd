extends Node2D
## Le Bois des Souches : la tranche verticale v1. Une forêt, six lieux, vingt minutes, et un seul
## objectif : empêcher un homme de brûler un camp.
##
## Ce script déroule les beats du GDD : l'arrivée, le réflexe, le camp, la cueillette, le remède,
## puis la lisière : Garin Corbe, le renfort des gobelins, et l'une des deux fins.
## Les répliques sont des listes à réécrire dans l'inspecteur (rubrique Répliques) :
## une ligne par réplique, « Nom : texte », ou sans nom pour une description.

enum Etape { ARRIVEE, FOURRE, REFLEXE, VERS_LE_CAMP, CAMP, QUETE, GUERIS, BOSS, FIN }

@export_group("Combat du réflexe")
## Au-delà de cette durée, le combat s'arrête quoi qu'il arrive (le GDD : moins de quinze secondes).
@export var duree_max_reflexe := 12.0
## Si Gojo reste aussi près de Greg sans frapper, Greg se retourne quand même, en pixels.
@export var distance_reveil_greg := 24.0
## Temps passé près de Greg avant qu'il se retourne, en secondes.
@export var duree_avant_reveil := 1.0

@export_group("Reprise")
## Temps entre un K.O. et la reprise au dernier point sûr, en secondes.
@export var duree_avant_reprise := 1.5

@export_group("Le boss")
## Vrai : la lisière s'ouvre dès le début de la quête, et l'on peut affronter Garin sans avoir
## soigné le camp (mais alors, sans renfort). Faux : elle ne s'ouvre qu'une fois le camp soigné.
@export var lisiere_ouverte_des_la_quete := true
## Dégâts d'un coup de gobelin du renfort sur Garin. Le GDD : ils ne font presque pas de dégâts,
## ils font diversion.
@export var degats_du_renfort := 0
## Combien de temps l'écran de fin provisoire reste affiché, en secondes.
@export var duree_fin := 6.0

@export_group("Répliques")
@export var repliques_baton: Array[String] = ["Un bâton ferré, abandonné dans l'herbe. Gojo le ramasse."]
@export var repliques_fin_du_reflexe: Array[String] = [
	"Greg : Assez. Lui déjà par terre.",
	"Greg : Humain frappe d'abord, regarde après. Toujours pareil.",
	"Greg : Toi, viens. Camp pas loin.",
]
@export var repliques_arrivee_camp: Array[String] = [
	"Greg : Ici, camp. Assis. Bois l'eau.",
	"Gojo reprend des forces. Autour de lui : des familles, des bébés, et beaucoup de malades couchés.",
]
@export var repliques_greg_au_camp: Array[String] = ["Greg : Lila, la vieille, soigne. Mais rien marche."]
@export var repliques_lila_avant_quete: Array[String] = ["Lila te tourne le dos. Elle veille ses malades."]
@export var repliques_quete: Array[String] = [
	"Gojo : De la fièvre, et des taches noires sur la peau. Deux symptômes : il faudra deux remèdes.",
	"Lila : Toi, savant ? Alors cherche. Plantes au vieux chêne, en haut. Plantes au creux, en bas.",
]
@export var repliques_lila_pendant_quete: Array[String] = ["Lila : Fièvre, et taches. Deux plantes. Pas une de plus."]
@export var repliques_greg_pendant_quete: Array[String] = ["Greg : Ma sœur aussi, malade. Toi trouves, toi."]
@export var repliques_ronce: Array[String] = [
	"Le malade tousse.",
	"Lila : Non ! Celle-là brûle la gorge.",
	"Lila t'arrache la plante des mains et la jette.",
]
@export var repliques_fleur: Array[String] = ["Lila : Fleur-trompette fait dormir. Pas guérir. Garde."]
@export var repliques_mousse: Array[String] = ["Lila : Mousse-de-lune. Bonne. La fièvre descend."]
@export var repliques_capuchon: Array[String] = ["Lila : Capuchon gris. Bon. Les taches partent."]
@export var repliques_deja_soigne: Array[String] = ["Lila : Ça, déjà fait. Il manque l'autre."]
@export var repliques_gueris: Array[String] = [
	"Les malades se relèvent.",
	"Lila : Toi pas comme les autres humains.",
	"Greg : Toi, ami. Greg le dit à tous.",
]
@export var repliques_lila_apres: Array[String] = ["Lila : Un homme rôde à la lisière. Avec du feu. Fais attention."]
@export var repliques_greg_apres: Array[String] = ["Greg : Toi peux dormir au camp. Personne te tape."]
@export var repliques_villageois_gueris: Array[String] = ["Gobelin : Merci, humain. Moi debout."]
@export var repliques_avant_lisiere: Array[String] = [
	"Une odeur de fumée vient de la lisière.",
	"Une fois entré, pas de retour avant d'en avoir fini.",
]
@export var repliques_garin_arrivee: Array[String] = [
	"Un homme entre dans la lisière, une torche à la main.",
	"Garin : Garin Corbe, chasseur de primes. On me paie pour ce camp, pas pour toi.",
	"Garin : Écarte-toi, l'étranger. Ou ne t'écarte pas.",
]
@export var repliques_garin_lame: Array[String] = ["Garin jette son arbalète et tire sa lame."]
@export var repliques_renfort: Array[String] = ["Greg : Toi aidé nous. Maintenant, nous aider toi !"]
@export var repliques_garin_a_terre: Array[String] = ["Garin tombe à genoux."]
@export var repliques_fin_ouverte: Array[String] = [
	"Garin : Tu crois avoir gagné ? Je reviendrai. Avec dix hommes.",
	"Garin s'enfuit entre les arbres.",
]
@export var repliques_fin_du_carnet: Array[String] = [
	"Gojo lui tend le carnet, ouvert à sa page.",
	"Garin lit. Il se tait longtemps.",
	"Garin laisse tomber sa torche, et s'en va.",
]
@export var repliques_liste_de_primes: Array[String] = [
	"La liste de primes de Garin Corbe.",
	"Des noms de créatures, et un prix en face de chacun.",
	"Le camp des gobelins était en haut de la liste. Il en reste beaucoup d'autres.",
]
@export var repliques_lila_apres_garin: Array[String] = ["Lila : L'homme au feu, parti. Le camp se souviendra."]
@export var repliques_greg_apres_garin: Array[String] = ["Greg : Toi rester. Toujours une place au camp."]

@export_group("Fin provisoire")
## La dernière ligne de l'écran de fin, en attendant le vrai écran du jalon 6.
@export var texte_fin_du_carnet := "Garin est reparti sans sa torche."
@export var texte_fin_ouverte := "Garin reviendra, avec dix hommes."

var etape := Etape.ARRIVEE
## Vrai une fois les malades soignés (on peut affronter Garin avant, ou après).
var camp_gueri := false
## Vrai si la tranche s'est finie par le carnet tendu à Garin.
var fin_heureuse := false

var _point_de_reprise := Vector2.ZERO
var _temps_reflexe := 0.0
var _temps_pres_de_greg := 0.0
var _avertissement_fait := false
var _renfort: Array[Gobelin] = []

@onready var gojo: Gojo = $Gojo
@onready var greg: Gobelin = $Fourre/Greg
@onready var lila: Gobelin = $Camp/Lila
@onready var _baton_au_sol: Node2D = $Clairiere/BatonAuSol
@onready var _embusques: Array[Node] = $Fourre/Embusques.get_children()
@onready var _malades: Array[Node] = $Camp/Malades.get_children()
@onready var _ronces_fourre: StaticBody2D = $Passages/RoncesFourre
@onready var _ronces_camp: StaticBody2D = $Passages/RoncesCamp
@onready var _ronces_lisiere: StaticBody2D = $Passages/RoncesLisiere
@onready var _marqueurs: Node2D = $Marqueurs
@onready var garin: Garin = $Lisiere/Garin
@onready var _liste_de_primes: Node2D = $Lisiere/ListeDePrimes
@onready var _barre_boss: Control = $Interface/BarreBoss
@onready var _fin: Control = $Interface/Fin
@onready var _silhouette_finale: Node2D = $Dieu/Silhouette3


func _ready() -> void:
	gojo.a_le_baton = false
	_point_de_reprise = gojo.global_position
	gojo.ko.connect(_on_gojo_ko)
	# La caméra s'arrête aux bords de la carte (80 × 36 tuiles de 16 pixels).
	var camera: Camera2D = gojo.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 80 * 16
	camera.limit_bottom = 36 * 16

	_baton_au_sol.get_node("Interactif").utilise.connect(_on_baton_ramasse)
	$Fourre/EntreeFourre.body_entered.connect(_on_entree_fourre)
	$Camp/EntreeCamp.body_entered.connect(_on_entree_camp)

	greg.rendre_frappable(true)
	greg.frappe.connect(_on_greg_frappe)
	for embusque: Gobelin in _embusques:
		_cacher(embusque)
	lila.repliques = repliques_lila_avant_quete
	for malade: Gobelin in _malades:
		malade.plante_proposee.connect(_on_plante_proposee)
		malade.analysable.analysee.connect(_on_malade_analyse)

	$Lisiere/AvantLisiere.body_entered.connect(_on_avant_lisiere)
	$Lisiere/EntreeLisiere.body_entered.connect(_on_entree_lisiere)
	garin.deuxieme_phase.connect(_on_garin_deuxieme_phase)
	garin.a_terre.connect(_on_garin_a_terre)
	garin.carnet_tendu.connect(_fin_du_carnet)
	_liste_de_primes.get_node("Interactif").utilise.connect(_on_liste_ramassee)
	_cacher(garin)
	_cacher(_liste_de_primes)

	_fermer(_ronces_fourre, false)
	_fermer(_ronces_camp, true)
	_fermer(_ronces_lisiere, true)


func _physics_process(delta: float) -> void:
	match etape:
		Etape.FOURRE:
			# Gojo n'a pas frappé, mais il est tout près : Greg se retourne quand même.
			if gojo.global_position.distance_to(greg.global_position) <= distance_reveil_greg:
				_temps_pres_de_greg += delta
				if _temps_pres_de_greg >= duree_avant_reveil:
					_embuscade()
			else:
				_temps_pres_de_greg = 0.0
		Etape.REFLEXE:
			_temps_reflexe += delta
			if gojo.pv <= 1 or _temps_reflexe >= duree_max_reflexe:
				_fin_du_reflexe()


# --- Beat 1 : l'arrivée -------------------------------------------------------

func _on_baton_ramasse(_gojo: Gojo) -> void:
	gojo.a_le_baton = true
	_baton_au_sol.queue_free()
	Dialogue.dire(repliques_baton)


func _on_entree_fourre(corps: Node2D) -> void:
	if corps == gojo and etape == Etape.ARRIVEE:
		etape = Etape.FOURRE
		# Passage à sens unique : les ronces se referment derrière Gojo.
		_fermer(_ronces_fourre, true)


# --- Beat 2 : le réflexe ------------------------------------------------------

func _on_greg_frappe() -> void:
	if etape == Etape.FOURRE:
		_embuscade()


## Dès le premier coup, trois gobelins surgissent. Ce combat est impossible à gagner :
## ils n'ont pas de PV, et Gojo ne descend pas sous 1 PV.
func _embuscade() -> void:
	etape = Etape.REFLEXE
	_temps_reflexe = 0.0
	gojo.pv_minimum = 1
	greg.provoque_l_attaque = false
	greg.marcher_vers(greg.global_position + Vector2(40, 0))
	for i in _embusques.size():
		var embusque: Gobelin = _embusques[i]
		_montrer(embusque, _marqueur("Embuscade%d" % (i + 1)))
		embusque.rendre_frappable(true)
		embusque.attaquer()


## Gojo tombe à 1 PV : les gobelins s'arrêtent au lieu d'achever.
func _fin_du_reflexe() -> void:
	etape = Etape.VERS_LE_CAMP
	if gojo.pv > 1:
		gojo.pv = 1
		gojo.pv_changes.emit(gojo.pv, gojo.pv_max)
	for embusque: Gobelin in _embusques:
		var recul := gojo.global_position.direction_to(embusque.global_position) * 40.0
		embusque.marcher_vers(embusque.global_position + recul)
	greg.marcher_vers(gojo.global_position + gojo.global_position.direction_to(greg.global_position) * 22.0)
	await _attendre_arrivee(greg, 2.0)
	await Dialogue.dire(repliques_fin_du_reflexe)
	gojo.pv_minimum = 0
	# Les trois autres rentrent au camp par la forêt ; Greg guide Gojo par le chemin.
	for embusque: Gobelin in _embusques:
		_cacher(embusque)
	_fermer(_ronces_camp, false)
	greg.rendre_frappable(false)
	greg.marcher_vers(_marqueur("CampGreg"), true)


func _attendre_arrivee(gobelin: Gobelin, duree_max: float) -> void:
	var temps := 0.0
	while gobelin.etat == Gobelin.Etat.MARCHE_VERS and temps < duree_max:
		await get_tree().physics_frame
		temps += get_physics_process_delta_time()


# --- Beat 3 : le camp ---------------------------------------------------------

func _on_entree_camp(corps: Node2D) -> void:
	if corps != gojo or etape != Etape.VERS_LE_CAMP:
		return
	etape = Etape.CAMP
	_fermer(_ronces_camp, true)
	_point_de_reprise = _marqueur("RepriseCamp")
	for i in _embusques.size():
		var villageois: Gobelin = _embusques[i]
		_montrer(villageois, _marqueur("CampVillageois%d" % (i + 1)))
		villageois.rendre_frappable(false)
		villageois.regard = Vector2.DOWN
	await Dialogue.dire(repliques_arrivee_camp)
	gojo.soigner()
	greg.repliques = repliques_greg_au_camp


## Analyser un malade (premier usage libre du gant) révèle le symptôme et ouvre la quête.
func _on_malade_analyse() -> void:
	if etape != Etape.CAMP:
		return
	etape = Etape.QUETE
	for malade: Gobelin in _malades:
		malade.analysable.toujours_analysable = false
	if lisiere_ouverte_des_la_quete:
		_fermer(_ronces_lisiere, false)
	lila.regard = Vector2.LEFT
	await Dialogue.dire(repliques_quete)
	lila.repliques = repliques_lila_pendant_quete
	greg.repliques = repliques_greg_pendant_quete


# --- Beats 4 et 5 : la cueillette et le remède ---------------------------------

func _on_plante_proposee(malade: Gobelin, _gojo: Gojo) -> void:
	var plante := gojo.sacoche.plante_choisie()
	match plante.effet:
		EspecePlante.Effet.TOXIQUE:
			# L'erreur coûte du temps et de la honte, pas une vie.
			gojo.sacoche.retirer_choisie()
			malade.tousser()
			await Dialogue.dire(repliques_ronce)
		EspecePlante.Effet.ENDORT:
			await Dialogue.dire(repliques_fleur)
		EspecePlante.Effet.FIEVRE:
			if _reste_de_la_fievre():
				gojo.sacoche.retirer_choisie()
				for m: Gobelin in _malades:
					m.soigner_fievre()
				await Dialogue.dire(repliques_mousse)
			else:
				await Dialogue.dire(repliques_deja_soigne)
		EspecePlante.Effet.TACHES:
			if _reste_des_taches():
				gojo.sacoche.retirer_choisie()
				for m: Gobelin in _malades:
					m.soigner_taches()
				await Dialogue.dire(repliques_capuchon)
			else:
				await Dialogue.dire(repliques_deja_soigne)
	if not _reste_de_la_fievre() and not _reste_des_taches() and not camp_gueri:
		await _guerison()


func _reste_de_la_fievre() -> bool:
	return _malades.any(func(m: Gobelin) -> bool: return m.fievre)


func _reste_des_taches() -> bool:
	return _malades.any(func(m: Gobelin) -> bool: return m.taches)


## Les malades se relèvent, le camp change d'attitude, et la page des gobelins change de ton.
func _guerison() -> void:
	camp_gueri = true
	# Le camp peut aussi être soigné après le départ de Garin.
	if etape == Etape.QUETE:
		etape = Etape.GUERIS
		_fermer(_ronces_lisiere, false)
	lila.regard = Vector2.DOWN
	await Dialogue.dire(repliques_gueris)
	Carnet.marquer_apaisee(greg.analysable.espece)
	var garin_est_parti := etape == Etape.FIN
	lila.repliques = repliques_lila_apres_garin if garin_est_parti else repliques_lila_apres
	greg.repliques = repliques_greg_apres_garin if garin_est_parti else repliques_greg_apres
	for malade: Gobelin in _malades:
		malade.repliques = repliques_villageois_gueris


# --- Beat 6 : la lisière ---------------------------------------------------------

func _on_avant_lisiere(corps: Node2D) -> void:
	var quete_en_cours := etape == Etape.QUETE or etape == Etape.GUERIS
	if corps == gojo and quete_en_cours and not _ronces_lisiere.visible and not _avertissement_fait:
		_avertissement_fait = true
		Dialogue.dire(repliques_avant_lisiere)


## Passage à sens unique : les ronces se referment, et Garin Corbe arrive avec sa torche.
func _on_entree_lisiere(corps: Node2D) -> void:
	if corps != gojo or not (etape == Etape.QUETE or etape == Etape.GUERIS):
		return
	etape = Etape.BOSS
	_fermer(_ronces_lisiere, true)
	_point_de_reprise = _marqueur("RepriseLisiere")
	_montrer(garin, _marqueur("GarinEntree"))
	garin.marcher_vers(_marqueur("GarinCombat"))
	await garin.arrive
	await Dialogue.dire(repliques_garin_arrivee)
	_barre_boss.visible = true
	garin.commencer_combat()


## À mi-vie, Garin passe à la lame. Si les malades ont été soignés, les gobelins entrent
## dans le combat : ils étaient venus sauver leur copain, ils viennent maintenant sauver Gojo.
func _on_garin_deuxieme_phase() -> void:
	await Dialogue.dire(repliques_garin_lame)
	if not camp_gueri:
		return
	_renfort = [greg]
	for embusque: Gobelin in _embusques:
		_renfort.append(embusque)
	for i in _renfort.size():
		var gobelin := _renfort[i]
		_montrer(gobelin, _marqueur("Renfort%d" % (i + 1)))
		gobelin.passer_en_renfort(degats_du_renfort)
		gobelin.attaquer(garin)
	await Dialogue.dire(repliques_renfort)


## Garin à terre : deux issues, selon que sa page est complète ou non.
func _on_garin_a_terre() -> void:
	_barre_boss.visible = false
	for gobelin in _renfort:
		gobelin.s_arreter()
	await Dialogue.dire(repliques_garin_a_terre)
	if Carnet.est_complete(garin.analysable.espece):
		# Il attend : c'est Gojo qui lui tend le carnet (E).
		garin.attendre_le_carnet()
	else:
		await Dialogue.dire(repliques_fin_ouverte)
		garin.partir(_marqueur("GarinDepart"))
		await garin.parti
		_terminer(false)


## Page complète : Garin lit, se tait, laisse tomber sa torche et s'en va.
## Il laisse derrière lui sa liste de primes, le dernier objet de la tranche.
func _fin_du_carnet() -> void:
	await Dialogue.dire(repliques_fin_du_carnet)
	Carnet.marquer_apaisee(garin.analysable.espece)
	garin.lacher_torche()
	_montrer(_liste_de_primes, garin.global_position + Vector2(8, 0))
	garin.partir(_marqueur("GarinDepart"))


func _on_liste_ramassee(_gojo: Gojo) -> void:
	_cacher(_liste_de_primes)
	await Dialogue.dire(repliques_liste_de_primes)
	_terminer(true)


## La tranche est finie : la lisière se rouvre, le renfort rentre au camp, et le Dieu des
## monstres regarde une dernière fois, à l'orée du bois.
func _terminer(heureuse: bool) -> void:
	etape = Etape.FIN
	fin_heureuse = heureuse
	_fermer(_ronces_lisiere, false)
	_point_de_reprise = _marqueur("RepriseCamp")
	_rappeler_le_renfort()
	if camp_gueri:
		lila.repliques = repliques_lila_apres_garin
		greg.repliques = repliques_greg_apres_garin
	_silhouette_finale.apparaitre()
	_fin.get_node("SousTitre").text = texte_fin_du_carnet if heureuse else texte_fin_ouverte
	_fin.visible = true
	await get_tree().create_timer(duree_fin, false).timeout
	_fin.visible = false


func _rappeler_le_renfort() -> void:
	for i in _renfort.size():
		var gobelin := _renfort[i]
		gobelin.quitter_le_renfort()
		gobelin.regard = Vector2.DOWN
		var marqueur := "CampGreg" if gobelin == greg else "CampVillageois%d" % i
		_montrer(gobelin, _marqueur(marqueur))
	_renfort.clear()


# --- Reprise après un K.O. -----------------------------------------------------

func _on_gojo_ko() -> void:
	await get_tree().create_timer(duree_avant_reprise).timeout
	gojo.revivre(_point_de_reprise)
	# Tombé pendant le combat de boss : le combat recommence. Le carnet garde ses pages.
	if etape == Etape.BOSS and garin.se_bat():
		_rappeler_le_renfort()
		garin.reinitialiser(_marqueur("GarinCombat"))
		garin.commencer_combat()


# --- Outils --------------------------------------------------------------------

func _marqueur(nom: String) -> Vector2:
	return _marqueurs.get_node(nom).global_position


## Des ronces bouchent le passage (ou plus).
func _fermer(ronces: StaticBody2D, ferme: bool) -> void:
	ronces.visible = ferme
	ronces.get_node("CollisionShape2D").set_deferred("disabled", not ferme)


func _cacher(noeud: Node2D) -> void:
	if noeud is Gobelin:
		noeud.s_arreter()
	noeud.visible = false
	noeud.process_mode = Node.PROCESS_MODE_DISABLED


func _montrer(noeud: Node2D, position_depart: Vector2) -> void:
	noeud.global_position = position_depart
	noeud.reset_physics_interpolation()
	noeud.visible = true
	noeud.process_mode = Node.PROCESS_MODE_INHERIT

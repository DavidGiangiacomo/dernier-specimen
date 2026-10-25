class_name Espece
extends Resource
## Une espèce du carnet de terrain : la hure des souches, le gobelin, le rase-mousse…
##
## Chaque espèce est un fichier .tres qui se remplit dans l'inspecteur, sans toucher au code,
## à partir de la fiche de créature du GDD. Sa page commence en langage de laboratoire (« avant »)
## et passe en langage humain (« après ») quand une créature de l'espèce a été apaisée.

@export_group("Avant : langage de laboratoire")
## Ce que Gojo écrit avant de comprendre.
@export var nom_de_terrain := ""
## Une phrase froide, de savant.
@export_multiline var description_avant := ""

@export_group("Après : langage humain")
## Le vrai nom de l'espèce (dans le jeu complet, ce sont les gobelins qui l'apprennent à Gojo).
@export var nom_veritable := ""
## Ce que Gojo a compris.
@export_multiline var description_apres := ""

@export_group("Observations et clé")
## Une ligne par analyse réussie, dans l'ordre.
@export var observations: Array[String] = []
## Ce qui calme la créature sans la tuer. Elle n'apparaît qu'avec la dernière observation.
@export_multiline var cle := ""

@export_group("Dessin")
## Le croquis de la page. Tant qu'il est vide, un rectangle de la couleur de l'espèce le remplace.
@export var croquis: Texture2D
## Couleur provisoire de l'espèce, pour la reconnaître en attendant les croquis.
@export var couleur := Color.WHITE

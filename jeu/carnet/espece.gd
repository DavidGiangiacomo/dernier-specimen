class_name Espece
extends Resource
## Une espèce du carnet de terrain : la hure des souches, le gobelin, le rase-mousse…
##
## Chaque espèce est un fichier .tres qui se remplit dans l'inspecteur, sans toucher au code.
## Les observations et la clé arriveront au jalon 3.

## Ce que Gojo écrit avant de comprendre (voir la fiche de créature du GDD).
@export var nom_de_terrain := ""
## Couleur provisoire de l'espèce, pour la reconnaître sur sa page en attendant les croquis.
@export var couleur := Color.WHITE

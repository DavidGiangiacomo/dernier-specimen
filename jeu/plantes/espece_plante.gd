class_name EspecePlante
extends Espece
## Une plante de l'herbier. Une seule analyse suffit à remplir sa page, et elle n'a pas de clé.

enum Effet { FIEVRE, TACHES, TOXIQUE, ENDORT }

@export_group("Plante")
## Ce que fait la plante : faire tomber la fièvre, refermer les taches, empoisonner, endormir.
@export var effet := Effet.FIEVRE
## Ce que Gojo voit avant de l'avoir analysée : mousse-de-lune et ronce-rouge se ressemblent beaucoup.
@export var nom_apparent := ""
## Sa couleur avant d'avoir été analysée. Après, c'est la couleur de l'espèce (rubrique Dessin).
@export var couleur_apparente := Color.WHITE

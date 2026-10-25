extends Node
## Le carnet de terrain de Gojo. Il compte les analyses réussies de chaque espèce.
##
## C'est un « autoload » : il existe pendant toute la partie, même quand un niveau recommence.

## Émis à chaque analyse réussie.
signal page_changee(espece: Espece, analyses: int)

## Analyses réussies pour compléter une page. Le chiffre qui décide du rythme de toute la tranche.
@export var analyses_par_page := 3

var _analyses := {}


func analyses(espece: Espece) -> int:
	return _analyses.get(espece, 0)


func est_complete(espece: Espece) -> bool:
	return analyses(espece) >= analyses_par_page


func ajouter_analyse(espece: Espece) -> void:
	if est_complete(espece):
		return
	_analyses[espece] = analyses(espece) + 1
	page_changee.emit(espece, analyses(espece))


## Vide le carnet (utile pour les tests).
func effacer() -> void:
	_analyses.clear()

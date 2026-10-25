extends Node
## Le carnet de terrain de Gojo. Il compte les analyses réussies de chaque espèce,
## et retient les espèces dont une créature a été apaisée.
##
## C'est un « autoload » : il existe pendant toute la partie, même quand un niveau recommence.

## Émis à chaque changement d'une page : analyse réussie, ou espèce apaisée.
signal page_changee(espece: Espece, analyses: int)

## Analyses réussies pour compléter la page d'une créature. Le chiffre qui décide du rythme de toute la tranche.
@export var analyses_par_page := 3
## Analyses pour compléter la page d'une plante de l'herbier.
@export var analyses_par_plante := 1

var _analyses := {}
var _apaisees := {}
## Les espèces dans l'ordre où Gojo les a rencontrées : c'est l'ordre des pages.
var _ordre: Array[Espece] = []


func analyses(espece: Espece) -> int:
	return _analyses.get(espece, 0)


## Le nombre d'analyses qui complète la page de cette espèce.
func analyses_requises(espece: Espece) -> int:
	return analyses_par_plante if espece is EspecePlante else analyses_par_page


func est_complete(espece: Espece) -> bool:
	return analyses(espece) >= analyses_requises(espece)


## Vrai quand Gojo a compris l'espèce (une créature apaisée, ou les gobelins soignés) :
## la page parle alors en langage humain.
func est_apaisee(espece: Espece) -> bool:
	return _apaisees.get(espece, false)


func especes() -> Array[Espece]:
	return _ordre.duplicate()


func ajouter_analyse(espece: Espece) -> void:
	if est_complete(espece):
		return
	if not _ordre.has(espece):
		_ordre.append(espece)
	_analyses[espece] = analyses(espece) + 1
	page_changee.emit(espece, analyses(espece))


func marquer_apaisee(espece: Espece) -> void:
	if est_apaisee(espece):
		return
	if not _ordre.has(espece):
		_ordre.append(espece)
	_apaisees[espece] = true
	page_changee.emit(espece, analyses(espece))


## Vide le carnet (utile pour les tests).
func effacer() -> void:
	_analyses.clear()
	_apaisees.clear()
	_ordre.clear()

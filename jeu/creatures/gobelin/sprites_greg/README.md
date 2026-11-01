# Greg, le gobelin épargné

Huit directions, dérivées des sprites du gobelin du camp. **64 pixels
modifiés, zéro génération.**

Les fiches d'Alessio disent : *« Greg et Lila, 24 × 24, comme le gobelin,
avec le détail qui les distingue. »* Le détail retenu ici est un **foulard
rouge noué au cou** (`#c75146`, ombré `#8c2f2f`), repris de l'illustration
d'Alessio où le gobelin épargné en porte un.

**La ligne « à quoi on le reconnaît » de sa fiche n'est pas encore remplie.**
Ce foulard est donc une proposition, pas une décision : si Alessio veut autre
chose, le script qui l'a produit est à refaire en deux minutes.

## Pourquoi un foulard, et pas autre chose

Greg est **vu de dos en premier** : « Greg, seul, de dos dans le fourré. Le
jeu invite à l'attaquer. » Puis il se retourne. Le signe qui le distingue doit
donc se lire **de dos avant de se lire de face** — c'est le cas d'un foulard,
ça ne l'aurait pas été d'une cicatrice ou d'un œil manquant.

Une réserve à trancher : le rouge est la couleur que la palette associe au
danger, au sang et à Garin Corbe. Sur le premier gobelin ami du jeu, c'est
discutable. Si ça gêne, `#99763f` ou `#ddc89b` feraient un foulard tout aussi
lisible sans cette charge.

## Technique

Mêmes contraintes que le gobelin : canevas 32 × 32, **pieds à y = 27**,
`centered = false`, `offset = Vector2(-16, -28)`, zéro couleur hors palette,
un seul composant par sprite.

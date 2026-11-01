# Greg, le gobelin épargné

Huit directions, dérivées des sprites du gobelin du camp. **64 pixels
modifiés, zéro génération.**

Les fiches d'Alessio disent : *« Greg et Lila, 24 × 24, comme le gobelin,
avec le détail qui les distingue. »* Le détail retenu ici est un **foulard
sable noué au cou** (`#ddc89b`, ombré `#99763f`), repris de l'illustration
d'Alessio où le gobelin épargné en porte un.

**La ligne « à quoi on le reconnaît » de sa fiche n'est pas encore remplie.**
Ce foulard est donc une proposition, pas une décision : si Alessio veut autre
chose, le script qui l'a produit est à refaire en deux minutes.

## Pourquoi un foulard, et pas autre chose

Greg est **vu de dos en premier** : « Greg, seul, de dos dans le fourré. Le
jeu invite à l'attaquer. » Puis il se retourne. Le signe qui le distingue doit
donc se lire **de dos avant de se lire de face** — c'est le cas d'un foulard,
ça ne l'aurait pas été d'une cicatrice ou d'un œil manquant.

## Pourquoi sable, et plus rouge

Le foulard a d'abord été dessiné en rouge, d'après l'illustration. Mais le
rouge est la couleur que la palette et le GDD attribuent à **Garin Corbe** —
« Rouges : danger, sang, Garin Corbe ». La porter sur le premier gobelin ami
du jeu brouillait le signal.

Le sable `#ddc89b` tranche sur la peau verte comme sur la tunique brune, et
n'entre en concurrence avec rien. `#99763f` seul avait été envisagé, mais
c'est déjà la couleur claire de la tunique : le foulard s'y serait fondu. Il
sert donc d'ombre, pas de teinte principale.

Les trois signes du camp sont maintenant distincts : **sable** pour Greg,
**gris** pour Lila, **rouge** pour Garin.

## Technique

Mêmes contraintes que le gobelin : canevas 32 × 32, **pieds à y = 27**,
`centered = false`, `offset = Vector2(-16, -28)`, zéro couleur hors palette,
un seul composant par sprite.

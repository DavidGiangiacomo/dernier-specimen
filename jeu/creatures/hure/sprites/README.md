# Les sprites de la hure des souches

Huit directions, canevas 32 × 32, **pieds à y = 27** comme Gojo et le gobelin —
le même réglage Godot vaut pour les trois.

Large et basse : 25 px de large de profil contre 14 de face, là où Gojo fait
18 de large dans toutes les directions. La silhouette doit dire « bête », pas
« personnage ».

## L'épine, et pourquoi elle compte

Les fiches d'Alessio donnent la clé de la hure : **« une épine fichée dans
l'épaule, à retirer au gant. Sans l'épine, elle est apaisée : elle se promène
sans plus jamais charger. »**

L'épine est donc à la hure ce que le gant cyan est à Gojo : **le signal visuel
d'une mécanique**, et non un ornement. Elle est dessinée en `#ddc89b` sortant
d'une plaie enflammée en `#8c2f2f`, et elle dépasse au-dessus de la ligne du
dos — ce que confirme le `ColorRect` nommé `Epine` de `hure.tscn`.

**Elle est présente dans les huit directions**, de 6 à 8 pixels. C'était
l'enjeu principal : un joueur doit comprendre qu'il y a quelque chose à
retirer, quel que soit l'angle sous lequel il voit la bête.

Quand le jalon 3 permettra de la retirer, il faudra une seconde série de
sprites sans l'épine — l'état « apaisée ». Les mêmes fichiers, moins quatre
pixels : c'est faisable à la main, sans rien générer.

## D'où ils viennent

**Trois vues dessinées à la main** — face, profil droit et dos — au lieu des
deux habituelles, parce qu'un quadrupède se lit surtout de profil. Les cinq
autres générées pour **1 génération**, avec le gabarit quadrupède « ours »,
le plus proche d'un sanglier parmi ceux disponibles.

| Élément | Couleurs |
| --- | --- |
| Corps | `#6e5236`, dos éclairé `#99763f` |
| Soies, sabots | `#4a3828` |
| Groin | `#5c4a3d`, naseaux `#241c1a` |
| Défenses | `#efe2c4` |
| Épine | `#ddc89b`, plaie `#8c2f2f` |

**Zéro couleur hors de la palette du jeu, sur les huit directions.**

## Réparations déjà faites

Les pattes extérieures revenaient **détachées du corps** sur quatre directions
(`east`, `west`, `south`, `south-west`) : un défaut hérité des vues dessinées
à la main, où le bas du corps ne touchait pas le haut des pattes. Cinq pixels
de raccord ont suffi, ajoutés au plus court chemin vers le corps. Les huit
sprites sont maintenant d'un seul tenant.

**À vérifier après toute retouche** : que le sprite ne fasse qu'une seule
composante. Une patte détachée ne se voit pas à l'œil mais trahit un dessin
qui se défera à l'animation.

## Ce qui reste à corriger, à l'œil

- De trois quarts arrière (`north-east`, `north-west`), les défenses
  apparaissent comme **deux pixels blancs isolés** sur le côté : on ne
  comprend pas ce que c'est.
- La vue de dos est une masse brune assez plate.

## Comment corriger

1. Ouvrir le fichier dans Pixelorama.
2. Charger `jeu/palette/palette.gpl` et ne peindre qu'avec ces couleurs.
3. Garder les pieds sur la ligne y = 27, et l'épine visible.

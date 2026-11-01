# Les sprites du gobelin

Huit directions, canevas 32 × 32, contenu 18 à 19 px de haut, **pieds à
y = 27** comme Gojo — le même réglage Godot vaut donc pour les deux.

Le gobelin fait 18 px là où Gojo en fait 22. Cette différence est voulue :
c'est elle qui les distingue d'un coup d'œil quand ils sont côte à côte.

## D'où ils viennent

La vue de face et la vue de dos sont **dessinées à la main**, les six autres
générées pour **1 génération**. Sources : le placeholder du code
(`gobelin.tscn`, corps de 16 × 18 en vert), les fiches d'Alessio qui prévoient
le gobelin en 24 × 24, et son illustration.

| Élément | Couleurs |
| --- | --- |
| Peau | `#6a9c58`, clair `#9dc271`, sombre `#45784a` (oreilles) |
| Tunique | `#6e5236`, clair `#99763f` |
| Ceinture | `#5c4a3d` |
| Pieds | `#4a3828` |

**Zéro couleur hors de la palette du jeu, sur les huit directions.**

Les yeux sont en `#0d0f17` et non en ambre : la palette réserve `#f2c14e` à la
clé du gant, et un œil de gobelin ne doit pas entrer en concurrence avec un
signal de mécanique.

## Ce qui reste à corriger, à l'œil

- **Les oreilles disparaissent dans les vues de trois quarts.** Elles fondent
  dans la masse de la tête, qui se lit alors comme un buisson vert. C'est
  pourtant la signature de l'espèce : c'est le défaut le plus gênant.
- **Les profils (`east`, `west`) ne font que 9 px de large** : le gobelin y
  paraît filiforme.
- Les yeux sont à peine lisibles ailleurs que de face.

Le remède est le même que pour le sac à dos de Gojo : dessiner aussi la vue
de profil à la main et relancer. Une génération de plus.

## Comment corriger

1. Ouvrir le fichier dans Pixelorama.
2. Charger `jeu/palette/palette.gpl` et ne peindre qu'avec ces couleurs.
3. Garder les pieds sur la ligne y = 27.

## Les trois formes du gobelin

`gobelin.gd` donnait déjà trois tailles à son rectangle. Chacune a maintenant
son jeu de huit dessins.

| Fichiers | Forme | Quand |
| --- | --- | --- |
| `gobelin_<dir>.png` | debout, 18 px | normal |
| `gobelin_malade_<dir>.png` | couché, 9 px | `est_malade()` |
| `gobelin_malade_taches_<dir>.png` | couché, avec les taches | `taches` |
| `gobelin_bebe_<dir>.png` | 9 px, grosse tête | `bebe` |

Les taches sont posées aux emplacements exacts où le code mettait ses trois
`ColorRect`, convertis en coordonnées de texture. Le bébé était indispensable :
sans lui, les deux bébés du camp se seraient affichés en adultes — pire que le
rectangle qu'ils remplacent.

## La fièvre reste une teinte, et c'est voulu

Les deux symptômes sont **indépendants**, et c'est toute l'énigme des malades :
la fièvre se soigne à la mousse-de-lune, les taches au capuchon gris. Il faut
donc pouvoir les voir séparément et ensemble.

Les taches sont dans le dessin ; la fièvre reste une teinte. Les quatre
combinaisons sont ainsi couvertes avec deux jeux de dessins au lieu de quatre.

C'est pourquoi `etats_sans_teinte` est vide ici, alors que la hure y déclare
son état apaisé : là-bas la teinte délavait un dessin qui disait déjà tout,
ici elle ajoute un second symptôme.

## Ce qui reste à corriger, à l'œil

**Le gobelin couché se lit comme une pastille à taches.** La tête ne se
distingue pas du corps. Trois essais : tête agrandie, membres sortis, peau
portée de 25 % à 75 % du corps — c'est mieux, ce n'est pas bon. À 9 px de haut
il n'y a pas la place, et la fièvre qui pousse 45 % vers le rouge n'arrange
rien. C'est le dessin du jeu qui demande le plus à être repris à la main.

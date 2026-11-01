# Les sprites du rase-mousse

Huit directions, canevas **16 × 16** — la taille prévue par les fiches
d'Alessio, et non 24 × 24 comme les autres.

## Il vole : l'ancrage n'est pas le même

Les autres personnages posent les pieds à y = 27. Pas lui. Le code lui donne
un `Corps` qui flotte entre y = −12 et y = −6, et une **`Ombre` au sol comme
nœud séparé**. Le sprite ne contient donc que la bête ; l'ombre reste un nœud
Godot à part, et elle doit le rester — c'est elle qui dit au joueur à quelle
hauteur vole la bestiole.

```
centered = false
offset = Vector2(-8, -15)
```

Ce réglage place le centre du sprite là où le `Corps` provisoire est
aujourd'hui, à 9 px au-dessus du sol.

## D'où ils viennent

**Entièrement dessinés à la main, zéro génération.** Une bestiole volante vue
de dessus est symétrique gauche-droite : cinq vues suffisent — face, dos,
profil droit, trois-quarts avant et trois-quarts arrière — les trois autres
sont des miroirs horizontaux exacts.

| Élément | Couleurs |
| --- | --- |
| Ailes | `#9dc271`, bord `#6a9c58` |
| Corps, tête | `#1d3326` |
| Yeux | `#ddc89b` |
| Antennes, raie dorsale | `#45784a` |

**Zéro couleur hors palette, un seul composant par sprite.**

## Lisibilité, mesurée

Le corps est en vert très sombre et les yeux en crème pâle : à 16 px, deux
points clairs sur une masse sombre sont ce qui dit « créature qui regarde ».
Une première version en camaïeu de vert se lisait comme une pousse végétale.

Contraste du corps (luminance 43) avec les tuiles du jeu :

| Tuile | Écart |
| --- | --- |
| boue — son habitat | 30 |
| herbe | 47 |
| chemin, terre du camp, herbe sèche | 75 à 91 |
| **arbre** | **1 — le corps y disparaît** |

Le corps s'efface contre les arbres seulement. Les arbres sont des obstacles
et non du sol, et le rase-mousse vit dans la boue du creux humide : ce n'est
donc pas gênant. Et les ailes, à 174 de luminance, tranchent sur toutes les
tuiles sans exception — ce sont elles qui portent la lisibilité.

## Ce qui reste à corriger, à l'œil

- **Les profils (`east`, `west`) sont les plus faibles** : l'aile vue de
  tranche se lit comme une barre claire posée au-dessus d'une masse sombre,
  plutôt que comme une bête de profil.
- La bête est très plate. Une vraie nuée gagnerait à ce que les quatre
  individus ne soient pas identiques.

## Ce qu'il reste à dessiner, et qui ne coûtera rien

Les fiches prévoient : **vol 2 à 4 images, morsure 2, endormi 1, et le nid.**
L'état *endormi* est une seule image — ailes repliées, yeux fermés — et le
battement d'ailes se fait en déplaçant les ailes existantes. Tout cela se
dessine à la main, sans générer.

# Les dessins de l'interface

## Les cœurs

Trois images de **8 × 8**, une par état d'un cœur :

| Fichier | État |
| --- | --- |
| `coeur_vide.png` | 0 PV dans ce cœur |
| `coeur_demi.png` | 1 PV |
| `coeur_plein.png` | 2 PV |

`coeurs.gd` les charge dans cet ordre et se sert du **nombre de PV restants
dans le cœur comme indice** du tableau : `_dessins[rempli]`. Les trois noms
doivent donc rester ceux-là.

Un cœur vaut 2 PV, le côté fait 8 px et l'écart entre deux cœurs 3 px —
constantes `TAILLE` et `ECART` de `coeurs.gd`. Une image d'une autre taille
s'afficherait décalée : elles sont dessinées pour ce gabarit.

Si l'une des trois manque, `_charger_les_dessins()` renonce **en bloc** et les
rectangles provisoires reprennent la main. Pas de moitié de barre de vie avec
un cœur dessiné et deux rectangles.

# Les sprites de la zone

| Fichier | Taille | Ce que c'est |
| --- | --- | --- |
| `dieu_des_monstres.png` | 24 × 48 | la silhouette en lisière |
| `souche.png` | 16 × 16 | une souche, il y en a cinq — la hure s'y assomme |
| `baton.png` | 16 × 16 | le bâton ferré, au sol dans la clairière |
| `ronces.png` | 16 × 32 | les ronces qui ferment les passages |

Chacun remplace un rectangle provisoire **de la même taille**, et les pieds
tombent au même endroit. Les rectangles ne sont pas supprimés mais masqués :
la forme d'origine reste lisible dans la scène.

Les ronces font 32 px de haut et non 16 : leur rectangle allait de −16 à +16,
elles débordent de part et d'autre du passage qu'elles ferment. Elles sont
dessinées en brins qui se croisent plutôt qu'en mur plein — un premier essai
en rectangle rempli se lisait comme un bloc rouge, pas comme un enchevêtrement.

`RoncesFourre` est masqué au démarrage : ce premier passage est ouvert dès le
début. Les deux autres sont visibles.

## `dieu_des_monstres.png`

Canevas **24 × 48**, contenu 20 × 43, pieds à y = 46. Une seule image, comme
le prévoient les fiches : *« une seule image, sa silhouette (s'il apparaît en
lisière) »*. **Zéro génération.**

Le GDD est précis sur son rôle : *« Un sprite immobile, aperçu deux ou trois
fois en lisière, qui disparaît quand on s'approche. Zéro mécanique, gros effet
d'ambiance. »*

C'est donc **le seul personnage du jeu pour lequel la lisibilité n'est pas le
but.** Il doit être à peine déchiffrable. Le dessin en tire les conséquences :

- presque uniquement les deux noirs de la palette, `#0d0f17` et `#1b1f2d`,
  avec des taches de `#1d3326` — la mousse et l'écorce qui ont poussé sur lui ;
- **deux lueurs ternes en `#333a4d`** à la place des yeux, et non des yeux
  brillants : une lueur qu'on n'est pas sûr d'avoir vue inquiète davantage ;
- épaules de 20 px contre 14 au corps, bras pendants jusqu'aux genoux — c'est
  l'échelle et la posture qui disent « grand humanoïde non armé » ;
- bord déchiqueté : une masse aux bords lisses se lit comme un objet, une
  masse irrégulière comme un être.

Il fait **43 px de haut contre 22 à Gojo** : deux fois sa taille.

Comme il n'a pas de scène à lui, le placer tel quel dans la zone, aux pieds :

```
centered = false
offset = Vector2(-12, -47)
```

Attention à l'ordre d'affichage : il doit passer **derrière** les arbres de
lisière, jamais devant. C'est ce qui vend l'idée qu'on l'aperçoit entre eux.

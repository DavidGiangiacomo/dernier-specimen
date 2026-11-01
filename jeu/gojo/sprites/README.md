# Les sprites de Gojo

Huit directions, canevas 32 × 32 chacune. Le canevas fait 32 et non 24 parce
que c'est le format dans lequel PixelLab produit ses rotations ; le contenu,
lui, tient dans les 24 × 24 du GDD.

| Fichier | Direction |
| --- | --- |
| `gojo_south.png` | Bas (face) |
| `gojo_south-east.png` · `gojo_south-west.png` | Diagonales basses |
| `gojo_east.png` · `gojo_west.png` | Droite, gauche |
| `gojo_north-east.png` · `gojo_north-west.png` | Diagonales hautes |
| `gojo_north.png` | Haut (dos) |

**Les pieds posent sur la ligne y = 27 dans les huit fichiers.** C'est ce qui
évite que Gojo sautille d'un pixel quand le joueur tourne. Toute retouche doit
conserver cet alignement.

## D'où ils viennent

La vue de face a été dessinée au pixel près, puis validée. Les sept autres
directions en ont été pivotées par PixelLab pour **1 seule génération**, parce
que fournir la vue de face évite d'en payer la création (5 générations).
La vue de face du jeu est au pixel identique à celle qui a été validée.

## Le personnage

| Élément | Couleurs | Rôle |
| --- | --- | --- |
| Manteau | `#333a4d`, ombre `#1b1f2d`, col `#5a6375` | La masse du sprite |
| Chemise | `#e8d5b0` | Visible dans l'ouverture du manteau |
| Harnais du sac | `#6e5236` | Bretelles sur la poitrine, sac aux épaules |
| Cheveux | `#241c1a`, reflet `#3a2f2b` | Servent aussi de contour à la tête |
| Gant d'analyse | `#8fe3ff`, éclat `#d8f6ff`, creux `#3a9fc9` | Au bout du bras gauche |

**Zéro couleur hors de la palette du jeu, sur les huit directions.**

Le gant est visible dans six directions sur huit. Il disparaît de dos
(`north`, `north-west`), ce qui est correct : la main est devant le corps.
Si l'état du gant doit rester lisible de dos, il faudra le signaler autrement
qu'avec le sprite — une lueur au sol, ou sur la barre d'analyse.

## Intégration dans Godot

Le code ancre Gojo aux pieds (`gojo.tscn` : `Corps` va de `offset_top = -24`
à 0). Pour poser un de ces sprites au même endroit :

```
centered = false
offset = Vector2(-16, -28)
```

## Ce qui reste à corriger, à l'œil

- Les débords du sac aux épaules se lisent comme **des barres brunes
  horizontales**, surtout de trois quarts. C'est le défaut hérité de la vue
  de face, que la rotation a amplifié.
- Les vues de profil (`east`, `west`) sont **nettement plus étroites**
  (11-12 px contre 16-18) : Gojo paraît maigre de profil.
- `north-west` montre une tache claire à l'emplacement du visage, qui n'a
  rien à y faire sur une vue de dos.

Pour corriger : ouvrir le fichier dans Pixelorama, charger
`jeu/palette/palette.gpl`, ne peindre qu'avec ces couleurs, et garder les
pieds sur la ligne y = 27.

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

**Deux directions sont dessinées à la main** : la vue de face, validée, et la
vue de dos. Les six autres en ont été générées par PixelLab pour **1 seule
génération** — fournir des directions déjà dessinées évite d'en payer la
création, et fait baisser le prix à mesure qu'on en fournit.

La vue de dos a dû être dessinée parce que la première tentative n'en avait
pas : la vue de face ne montrait du sac que deux débords aux épaules, et une
rotation ne peut faire pivoter que ce qui existe. De dos, le modèle reproduisait
donc des épaulettes là où le sac devrait occuper tout le torse.

La vue de face du jeu est au pixel identique à celle qui a été validée.

### Le sac, par direction

| Direction | Bas | Bas-D | Droite | Haut-D | Haut | Haut-G | Gauche | Bas-G |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pixels de sac | 18 | 11 | 33 | 64 | **66** | 65 | 32 | 10 |

Invisible de face — on n'en voit que les bretelles —, bosse nette de profil,
dominant de dos. C'est la progression attendue d'un sac réellement porté.

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

- **La vue de face garde ses deux débords bruns aux épaules.** Ils passaient
  tant que le sac n'existait nulle part ; maintenant que les autres directions
  en montrent un vrai, ces deux barres détonnent. C'est la vue validée, donc
  elle n'a pas été touchée — mais elle mérite d'être reprise.
- De trois quarts arrière (`north-east`, `north-west`), **le sac est si gros
  que le corps disparaît derrière** : ça se lit comme une caisse brune sur
  deux jambes.
- De profil, le sac est posé **assez bas**, plutôt à hauteur de hanche que
  de haut du dos.

Pour corriger : ouvrir le fichier dans Pixelorama, charger
`jeu/palette/palette.gpl`, ne peindre qu'avec ces couleurs, et garder les
pieds sur la ligne y = 27.

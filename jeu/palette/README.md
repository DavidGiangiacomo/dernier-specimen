# La palette du Dernier Spécimen

**30 couleurs, une seule pour tout le jeu.** C'est une contrainte du GDD
(« Rend cohérent même un art débutant, et réduit les décisions »). Tout
sprite, toute tuile, toute icône du carnet se peint dans ces 30 couleurs
et dans aucune autre.

## Les fichiers

| Fichier | À quoi il sert |
| --- | --- |
| `palette.gpl` | **À charger dans Pixelorama** : menu des palettes, *Importer*. Format GIMP, lu aussi par Aseprite et Krita. |
| `palette_apercu.png` | L'aperçu lisible, avec le rôle de chaque couleur. À regarder, pas à importer. |
| `palette.png` | Bande de 30 × 1 px, pour les outils. C'est elle qu'on donne à `reduce_colors` de PixelLab pour forcer un sprite généré sur la palette du jeu. |

## Les quatre couleurs qui viennent du code

Celles-là n'ont pas été choisies ici : elles sont déjà dans `gojo.gd` et
`gojo.tscn`, et l'écran les affiche aujourd'hui. Les changer veut dire
changer le code en même temps.

| Couleur | Constante | Rôle |
| --- | --- | --- |
| `#8fe3ff` | `COULEUR_ANALYSE` | Le gant pendant une analyse, et la barre |
| `#f2c14e` | `COULEUR_CLE` | Le gant quand il applique la clé |
| `#fff8e8` | `couleur_roulade` | Le corps pendant la roulade |
| `#e8d5b0` | couleur du `Corps` | Le manteau de Gojo |

## La règle du cyan

`#8fe3ff` est le seul cyan saturé de la palette, et il est réservé à
l'analyse. Aucune plante, aucune créature, aucune tuile ne doit l'employer :
c'est ce qui fait que le gant saute aux yeux sur un sprite de 24 px, où il
n'occupe que deux pixels sur deux. Même logique pour `#f2c14e`, réservé à
la clé.

## Règle de lisibilité

Reprise du GDD : **une créature doit être reconnaissable à sa silhouette en
noir.** Si elle ne l'est pas, c'est la forme qu'il faut corriger, pas les
couleurs. Le test se fait en remplissant le sprite de `#0d0f17` sur fond
clair.

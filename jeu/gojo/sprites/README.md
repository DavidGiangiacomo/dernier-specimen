# Les sprites de Gojo

## `gojo_face.png` — la vue de face, à corriger

Canevas 32 × 32, contenu 18 × 22, **12 couleurs, toutes dans la palette du
jeu**. Le canevas fait 32 et non 24 parce que c'est le format que PixelLab
impose pour faire pivoter un sprite en 8 directions ; le contenu, lui, tient
dans les 24 × 24 du GDD.

**Ce fichier n'est pas de l'art définitif.** C'est une base dessinée au
pixel près pour remplacer une première génération IA inutilisable, dont le
manteau crème ne représentait que 7 pixels sur 240.

### Ce qui est acquis

- La silhouette passe le test du GDD : un seul composant, aucun trou,
  reconnaissable en noir.
- Le manteau crème est la masse dominante : 122 pixels sur ~240.
- Le gant cyan `#8fe3ff` est rattaché au bras et déborde de la silhouette.
- Zéro couleur hors palette.

### Ce qui reste à corriger, à l'œil

- La forme se lit encore comme **une robe pâle** plutôt que comme un long
  manteau de savant. L'ourlet s'évase trop régulièrement.
- Il n'y a **pas de taille** : le corps est un triangle du col à l'ourlet.
- Le **sac à dos est absent**, alors qu'il fait partie du personnage.
- Le gant ne fait que 4 pixels : visible, mais discret.

## Comment le corriger

1. Ouvrir `gojo_face.png` dans Pixelorama.
2. Charger `jeu/palette/palette.gpl` (menu des palettes, *Importer*) et
   **ne peindre qu'avec ces couleurs**.
3. Garder le contenu dans 24 × 24 et les pieds en bas : le code Godot ancre
   Gojo aux pieds (`gojo.tscn`, `offset_top = -24`).
4. Tester la silhouette : remplir la forme en `#0d0f17` sur fond clair. Si on
   ne reconnaît pas un humain en manteau, corriger la forme, pas les couleurs.

Une fois la vue de face bonne, les **8 directions coûtent 1 seule génération**
PixelLab : elles sont pivotées à partir de ce fichier.

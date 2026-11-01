# Les sprites de Gojo

## `gojo_face.png` — la vue de face

Canevas 32 × 32, contenu 18 × 22, **13 couleurs, toutes dans la palette du
jeu**. Le canevas fait 32 et non 24 parce que c'est le format que PixelLab
impose pour faire pivoter un sprite en 8 directions ; le contenu, lui, tient
dans les 24 × 24 du GDD, pieds en bas.

Dessiné au pixel près, pour remplacer une première génération IA inutilisable
dont le manteau ne représentait que 7 pixels sur 240.

### Le personnage

| Élément | Couleurs | Rôle |
| --- | --- | --- |
| Manteau | `#333a4d`, ombre `#1b1f2d`, col `#5a6375` | La masse : 92 px sur ~240 |
| Chemise | `#e8d5b0` | Visible dans l'ouverture du manteau |
| Harnais du sac | `#6e5236` | Bretelles sur la poitrine, bords du sac aux épaules |
| Cheveux | `#241c1a`, reflet `#3a2f2b` | Servent aussi de contour à la tête |
| Gant d'analyse | `#8fe3ff`, éclat `#d8f6ff`, creux `#3a9fc9` | Au bout du bras gauche |

Le manteau sombre n'est pas `#1b1f2d` malgré la consigne « gris très foncé » :
cette couleur est trop proche du contour `#0d0f17`, le sprite redeviendrait une
masse noire sur fond de forêt sombre. `#333a4d` avec `#1b1f2d` en ombre donne la
même lecture tout en gardant du relief. Bénéfice secondaire du manteau sombre :
le cyan du gant y ressort bien mieux que sur le crème d'origine.

### Ce qui est acquis

- Silhouette : un seul composant, aucun trou, profil épaules 16 → taille 10 →
  ourlet 18. Reconnaissable en noir, comme l'exige le GDD.
- Le manteau est la masse dominante.
- Zéro couleur hors palette.

### Ce qui reste à corriger, à l'œil

- Les débords du sac aux épaules se lisent comme **deux blocs bruns carrés**,
  plutôt que comme une besace portée dans le dos.
- Le passage épaules → taille est **abrupt** : le personnage paraît pincé au
  milieu plutôt que cintré.
- L'ourlet reste assez régulier pour du tissu lourd.

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

# Les tuiles du sol

Une seule bande, `tuiles.png`, de **144 × 16** : neuf tuiles de 16 × 16 posées
côte à côte, dans l'ordre où `tuiles.tres` les découpe.

| Colonne | Tuile | Solide |
| --- | --- | --- |
| 0 | herbe | non |
| 1 | herbe sombre | non |
| 2 | chemin | non |
| 3 | terre du camp | non |
| 4 | boue | non |
| 5 | herbe sèche | non |
| 6 | arbre | **oui** |
| 7 | buisson | **oui** |
| 8 | hutte | **oui** |

Les trois dernières portent un polygone de collision plein dans `tuiles.tres` :
ce sont les obstacles. Ajouter une tuile se fait **à la fin** de la bande, pour
que les colonnes déjà posées dans les scènes ne se décalent pas.

## Les couleurs ont changé

Les anciennes tuiles provisoires employaient des couleurs à elles
(`#4f6346` pour l'herbe, `#8a7350` pour le chemin…) qui **n'étaient dans la
palette du jeu**. Le GDD demande une seule palette pour tout le jeu, donc
chaque tuile a été refaite avec les couleurs de `jeu/palette/`.

Conséquence à connaître : **le sol a changé de teinte**. L'herbe est plus
franche, le chemin nettement plus chaud. Ce n'est pas un effet de bord, c'est
le but ; mais c'est visible, et c'est la seule modification de cette série qui
change l'allure générale du jeu.

Le choix des couleurs s'est fait **par le sens, pas par la distance**. Prendre
mécaniquement la couleur de palette la plus proche de l'ancienne donnait des
absurdités — « herbe sombre » tombait sur un brun. Chaque tuile a donc reçu la
couleur que son nom appelle, dans la rampe correspondante de la palette.

## Pourquoi si peu de pixels de pigment

Une tuile se répète des centaines de fois à l'écran. Tout ce qu'on y dessine
se répète avec elle, et **une forme dessinée devient une trame régulière** —
un motif de tapisserie, pas un terrain. C'est la contrainte qui gouverne les
neuf dessins :

- **Les sols** (herbe, chemin, boue…) sont une base unie piquée de 4 à 10
  pixels isolés. Isolés, donc sans couture d'une tuile à l'autre. Au-delà
  d'une dizaine, le grain devient du bruit ; en dessous de quatre, la tuile
  est plate.
- **L'arbre** est la bordure infranchissable de la zone : il couvre près de la
  moitié de l'écran. Les deux dessins « lisibles » essayés avant — une couronne
  concentrique, puis un disque qui déborde — donnaient l'un une rangée de
  caisses, l'autre un damier d'argyle. Ce qui marche est l'inverse : une masse
  sombre **faiblement contrastée**, faite de touffes qui mordent les bords et
  se soudent aux tuiles voisines. On ne voit plus la grille.
- **Le buisson** est isolé au milieu de l'herbe, et a donc **le fond de
  l'herbe** avec sa touffe au centre : il se pose dans une clairière sans y
  découper un carré, et ne se confond pas avec la lisière.
- **La hutte** garde ses lattes horizontales et son poteau, comme la tuile
  provisoire d'origine.

## Vérifié

- Aucune couleur hors de `jeu/palette/palette.png`.
- Relu en jeu, pas seulement en planche-contact : la trame des tuiles ne se
  juge qu'une fois répétée à l'écran.

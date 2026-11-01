# Les dessins des plantes

Quatre plantes, **deux images chacune**, en 16 × 16 comme le prévoient les
fiches. Le nom du fichier suit celui de la ressource d'espèce :

| Fichier | Ce que c'est |
| --- | --- |
| `mousse_de_lune_apparent.png` | ce que Gojo en voit **avant** de l'avoir analysée |
| `mousse_de_lune.png` | ce qu'il en voit **une fois l'espèce dans son herbier** |

`plante.gd` les trouve tout seul à partir du chemin de la ressource. Aucun
réglage à faire dans l'inspecteur : poser le fichier au bon nom suffit, et
tant qu'une des deux images manque, le rectangle provisoire reprend la main.

## Les deux qui se ressemblent

Le code dit déjà l'essentiel : `mousse_de_lune.tres` et `ronce_rouge.tres`
portent **le même `nom_apparent`** — « Mousse bleutée » — et **la même
`couleur_apparente`**. L'une fait tomber la fièvre, l'autre empoisonne.

Leurs deux images apparentes sont donc **identiques au pixel près**. C'est
l'énigme des malades : rien ne les distingue tant qu'on n'a pas pris le temps
d'analyser, et c'est ce qui donne sa valeur à l'analyse.

Une fois connues, elles n'ont plus rien à voir : la mousse-de-lune devient
pâle et froide, la ronce-rouge révèle son rouge et ses épines. C'est la
récompense, et elle se voit.

**Le test le vérifie en comparant les pixels**, pas les noms de fichiers :
deux fichiers distincts au contenu identique sont indiscernables pour le
joueur, et c'est tout ce qui est demandé. Si quelqu'un modifie une des deux
images sans l'autre, le test le dira.

## Couleurs réservées, et comment je les ai contournées

Deux couleurs de la palette sont réservées à des signaux de mécanique, et
aucune plante ne les emploie :

- `#8fe3ff` et sa rampe — l'analyse. La mousse-de-lune aurait aimé ce bleu
  pâle ; elle se contente de `#5a6375` et d'un reflet crème.
- `#f2c14e` — la clé du gant. La fleur-trompette est en `#ddc89b` et
  `#b5812a`, qui la rendent jaune sans entrer en concurrence.

Le rouge de la ronce, lui, ne pose pas de problème : la palette l'associe au
danger, et une plante toxique est exactement cela.

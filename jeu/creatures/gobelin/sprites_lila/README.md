# Lila, la doyenne du camp

Huit directions, dérivées des sprites du gobelin du camp. **191 pixels
modifiés, zéro génération.**

Le détail retenu est une **capuche grise** (`#5a6375`, ombrée `#333a4d`) qui
couvre le haut du crâne et retombe de chaque côté du visage, les oreilles
dépassant — repris de l'illustration d'Alessio, où la doyenne est encapuchonnée.

**La ligne « À quoi on voit que c'est elle, la doyenne » de sa fiche n'est pas
encore remplie.** Cette capuche est donc une proposition, pas une décision.

## Pourquoi une capuche

Comme Greg, Lila est **vue de dos en premier** : « Lila te tourne le dos. Elle
veille ses malades. » Une capuche est ce qui se lit le mieux de dos.

Le gris est aussi le seul endroit du jeu où cette couleur habille quelqu'un :
les gobelins sont en terre et en cuir, Gojo en gris très foncé. Une vieille en
gris pâle se repère immédiatement dans un camp de bruns et de verts.

## Technique

Mêmes contraintes que le gobelin : canevas 32 × 32, **pieds à y = 27**,
`centered = false`, `offset = Vector2(-16, -28)`, zéro couleur hors palette,
un seul composant par sprite.

## Ce qui manque encore

Elle n'est pas plus voûtée ni plus petite que les autres gobelins. Le GDD en
fait une **ancienne** : une silhouette un peu tassée la distinguerait encore
mieux, mais cela demande de redessiner le corps et non de le retoucher.

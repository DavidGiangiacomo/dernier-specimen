# Les sprites de Garin Corbe

Huit directions, canevas 32 × 32, **pieds à y = 27** comme Gojo et les
gobelins — même réglage Godot pour tous :

```
centered = false
offset = Vector2(-16, -28)
```

## Le miroir sombre de Gojo

Le GDD le décrit ainsi : *« Chasseur de primes humain, carnet à la ceinture.
Il veut être payé : il n'a rien contre les gobelins en particulier. Arbalète
à distance, lame au contact. »* Tous deux tiennent un carnet — l'un y consigne
des créatures, l'autre des primes. Le sien est dessiné à sa ceinture, en
`#ddc89b` : deux pixels qu'on ne remarquera presque pas, mais qui sont là.

Puisqu'ils s'affrontent, **le contraste avec Gojo est le critère de
conception** :

| | Gojo | Garin |
| --- | --- | --- |
| Manteau | gris-bleu froid `#333a4d` | brun chaud `#4a3828` |
| Tête | nu-tête, cheveux en bataille | **chapeau à large bord** |
| Peau | `#f0c9a4` | `#d19d73`, plus tannée : il vit dehors |
| Accent | cyan du gant `#8fe3ff` | ceinture rouge `#c75146` |

**Le chapeau fait 18 px de large contre 14 aux épaules.** C'est lui qui les
sépare en silhouette pure, instantanément — et Garin est le seul personnage
coiffé du jeu. Le test de silhouette du GDD est concluant : remplis en noir,
on les distingue sans hésiter.

Le rouge est explicitement **sa** couleur dans la palette du jeu
(« Rouges — Danger, sang, Garin Corbe »).

## L'arbalète

Elle est dessinée dans la vue de dos, sanglée en travers. C'est la leçon du
sac de Gojo et de l'épine de la hure : **une rotation ne peut faire pivoter
que ce qui existe**. Le dos a donc été dessiné à la main, comme la face.

## Ce qui reste à corriger, à l'œil

- **Il brandit ses armes dans six directions sur huit.** J'avais dessiné la
  lame au fourreau, à la hanche ; la génération en a fait une arme tenue à
  bout de bras, et l'arbalète avec. C'est juste pour un boss qui arrive
  brûler un camp, mais ce n'est pas une pose de *repos* — or les fiches
  prévoient « tir à l'arbalète 3 » et « coup de lame 3 » comme animations
  distinctes. À reprendre si le repos doit être neutre.
- De dos, l'arbalète se lit comme **un panneau clair sanglé**, pas comme une
  arme.

## Ce qui n'est pas dans ces sprites

**La torche.** Les fiches la listent séparément, et il ne la porte qu'à son
arrivée au jalon 5. À dessiner à part, pour pouvoir la lui faire lâcher à la
fin 2 : *« Gojo lui tend le carnet ; Garin lit, se tait, lâche sa torche et
s'en va. »*

## `garin_a_terre_*.png` — à genoux

Huit directions, **14 px de haut** au lieu de 22 — la hauteur que `garin.gd`
donnait déjà au rectangle en `Etat.A_TERRE`. Cinq vues dessinées à la main,
trois miroirs, zéro génération.

C'est le moment où Gojo lui tend le carnet, donc ce qui devait rester lisible :
le chapeau, qui le désigne ; la ceinture rouge ; et le carnet à sa ceinture.

Le tremblement d'avertissement avant un coup de lame est reporté sur le
dessin, comme il l'était sur le rectangle. La torche reste un nœud à part :
il la lâche à la fin, et `lacher_torche()` la dépose au sol.

# Le Dernier Spécimen

RPG d'action en vue de dessus où l'on progresse en comprenant les monstres plutôt qu'en les tuant.

| Fichier | Rôle |
| --- | --- |
| [`jeu/`](jeu/) | Le projet Godot du jeu. |
| [`docs/game-design-document.md`](docs/game-design-document.md) | Le Game Design Document, la version de référence à faire évoluer. |
| [`BOCAL_A_IDEES.md`](BOCAL_A_IDEES.md) | Le bocal à idées : toutes les idées qui ne sont pas dans le GDD, listées par date. |
| [`docs/fiches/fiches_alessio.pdf`](docs/fiches/fiches_alessio.pdf) | Les fiches d'Alessio, à imprimer en A4 : créatures, plantes, personnages, dialogues, plan de la zone, dessins, équilibrage, tests, décisions. |
| [`docs/archives/game-design-document-v1.pdf`](docs/archives/game-design-document-v1.pdf) | Le PDF d'origine de la v1 (24 octobre 2026), figé. |

## Lancer le jeu

1. Installer [Godot 4.7.2](https://godotengine.org/article/maintenance-release-godot-4-7-2/) (version standard, pas .NET). On garde cette version jusqu'à la fin de la tranche verticale.
2. Dans le gestionnaire de projets de Godot : **Importer**, puis choisir `jeu/project.godot`.
3. Appuyer sur **F5** pour jouer : on commence dans la clairière du Bois des Souches.
   Le terrain de test des premiers jalons reste disponible : ouvrir `jeu/terrain_de_test/terrain_de_test.tscn`, puis **F6**.

| Action | Clavier | Manette |
| --- | --- | --- |
| Se déplacer | Flèches, ou Z Q S D (W A S D sur un clavier QWERTY) | Stick gauche ou croix |
| Roulade | Espace | A (croix sur PlayStation) |
| Coup de bâton | J ou X | X (carré sur PlayStation) |
| Analyser, ou appliquer la clé (tenir, au contact) ; sans rien toucher, analyser la plante choisie dans la sacoche | K ou C | B (rond sur PlayStation) |
| Ouvrir ou fermer le carnet (jeu en pause) | Tab ou I | Select |
| Tourner les pages du carnet | Gauche, droite | Gauche, droite |
| Parler, ramasser, cueillir, donner la plante choisie, souffler le pollen, tendre le carnet | E ou Entrée | Y (triangle sur PlayStation) |
| Changer de plante choisie | R | RB (R1 sur PlayStation) |
| Passer à la ligne suivante d'un dialogue | E ou Entrée | Y |

**Régler les valeurs**, sans toucher au code : ouvrir la scène, cliquer sur le premier nœud, et changer les valeurs dans l'inspecteur.

| Scène | Nœud | Rubriques |
| --- | --- | --- |
| `jeu/gojo/gojo.tscn` | Gojo | *Marche*, *Roulade*, *Bâton*, *Gant*, *Vie* |
| `jeu/creatures/hure/hure.tscn` | Hure | *Vie*, *Errance*, *Charge* |
| `jeu/creatures/rase_mousse/rase_mousse.tscn` | RaseMousse | *Vie*, *Nuée*, *Pollen* |
| `jeu/creatures/gobelin/gobelin.tscn` | Gobelin | vitesses, durée et recharge des coups |
| `jeu/creatures/garin/garin.tscn` | Garin | *Vie*, *Phase 1 : l'arbalète*, *Phase 2 : la lame*, *Pollen* |
| `jeu/carnet/carnet.tscn` | Carnet | *Analyses par page*, *Analyses par plante* |
| `jeu/zone/bois_des_souches.tscn` | BoisDesSouches | *Combat du réflexe*, *Reprise*, *Le boss*, *Répliques*, *Fin provisoire* |

Les dégâts et le recul d'un coup se règlent sur sa hitbox : `Baton/Hitbox` pour Gojo, `HitboxCharge` pour la hure, `Lame/Hitbox` pour Garin. Les carreaux et les pièges de Garin ont leur propre scène (`carreau.tscn` : vitesse et durée de vol ; `piege.tscn`). L'invincibilité après un coup se règle sur la `Hurtbox` de chacun.

**Les espèces** du carnet sont des fichiers `.tres` à remplir dans l'inspecteur, à partir de la fiche de créature du GDD, par exemple `jeu/creatures/hure/hure.tres` ou `jeu/creatures/garin/garin.tres` :

| Rubrique | Champs | Quand la page les montre |
| --- | --- | --- |
| *Avant : langage de laboratoire* | Nom de terrain, description | Tant que l'espèce n'a pas été apaisée |
| *Après : langage humain* | Nom véritable, description | Une fois une créature de l'espèce apaisée |
| *Observations et clé* | Une observation par analyse, la clé | Une ligne par analyse réussie ; la clé avec la dernière |
| *Dessin* | Croquis (une image), couleur provisoire | Toujours ; la couleur remplace le croquis tant qu'il manque |

Les plantes de l'herbier (`jeu/plantes/*.tres`) ont en plus une rubrique *Plante* : leur effet, et le nom et la couleur qu'elles ont avant d'être analysées (la mousse-de-lune et la ronce-rouge se ressemblent).

Tous les textes sont provisoires, tirés du GDD : c'est à Alessio de les réécrire d'après ses fiches.

**Les fiches à remplir** sont dans [`docs/fiches/`](docs/fiches/) : le PDF à imprimer, et sa source `fiches_alessio.html`. Chaque fiche montre en gris le texte actuel du jeu, et dit où taper la version d'Alessio. Pour réimprimer après une modification du HTML : l'ouvrir dans Chrome, *Imprimer*, format A4, avec les graphiques d'arrière-plan.

## Le Bois des Souches

La zone de la tranche verticale est dans `jeu/zone/` :

- **La carte** (`carte.tscn`) : deux couches de tuiles, *Sol* et *Obstacles*, à repeindre avec l'éditeur de TileMap de Godot. Les tuiles sont provisoires (`tuiles/tuiles_provisoires.png`) ; arbres, buissons et huttes bloquent le passage.
- **Le déroulé** (`bois_des_souches.tscn`) : Greg, Lila, les villageois, les malades, la hure, les rase-mousses, les plantes, les ronces des passages à sens unique, puis la lisière et Garin Corbe. Les répliques de la quête se réécrivent dans l'inspecteur du nœud *BoisDesSouches*, rubrique *Répliques* ; celles de chaque gobelin, dans son propre inspecteur. Une réplique s'écrit `Nom : texte`, ou sans nom pour une description.
- **La lisière** : elle s'ouvre dès que Lila donne la quête (rubrique *Le boss* : on peut choisir qu'elle n'ouvre qu'une fois le camp soigné). On y entre sans retour possible avant la fin du combat. Garin tire à l'arbalète et pose des pièges, puis passe à la lame à mi-vie ; le pollen de fleur-trompette l'endort un court moment. Si le camp a été soigné, Greg et la meute viennent en renfort au début de la phase 2. À 0 PV, Garin tombe à genoux : page incomplète, il s'enfuit (fin ouverte) ; page complète, Gojo lui tend le carnet (E), et Garin laisse sa torche et sa liste de primes (la fin du carnet). Un écran de fin provisoire l'annonce, en attendant celui du jalon 6.
- **Le Dieu des monstres** (`jeu/dieu/silhouette.tscn`) : une silhouette muette, aperçue à la clairière d'arrivée et au vieux chêne, puis une dernière fois à la lisière après le départ de Garin. Elle s'efface quand Gojo s'approche, et ne revient pas.

## Tests automatiques

Des scripts jouent le jeu à notre place, sans fenêtre : ils appuient sur les touches, laissent passer les images, puis vérifient ce qui s'est passé (PV, position, étape de la quête, pages du carnet…).

| Fichier | Ce qu'il vérifie |
| --- | --- |
| `jeu/tests/test_terrain.gd` | Jalons 0 à 3, sur le terrain de test : déplacement, roulade, combat contre la hure, analyse au gant, carnet, clé |
| `jeu/tests/test_zone.gd` | Jalons 4 et 5 : la tranche jouée du début à la fin, jusqu'à Garin et la fin du carnet ; Garin affronté sans avoir soigné le camp (K.O., fin ouverte) ; les rase-mousses, l'analyse d'une plante dans la main, les silhouettes du Dieu |

**Sur GitHub**, ils tournent tout seuls à chaque pull request et à chaque push sur `main` (onglet *Actions*, ou les voyants en bas de la PR). Une PR au voyant rouge a cassé quelque chose.

**Sur l'ordinateur**, depuis le dossier du dépôt (Linux ou macOS) :

```sh
GODOT=/chemin/vers/Godot_v4.7.2 ./jeu/tests/lancer.sh
```

ou un seul fichier, sur n'importe quel système :

```sh
godot --headless --path jeu --script res://tests/test_zone.gd
```

Chaque vérification affiche `OK` ou `ECHEC`. Le hasard du jeu (les pas de la hure, le vol des rase-mousses) fait les mêmes tirages à chaque lancement : un test qui échoue échoue à chaque fois. Les tests de la zone prennent leurs repères sur les personnages et les objets de la scène, pas sur des coordonnées : on peut les déplacer sans casser les tests. En revanche, changer une règle du jeu (une durée, des dégâts, un nombre d'analyses) peut faire échouer un test qui la vérifie : c'est voulu, il suffit alors de mettre le test à jour.

## Faire évoluer le document

- **Modifier le GDD** : sur GitHub, ouvrir `docs/game-design-document.md`, cliquer sur le crayon, modifier, puis « Commit changes » avec un message qui dit ce qui change (par exemple « Nomme la doyenne »).
- **Une nouvelle idée** va dans le bocal, pas dans le GDD : c'est la règle du document.
- **Les schémas** sont écrits en [Mermaid](https://mermaid.js.org/) : on les modifie comme du texte, entre les balises ` ```mermaid `, et GitHub les redessine.
- **L'historique** de chaque modification se consulte avec le bouton « History » du fichier sur GitHub.

Le GDD a été importé depuis l'artifact Claude Docs
[Le dernier spécimen](https://claude.ai/artifact/73DcGhsCXbp5MzzFKNrHvF), qui n'est plus synchronisé :
c'est désormais le fichier Markdown qui fait foi.

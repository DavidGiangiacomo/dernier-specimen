# Le Dernier Spécimen

RPG d'action en vue de dessus où l'on progresse en comprenant les monstres plutôt qu'en les tuant.

| Fichier | Rôle |
| --- | --- |
| [`jeu/`](jeu/) | Le projet Godot du jeu. |
| [`docs/game-design-document.md`](docs/game-design-document.md) | Le Game Design Document, la version de référence à faire évoluer. |
| [`BOCAL_A_IDEES.md`](BOCAL_A_IDEES.md) | Le bocal à idées : toutes les idées qui ne sont pas dans le GDD, listées par date. |
| [`docs/archives/game-design-document-v1.pdf`](docs/archives/game-design-document-v1.pdf) | Le PDF d'origine de la v1 (24 octobre 2026), figé. |

## Lancer le jeu

1. Installer [Godot 4.7.2](https://godotengine.org/article/maintenance-release-godot-4-7-2/) (version standard, pas .NET). On garde cette version jusqu'à la fin de la tranche verticale.
2. Dans le gestionnaire de projets de Godot : **Importer**, puis choisir `jeu/project.godot`.
3. Appuyer sur **F5** pour jouer.

| Action | Clavier | Manette |
| --- | --- | --- |
| Se déplacer | Flèches, ou Z Q S D (W A S D sur un clavier QWERTY) | Stick gauche ou croix |
| Roulade | Espace | A (croix sur PlayStation) |
| Coup de bâton | J ou X | X (carré sur PlayStation) |
| Analyser (tenir, au contact) | K ou C | B (rond sur PlayStation) |

**Régler les valeurs**, sans toucher au code : ouvrir la scène, cliquer sur le premier nœud, et changer les valeurs dans l'inspecteur.

| Scène | Nœud | Rubriques |
| --- | --- | --- |
| `jeu/gojo/gojo.tscn` | Gojo | *Marche*, *Roulade*, *Bâton*, *Gant*, *Vie* |
| `jeu/creatures/hure/hure.tscn` | Hure | *Vie*, *Errance*, *Charge* |
| `jeu/carnet/carnet.tscn` | Carnet | *Analyses par page* |

Les dégâts et le recul d'un coup se règlent sur sa hitbox : `Baton/Hitbox` pour Gojo, `HitboxCharge` pour la hure. L'invincibilité après un coup se règle sur la `Hurtbox` de chacun.

**Les espèces** du carnet sont des fichiers `.tres` à remplir dans l'inspecteur, par exemple `jeu/creatures/hure/hure.tres` : nom de terrain et couleur provisoire pour l'instant. Les observations et la clé arriveront au jalon 3.

## Faire évoluer le document

- **Modifier le GDD** : sur GitHub, ouvrir `docs/game-design-document.md`, cliquer sur le crayon, modifier, puis « Commit changes » avec un message qui dit ce qui change (par exemple « Nomme la doyenne »).
- **Une nouvelle idée** va dans le bocal, pas dans le GDD : c'est la règle du document.
- **Les schémas** sont écrits en [Mermaid](https://mermaid.js.org/) : on les modifie comme du texte, entre les balises ` ```mermaid `, et GitHub les redessine.
- **L'historique** de chaque modification se consulte avec le bouton « History » du fichier sur GitHub.

Le GDD a été importé depuis l'artifact Claude Docs
[Le dernier spécimen](https://claude.ai/artifact/73DcGhsCXbp5MzzFKNrHvF), qui n'est plus synchronisé :
c'est désormais le fichier Markdown qui fait foi.

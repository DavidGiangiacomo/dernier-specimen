#!/usr/bin/env bash
# Lance tous les tests automatiques du jeu (jeu/tests/test_*.gd), sans fenêtre.
#
#   GODOT=/chemin/vers/Godot_v4.7.2-stable_linux.x86_64 ./jeu/tests/lancer.sh
#
# Sans GODOT, la commande « godot » est utilisée. Le script s'arrête en erreur
# si un test échoue, ou si un script GDScript plante en cours de route.

set -u
GODOT="${GODOT:-godot}"
JEU="$(cd "$(dirname "$0")/.." && pwd)"
SORTIE="$(mktemp)"
trap 'rm -f "$SORTIE"' EXIT

# Un dépôt tout juste cloné n'a pas encore le cache .godot : on importe d'abord.
"$GODOT" --headless --path "$JEU" --import > "$SORTIE" 2>&1
if grep -q "SCRIPT ERROR" "$SORTIE"; then
	cat "$SORTIE"
	echo "L'import du projet a échoué."
	exit 1
fi

echec=0
for fichier in "$JEU"/tests/test_*.gd; do
	test="res://tests/$(basename "$fichier")"
	echo
	echo "######## $test"
	"$GODOT" --headless --path "$JEU" --script "$test" 2>&1 | tee "$SORTIE"
	code=${PIPESTATUS[0]}
	if [ "$code" -ne 0 ] || grep -q "SCRIPT ERROR" "$SORTIE"; then
		echo "######## $test : ÉCHEC"
		echec=1
	fi
done

echo
if [ "$echec" -ne 0 ]; then
	echo "Des tests ont échoué."
	exit 1
fi
echo "Tous les tests sont passés."

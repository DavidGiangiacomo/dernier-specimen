extends Label
## L'invite en bas de l'écran : ce que Gojo peut faire avec ce qui est proche (« E : cueillir »).

@export var gojo: Gojo


func _ready() -> void:
	text = ""
	if gojo:
		gojo.invite_changee.connect(func(texte: String): text = texte)

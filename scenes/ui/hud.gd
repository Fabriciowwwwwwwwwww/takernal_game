extends CanvasLayer

@onready var corazones = [
	$Hearts/heart1,
	$Hearts/heart2,
	$Hearts/heart3
]

func actualizar_vidas(vida):
	for i in corazones.size():
		corazones[i].visible = i < vida

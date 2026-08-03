extends CanvasLayer

@onready var corazones = [
	$Hearts/heart1,
	$Hearts/heart2,
	$Hearts/heart3
]

@onready var barra = $ProgressBar

var progreso := 0
var vidas := 3


func perder_vida():
	vidas -= 1
	actualizar_corazones()


func sumar_progreso():
	progreso += 10
	
	if progreso > 100:
		progreso = 100
		
	barra.value = progreso


func actualizar_corazones():
	for i in corazones.size():
		corazones[i].visible = i < vidas

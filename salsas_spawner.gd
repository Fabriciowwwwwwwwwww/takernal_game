extends Node2D


@export_category("Salsas")

@export var armas: Array[NodePath]

@export var tiempos: Array[float]


func _ready():

	for i in range(armas.size()):

		var salsa = get_node(armas[i])

		var timer = Timer.new()

		add_child(timer)


		# Tiempo de esta salsa
		timer.wait_time = tiempos[i]

		timer.one_shot = false


		timer.timeout.connect(
			func():
				salsa.disparar()
		)


		timer.start()

extends Node2D

@export var bola_scene: PackedScene

@onready var timer = $Timer

var puntos_spawn = []


func _ready():

	puntos_spawn = [
		$Spawn1,
		$Spawn2,
		$Spawn3,
		$Spawn4
	]

	timer.timeout.connect(spawn_bolas)


func spawn_bolas():

	for punto in puntos_spawn:

		var bola = bola_scene.instantiate()

		get_parent().add_child(bola)

		bola.global_position = punto.global_position

		# dirección aleatoria
		var direccion = Vector2(
			randf_range(-1,1),
			randf_range(-1,1)
		).normalized()

		bola.iniciar_movimiento(direccion)

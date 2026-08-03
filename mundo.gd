extends Node2D

@export var jugador1: PackedScene
@export var jugador2: PackedScene

@onready var posicion_inicial: Marker2D = $Marker2D


func _ready():

	var centro = posicion_inicial.global_position


	# Instanciar Jugador 1
	var p1 = jugador1.instantiate()

	# Asignar controles jugador 1
	p1.jugador = "Jugador 1"

	add_child(p1)


	if GameManager.modo_juego == GameManager.ModoJuego.COOP:

		# Posición jugador 1
		p1.global_position = centro + Vector2(-40, 0)


		# Instanciar Jugador 2
		var p2 = jugador2.instantiate()

		# Asignar controles jugador 2
		p2.jugador = "Jugador 2"

		add_child(p2)


		# Posición jugador 2
		p2.global_position = centro + Vector2(40, 0)


	else:

		p1.global_position = centro

extends Node2D

@export var jugador1: PackedScene
@export var jugador2: PackedScene

@export var sprite_frame_jugador1: SpriteFrames
@export var sprite_frame_jugador2: SpriteFrames

@onready var posicion_inicial: Marker2D = $posicion_inicial

@export var nodo_puzle : Node2D 

# Arrastra aquí tu Sprite, Panel o Partículas
@export var imagen_victoria : Sprite2D 


@onready var musica: AudioStreamPlayer2D = $sonido_mundo

func _ready():
	musica.play()


	var centro = posicion_inicial.global_position


	# Instanciar Jugador 1
	var p1 = jugador1.instantiate()

	p1.jugador = "Jugador 1"
	p1.sprite_frame = sprite_frame_jugador1

	add_child(p1)


	if GameManager.modo_juego == GameManager.ModoJuego.COOP:

		p1.global_position = centro + Vector2(-40, 0)


		# Instanciar Jugador 2
		var p2 = jugador2.instantiate()

		p2.jugador = "Jugador 2"
		p2.sprite_frame = sprite_frame_jugador2

		add_child(p2)


		p2.global_position = centro + Vector2(40, 0)


	else:

		p1.global_position = centro

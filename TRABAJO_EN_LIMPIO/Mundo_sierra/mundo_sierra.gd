extends Node2D

# =========================================================
# JUGADORES
# =========================================================

@export_category("Escenas de jugadores")

@export var jugador1: PackedScene
@export var jugador2: PackedScene


# =========================================================
# SPRITE FRAMES - JUGADOR 1
# =========================================================

@export_category("SpriteFrames - Jugador 1")

@export var sprite_frames_condor_p1: SpriteFrames
@export var sprite_frames_cuy_p1: SpriteFrames


# =========================================================
# SPRITE FRAMES - JUGADOR 2
# =========================================================

@export_category("SpriteFrames - Jugador 2")

@export var sprite_frames_condor_p2: SpriteFrames
@export var sprite_frames_cuy_p2: SpriteFrames


# =========================================================
# NODOS
# =========================================================

@onready var posicion_inicial: Marker2D = $posicion_inicial
@onready var musica: AudioStreamPlayer2D = $sonido_mundo
@onready var enemigo = $EnemigoSierra


# =========================================================
# READY
# =========================================================

func _ready():

	musica.play()

	var centro: Vector2 = posicion_inicial.global_position


	# =====================================================
	# JUGADOR 1
	# =====================================================

	var p1 = jugador1.instantiate()

	p1.jugador = "Jugador 1"

	p1.sprite_frames_condor = sprite_frames_condor_p1
	p1.sprite_frames_cuy = sprite_frames_cuy_p1

	add_child(p1)

	p1.global_position = centro + Vector2(-40, 0)


	# =====================================================
	# JUGADOR 2
	# =====================================================

	var p2 = null

	if GameManager.modo_juego == GameManager.ModoJuego.COOP:

		p2 = jugador2.instantiate()

		p2.jugador = "Jugador 2"

		p2.sprite_frames_condor = sprite_frames_condor_p2
		p2.sprite_frames_cuy = sprite_frames_cuy_p2

		add_child(p2)

		p2.global_position = centro + Vector2(40, 0)


	# =====================================================
	# ENTREGAR JUGADORES AL ENEMIGO
	# =====================================================

	var jugadores: Array[Node2D] = [p1]

	if p2 != null:
		jugadores.append(p2)

	enemigo.asignar_jugadores(jugadores)

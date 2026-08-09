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

# IMPORTANTE:
# Ajusta esta ruta si tu CanvasLayer está en otro lugar.
@onready var hud: CanvasLayer = $CanvasLayer


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	print("======================================")
	print("=========== INICIANDO MUNDO ===========")
	print("======================================")

	if musica:
		musica.play()


	# =====================================================
	# DETECTAR MODO DE JUEGO
	# =====================================================

	var es_coop: bool = (
		GameManager.modo_juego == GameManager.ModoJuego.COOP
	)

	if es_coop:

		print("[MUNDO] MODO COOPERATIVO")

	else:

		print("[MUNDO] MODO UN JUGADOR")


	# =====================================================
	# POSICIÓN CENTRAL
	# =====================================================

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


	print("[MUNDO] Jugador 1 creado")


	# =====================================================
	# JUGADOR 2
	# =====================================================

	var p2 = null

	if es_coop:

		p2 = jugador2.instantiate()

		p2.jugador = "Jugador 2"

		p2.sprite_frames_condor = sprite_frames_condor_p2
		p2.sprite_frames_cuy = sprite_frames_cuy_p2

		add_child(p2)

		p2.global_position = centro + Vector2(40, 0)

		print("[MUNDO] Jugador 2 creado")


	# =====================================================
	# CREAR LISTA DE JUGADORES
	# =====================================================

	var jugadores: Array[Node2D] = [p1]

	if p2 != null:
		jugadores.append(p2)


	# =====================================================
	# ENTREGAR JUGADORES AL ENEMIGO
	# =====================================================

	if enemigo != null:

		if enemigo.has_method("asignar_jugadores"):

			enemigo.asignar_jugadores(jugadores)

			print(
				"[MUNDO] Jugadores entregados al enemigo: ",
				jugadores.size()
			)


	# =====================================================
	# CONECTAR MUNDO → HUD
	# =====================================================

	if hud != null:

		if hud.has_method("configurar_modo_juego"):

			hud.configurar_modo_juego(
				es_coop,
				jugadores
			)

			print("[MUNDO] HUD configurado correctamente")

		else:

			print(
				"[MUNDO] ERROR: El HUD no tiene ",
				"configurar_modo_juego()"
			)

	else:

		print(
			"[MUNDO] ERROR: CanvasLayer HUD no encontrado"
		)

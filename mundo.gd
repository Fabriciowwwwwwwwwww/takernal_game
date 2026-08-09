
extends Node2D

# =========================================================
# JUGADORES
# =========================================================

@export_category("Jugadores")

@export var jugador1: PackedScene
@export var jugador2: PackedScene

@export var sprite_frame_jugador1: SpriteFrames
@export var sprite_frame_jugador2: SpriteFrames


# =========================================================
# POSICIÓN
# =========================================================

@onready var posicion_inicial: Marker2D = $posicion_inicial


# =========================================================
# PUZLE
# =========================================================

@export_category("Puzle")

@export var nodo_puzle: Node2D


# =========================================================
# VICTORIA
# =========================================================

@export_category("Victoria")

@export var imagen_victoria: Sprite2D


# =========================================================
# MÚSICA
# =========================================================

@onready var musica: AudioStreamPlayer2D = $sonido_mundo


# =========================================================
# DIFICULTAD
# =========================================================

var es_coop: bool = false

# Multiplicador general de dificultad
var multiplicador_dificultad: float = 1.0

# Multiplicador de ingredientes
var multiplicador_ingredientes: float = 1.0

# Multiplicador de spawns
var multiplicador_spawn: float = 1.0


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	print("======================================")
	print("========== MUNDO PUZLE ===============")
	print("======================================")


	# ---------------------------------------------------------
	# MÚSICA
	# ---------------------------------------------------------

	if musica != null:
		musica.play()


	# ---------------------------------------------------------
	# DETERMINAR MODO DE JUEGO
	# ---------------------------------------------------------

	es_coop = (
		GameManager.modo_juego ==
		GameManager.ModoJuego.COOP
	)


	# =========================================================
	# JUGADOR 1
	# =========================================================

	var centro: Vector2 = posicion_inicial.global_position

	var p1 = jugador1.instantiate()

	p1.jugador = "Jugador 1"
	p1.sprite_frame = sprite_frame_jugador1

	add_child(p1)


	# =========================================================
	# MODO COOPERATIVO
	# =========================================================

	if es_coop:

		print("======================================")
		print("======= MODO COOPERATIVO =============")
		print("======= DIFICULTAD AUMENTADA ==========")
		print("======================================")


		# -----------------------------------------------------
		# CONFIGURAR DIFICULTAD
		# -----------------------------------------------------

		multiplicador_dificultad = 2.0
		multiplicador_ingredientes = 2.0
		multiplicador_spawn = 2.0


		# -----------------------------------------------------
		# JUGADOR 1
		# -----------------------------------------------------

		p1.global_position = centro + Vector2(-40, 0)


		# -----------------------------------------------------
		# JUGADOR 2
		# -----------------------------------------------------

		var p2 = jugador2.instantiate()

		p2.jugador = "Jugador 2"
		p2.sprite_frame = sprite_frame_jugador2

		add_child(p2)

		p2.global_position = centro + Vector2(40, 0)


		print("[MUNDO] Jugador 1 creado")
		print("[MUNDO] Jugador 2 creado")
		print("[MUNDO] Ingredientes x2")
		print("[MUNDO] Dificultad x2")
		print("[MUNDO] Spawns x2")


	# =========================================================
	# MODO UN JUGADOR
	# =========================================================

	else:

		print("======================================")
		print("======== MODO UN JUGADOR =============")
		print("======== DIFICULTAD NORMAL ===========")
		print("======================================")


		multiplicador_dificultad = 1.0
		multiplicador_ingredientes = 1.0
		multiplicador_spawn = 1.0


		p1.global_position = centro


	# =========================================================
	# ENVIAR CONFIGURACIÓN AL PUZLE
	# =========================================================

	configurar_puzle()


# =========================================================
# CONFIGURAR PUZLE
# =========================================================

func configurar_puzle() -> void:

	if nodo_puzle == null:

		print("[MUNDO] No hay nodo_puzle asignado")

		return


	# ---------------------------------------------------------
	# ENVIAR MULTIPLICADOR DE INGREDIENTES
	# ---------------------------------------------------------

	if nodo_puzle.has_method("configurar_dificultad"):

		nodo_puzle.configurar_dificultad(
			multiplicador_dificultad,
			multiplicador_ingredientes,
			multiplicador_spawn
		)

		print("[MUNDO] Dificultad enviada al puzle")


	# ---------------------------------------------------------
	# SI EL PUZLE UTILIZA VARIABLES DIRECTAS
	# ---------------------------------------------------------

	if "es_coop" in nodo_puzle:

		nodo_puzle.es_coop = es_coop


	if "multiplicador_ingredientes" in nodo_puzle:

		nodo_puzle.multiplicador_ingredientes = (
			multiplicador_ingredientes
		)


	if "multiplicador_dificultad" in nodo_puzle:

		nodo_puzle.multiplicador_dificultad = (
			multiplicador_dificultad
		)


	if "multiplicador_spawn" in nodo_puzle:

		nodo_puzle.multiplicador_spawn = (
			multiplicador_spawn
		)


# =========================================================
# FUNCIONES PARA OTROS NODOS
# =========================================================

func es_modo_coop() -> bool:

	return es_coop


func obtener_multiplicador_dificultad() -> float:

	return multiplicador_dificultad


func obtener_multiplicador_ingredientes() -> float:

	return multiplicador_ingredientes


func obtener_multiplicador_spawn() -> float:

	return multiplicador_spawn

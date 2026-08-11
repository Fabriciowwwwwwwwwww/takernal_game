
extends Node2D
@onready var canvas_how: CanvasLayer = $how
@export var tiempo_how: float = 3.0
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
# MÚSICA
# =========================================================

@onready var musica: AudioStreamPlayer2D = $AudioStreamPlayer2D


# =========================================================
# HUD
# =========================================================

@onready var hud: CanvasLayer = $Ui


# =========================================================
# DIFICULTAD
# =========================================================

var es_coop: bool = false

var multiplicador_dificultad: float = 1.0
var multiplicador_ingredientes: float = 1.0
var multiplicador_spawn: float = 1.0


# =========================================================
# VIDA DEL JEFE
# =========================================================

@export_category("Vida del Jefe")

# Vida normal
@export var vida_jefe_normal: int = 300

# En cooperativo +50%
@export var multiplicador_vida_jefe_coop: float = 1.5

var vida_jefe: int = 300


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	print("======================================")
	print("========== MUNDO PUZLE ===============")
	print("======================================")

	get_tree().paused = true

	print("[MUNDO] Juego pausado")
	print("[MUNDO] Mostrando HOW durante ", tiempo_how, " segundos")

	if canvas_how != null:
		canvas_how.show()

		# IMPORTANTE:
		# El Canvas debe seguir procesándose aunque el juego
		# esté pausado.
		canvas_how.process_mode = Node.PROCESS_MODE_ALWAYS
	# -----------------------------------------------------
	# MÚSICA
	# -----------------------------------------------------

	if musica != null:
		musica.play()


	# -----------------------------------------------------
	# DETERMINAR MODO
	# -----------------------------------------------------

	es_coop = (
		GameManager.modo_juego
		== GameManager.ModoJuego.COOP
	)


	# -----------------------------------------------------
	# CALCULAR VIDA DEL JEFE
	# -----------------------------------------------------

	if es_coop:

		vida_jefe = int(
			vida_jefe_normal
			* multiplicador_vida_jefe_coop
		)

	else:

		vida_jefe = vida_jefe_normal


	print(
		"[MUNDO] Vida normal del jefe: ",
		vida_jefe_normal
	)

	print(
		"[MUNDO] Vida final del jefe: ",
		vida_jefe
	)


	# -----------------------------------------------------
	# POSICIÓN
	# -----------------------------------------------------

	var centro: Vector2 = (
		posicion_inicial.global_position
	)


	# =====================================================
	# JUGADOR 1
	# =====================================================

	if jugador1 == null:

		push_error(
			"[MUNDO] jugador1 no está asignado"
		)

		return


	var p1: Node2D = jugador1.instantiate()

	p1.jugador = "Jugador 1"

	add_child(p1)

	p1.global_position = centro


	# -----------------------------------------------------
	# CONFIGURAR SPRITE JUGADOR 1
	# -----------------------------------------------------

	configurar_sprite_jugador(
		p1,
		sprite_frame_jugador1
	)


	# =====================================================
	# COOPERATIVO
	# =====================================================

	if es_coop:

		print("======================================")
		print("======= MODO COOPERATIVO =============")
		print("======================================")


		# -------------------------------------------------
		# DIFICULTAD
		# -------------------------------------------------

		multiplicador_dificultad = 2.0
		multiplicador_ingredientes = 2.0
		multiplicador_spawn = 2.0


		# -------------------------------------------------
		# POSICIÓN JUGADOR 1
		# -------------------------------------------------

		p1.global_position = (
			centro + Vector2(-40, 0)
		)


		# -------------------------------------------------
		# JUGADOR 2
		# -------------------------------------------------

		if jugador2 == null:

			push_error(
				"[MUNDO] jugador2 no está asignado"
			)

		else:

			var p2: Node2D = (
				jugador2.instantiate()
			)

			p2.jugador = "Jugador 2"

			add_child(p2)

			p2.global_position = (
				centro + Vector2(40, 0)
			)


			# ---------------------------------------------
			# CONFIGURAR SPRITE JUGADOR 2
			# ---------------------------------------------

			configurar_sprite_jugador(
				p2,
				sprite_frame_jugador2
			)


			print(
				"[MUNDO] Jugador 2 creado"
			)


		print(
			"[MUNDO] Jugador 1 creado"
		)

		print(
			"[MUNDO] Ingredientes x",
			multiplicador_ingredientes
		)

		print(
			"[MUNDO] Dificultad x",
			multiplicador_dificultad
		)

		print(
			"[MUNDO] Spawns x",
			multiplicador_spawn
		)

		print(
			"[MUNDO] JEFE +50% VIDA"
		)

		print(
			"[MUNDO] VIDA JEFE: ",
			vida_jefe
		)


	# =====================================================
	# UN JUGADOR
	# =====================================================

	else:

		print("======================================")
		print("======== MODO UN JUGADOR =============")
		print("======== DIFICULTAD NORMAL ===========")
		print("======================================")


		multiplicador_dificultad = 1.0
		multiplicador_ingredientes = 1.0
		multiplicador_spawn = 1.0


		p1.global_position = centro


		print(
			"[MUNDO] Jugador 1 creado"
		)

		print(
			"[MUNDO] JEFE: VIDA NORMAL"
		)

		print(
			"[MUNDO] VIDA JEFE: ",
			vida_jefe
		)


	# =====================================================
	# CONFIGURAR HUD
	# =====================================================

	call_deferred(
		"configurar_hud"
	)
	await mostrar_how()


# =========================================================
# CONFIGURAR SPRITE DEL JUGADOR
# =========================================================

func configurar_sprite_jugador(
	jugador: Node2D,
	sprite_frames: SpriteFrames
) -> void:

	if jugador == null:
		return


	if sprite_frames == null:

		print(
			"[MUNDO] No se asignaron SpriteFrames para: ",
			jugador.name
		)

		return


	# -----------------------------------------------------
	# BUSCAR AnimatedSprite2D
	# -----------------------------------------------------

	var animated_sprite: AnimatedSprite2D = (
		jugador.get_node_or_null(
			"AnimatedSprite2D"
		)
	)


	# -----------------------------------------------------
	# SI NO ESTÁ DIRECTAMENTE
	# BUSCAR ENTRE LOS HIJOS
	# -----------------------------------------------------

	if animated_sprite == null:

		for hijo in jugador.get_children():

			if hijo is AnimatedSprite2D:

				animated_sprite = hijo

				break


	# -----------------------------------------------------
	# SI NO SE ENCUENTRA
	# -----------------------------------------------------

	if animated_sprite == null:

		print(
			"[MUNDO] No se encontró AnimatedSprite2D en: ",
			jugador.name
		)

		return


	# -----------------------------------------------------
	# ASIGNAR SPRITEFRAMES
	# -----------------------------------------------------

	animated_sprite.sprite_frames = sprite_frames


	print(
		"[MUNDO] SpriteFrames asignado a: ",
		jugador.name
	)


# =========================================================
# CONFIGURAR HUD
# =========================================================

func configurar_hud() -> void:

	if hud == null:

		print(
			"[MUNDO] ERROR: No se encontró CanvasLayer"
		)

		return


	print(
		"[MUNDO] Configurando HUD..."
	)


	# =====================================================
	# CONFIGURAR MODO DE JUEGO
	# =====================================================

	if hud.has_method(
		"configurar_modo_juego"
	):

		var jugadores: Array[Node2D] = []

		var jugadores_en_escena := (
			get_tree().get_nodes_in_group(
				"jugador"
			)
		)


		for jugador in jugadores_en_escena:

			if jugador is Node2D:

				jugadores.append(
					jugador
				)


		hud.configurar_modo_juego(
			es_coop,
			jugadores
		)


	# =====================================================
	# CONFIGURAR VIDA DEL JEFE
	# =====================================================

	if hud.has_method(
		"configurar_vida_jefe"
	):

		hud.configurar_vida_jefe(
			vida_jefe
		)

	else:

		# -------------------------------------------------
		# COMPATIBILIDAD CON TU HUD
		# -------------------------------------------------

		if "vida_maxima_enemigo" in hud:

			hud.vida_maxima_enemigo = (
				vida_jefe
			)


		if "vida_enemigo" in hud:

			hud.vida_enemigo = (
				vida_jefe
			)


		if hud.has_method(
			"actualizar_barra_enemigo"
		):

			hud.actualizar_barra_enemigo()


	print(
		"[MUNDO] HUD configurado."
	)

	print(
		"[MUNDO] Vida final del jefe: ",
		vida_jefe
	)


# =========================================================
# MODO COOPERATIVO
# =========================================================

func es_modo_coop() -> bool:

	return es_coop


# =========================================================
# MULTIPLICADOR DE DIFICULTAD
# =========================================================

func obtener_multiplicador_dificultad() -> float:

	return multiplicador_dificultad


# =========================================================
# MULTIPLICADOR DE INGREDIENTES
# =========================================================

func obtener_multiplicador_ingredientes() -> float:

	return multiplicador_ingredientes


# =========================================================
# MULTIPLICADOR DE SPAWN
# =========================================================

func obtener_multiplicador_spawn() -> float:

	return multiplicador_spawn


# =========================================================
# VIDA DEL JEFE
# =========================================================

func obtener_vida_jefe() -> int:

	return vida_jefe


# =========================================================
# MULTIPLICADOR VIDA JEFE
# =========================================================

func obtener_multiplicador_vida_jefe() -> float:

	if es_coop:

		return multiplicador_vida_jefe_coop

	return 1.0

func mostrar_how() -> void:

	# Esperar 6 segundos aunque el juego esté pausado
	await get_tree().create_timer(
		tiempo_how,
		true
	).timeout


	# ---------------------------------------------------------
	# OCULTAR HOW
	# ---------------------------------------------------------

	if canvas_how != null:
		canvas_how.hide()


	# ---------------------------------------------------------
	# QUITAR PAUSA
	# ---------------------------------------------------------

	get_tree().paused = false

	print("[MUNDO] HOW terminado")
	print("[MUNDO] Juego iniciado")

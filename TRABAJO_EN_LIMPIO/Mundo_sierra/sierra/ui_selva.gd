extends CanvasLayer

# =========================================================
# ESTADO
# =========================================================

var juego_ganado: bool = false
var game_over_activo: bool = false

# =========================================================
# MODO DE JUEGO
# =========================================================

var modo_coop: bool = false
var jugadores_activos: Array[Node2D] = []

# =========================================================
# JEFE / VIDA DEL ENEMIGO
# =========================================================

@export_category("Jefe")

@export var jefe: Node2D

# ---------------------------------------------------------
# LA VIDA DEL ENEMIGO SE CONTROLA AQUÍ
# ---------------------------------------------------------

@export var vida_maxima_enemigo: int = 300

var vida_enemigo: int = 300

# Daño que recibe por cada bala
@export var daño_por_bala: int = 1

# =========================================================
# VICTORIA
# =========================================================

@export_category("Victoria")

@export_file("*.tscn") var siguiente_escena: String

@export var tiempo_antes_siguiente_nivel: float = 4.0

@onready var victoria: CanvasLayer = (
	$"../CanvasLayer_victoria"
)

@onready var personaje_victoria: AnimatedSprite2D = (
	$"../CanvasLayer_victoria/AnimatedSprite2D"
)

# =========================================================
# BARRA DEL JEFE
# =========================================================

@onready var barra_progreso: ProgressBar = (
	$BarraProgreso
)

# =========================================================
# CORAZONES
# =========================================================

@onready var corazones = [
	$Hearts/heart1,
	$Hearts/heart2,
	$Hearts/heart3,
	$Hearts/heart4,
	$Hearts/heart5,
	$Hearts/heart6,
	$Hearts/heart7,
	$Hearts/heart8,
]

# =========================================================
# VIDAS DEL JUGADOR
# =========================================================

@export_category("Vidas")

@export var vidas_maximas: int = 8

var vidas: int = 8

# =========================================================
# GAME OVER
# =========================================================

@export_category("Game Over")

@export_file("*.tscn") var escena_game_over


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	print("======================================")
	print("[HUD SELVA] READY")
	print("======================================")

	# =====================================================
	# VIDA DEL ENEMIGO
	# =====================================================

	vida_enemigo = vida_maxima_enemigo

	print(
		"[HUD SELVA] Vida enemigo: ",
		vida_enemigo,
		"/",
		vida_maxima_enemigo
	)

	actualizar_barra_enemigo()


	# =====================================================
	# VIDAS DEL JUGADOR
	# =====================================================

	vidas = vidas_maximas

	actualizar_corazones()


	# =====================================================
	# JEFE
	# =====================================================

	if jefe == null:

		print(
			"[HUD SELVA] ERROR: Jefe no asignado"
		)

	else:

		print(
			"[HUD SELVA] Jefe encontrado: ",
			jefe.name
		)


	# =====================================================
	# BUSCAR JUGADORES
	# =====================================================

	call_deferred(
		"conectar_jugadores"
	)


# =========================================================
# CONECTAR JUGADORES
# =========================================================

func conectar_jugadores() -> void:

	var jugadores := get_tree().get_nodes_in_group(
		"jugador"
	)

	print(
		"[HUD SELVA] Jugadores encontrados: ",
		jugadores.size()
	)

	for jugador_actual in jugadores:

		if jugador_actual == null:
			continue

		if not jugadores_activos.has(
			jugador_actual
		):

			jugadores_activos.append(
				jugador_actual
			)

		# -------------------------------------------------
		# SEÑAL DE GOLPE
		# -------------------------------------------------

		if jugador_actual.has_signal(
			"golpe_recibido"
		):

			if not jugador_actual.golpe_recibido.is_connected(
				_on_jugador_golpe_recibido
			):

				jugador_actual.golpe_recibido.connect(
					_on_jugador_golpe_recibido
				)

				print(
					"[HUD SELVA] Jugador conectado: ",
					jugador_actual.name
				)


# =========================================================
# RECIBIR DAÑO DEL ENEMIGO
#
# ESTA ES LA FUNCIÓN QUE DEBE LLAMAR LA BALA
# =========================================================

func recibir_daño_enemigo(cantidad: int = 1) -> void:

	if juego_ganado:
		return

	if game_over_activo:
		return

	if vida_enemigo <= 0:
		return


	# -----------------------------------------------------
	# RESTAR VIDA
	# -----------------------------------------------------

	vida_enemigo -= cantidad

	vida_enemigo = clamp(
		vida_enemigo,
		0,
		vida_maxima_enemigo
	)


	print(
		"[HUD SELVA] ¡ENEMIGO RECIBIÓ DAÑO!"
	)

	print(
		"[HUD SELVA] Vida enemigo: ",
		vida_enemigo,
		"/",
		vida_maxima_enemigo
	)


	# -----------------------------------------------------
	# ACTUALIZAR BARRA
	# -----------------------------------------------------

	actualizar_barra_enemigo()


	# -----------------------------------------------------
	# COMPROBAR DERROTA
	# -----------------------------------------------------

	if vida_enemigo <= 0:

		print(
			"[HUD SELVA] ¡VIDA DEL ENEMIGO EN 0!"
		)

		_on_jefe_derrotado()


# =========================================================
# ACTUALIZAR BARRA DEL ENEMIGO
# =========================================================

func actualizar_barra_enemigo() -> void:

	if barra_progreso == null:
		return

	barra_progreso.max_value = (
		vida_maxima_enemigo
	)

	barra_progreso.value = (
		vida_enemigo
	)


# =========================================================
# GOLPE RECIBIDO POR JUGADOR
# =========================================================

func _on_jugador_golpe_recibido() -> void:

	if juego_ganado:
		return

	if game_over_activo:
		return

	print(
		"[HUD SELVA] ¡JUGADOR RECIBIÓ DAÑO!"
	)

	perder_vida()


# =========================================================
# PERDER VIDA DEL JUGADOR
# =========================================================

func perder_vida() -> void:

	if vidas <= 0:
		return


	# -----------------------------------------------------
	# CORAZÓN ACTUAL
	# -----------------------------------------------------

	var indice := vidas - 1

	vidas -= 1


	print(
		"[HUD SELVA] Corazones restantes: ",
		vidas
	)


	# -----------------------------------------------------
	# ANIMACIÓN
	# -----------------------------------------------------

	if (
		indice >= 0
		and indice < corazones.size()
	):

		var corazon: AnimatedSprite2D = (
			corazones[indice]
		)

		if corazon != null:

			corazon.visible = true

			corazon.play(
				"romper"
			)

			await corazon.animation_finished

			if is_instance_valid(corazon):

				corazon.visible = false


	# -----------------------------------------------------
	# ACTUALIZAR
	# -----------------------------------------------------

	actualizar_corazones()


	# -----------------------------------------------------
	# GAME OVER
	# -----------------------------------------------------

	if vidas <= 0:

		game_over_activo = true

		await preparar_game_over()


# =========================================================
# ACTUALIZAR CORAZONES
# =========================================================

func actualizar_corazones() -> void:

	for i in range(corazones.size()):

		var corazon = corazones[i]

		if corazon == null:
			continue

		if i < vidas:

			corazon.visible = true

			corazon.play(
				"idle"
			)

		else:

			corazon.visible = false


# =========================================================
# PREPARAR GAME OVER
# =========================================================

func preparar_game_over() -> void:

	print(
		"[HUD SELVA] Preparando Game Over"
	)


	# -----------------------------------------------------
	# DESACTIVAR JUGADORES
	# -----------------------------------------------------

	for jugador_actual in jugadores_activos:

		if jugador_actual == null:
			continue

		if not is_instance_valid(
			jugador_actual
		):
			continue

		if jugador_actual.has_method(
			"soltar_cuy_y_caer"
		):

			jugador_actual.soltar_cuy_y_caer()


	# -----------------------------------------------------
	# ESPERAR
	# -----------------------------------------------------

	await get_tree().create_timer(
		2.0
	).timeout


	# -----------------------------------------------------
	# MOSTRAR GAME OVER
	# -----------------------------------------------------

	mostrar_game_over()


# =========================================================
# MOSTRAR GAME OVER
# =========================================================

func mostrar_game_over() -> void:

	get_tree().paused = false

	if escena_game_over.is_empty():

		print(
			"[GAME OVER] NO HAY ESCENA ASIGNADA"
		)

		return


	var escena_actual := (
		get_tree().current_scene.scene_file_path
	)

	print(
		"[GAME OVER] Escena actual: ",
		escena_actual
	)


	var game_over = load(
		escena_game_over
	).instantiate()


	if game_over.has_method(
		"configurar_escena_anterior"
	):

		game_over.configurar_escena_anterior(
			escena_actual
		)


	get_tree().current_scene.add_child(
		game_over
	)


# =========================================================
# JEFE DERROTADO
# =========================================================

func _on_jefe_derrotado() -> void:

	if juego_ganado:
		return


	print(
		"======================================"
	)

	print(
		"========= JEFE SELVA DERROTADO ======="
	)

	print(
		"======================================"
	)


	ganar_juego()


# =========================================================
# GANAR JUEGO
# =========================================================

func ganar_juego() -> void:

	if juego_ganado:
		return


	juego_ganado = true


	# -----------------------------------------------------
	# DETENER JEFE
	# -----------------------------------------------------

	if jefe != null:

		if jefe.has_method(
			"detener_combate"
		):

			jefe.detener_combate()


	# -----------------------------------------------------
	# DETENER JUGADORES
	# -----------------------------------------------------

	for jugador_actual in jugadores_activos:

		if jugador_actual == null:
			continue

		if is_instance_valid(
			jugador_actual
		):

			if jugador_actual.has_method(
				"hacer_invulnerable"
			):

				jugador_actual.hacer_invulnerable(
					true
				)

			if jugador_actual is CharacterBody2D:

				jugador_actual.velocity = (
					Vector2.ZERO
				)


	# -----------------------------------------------------
	# VICTORIA
	# -----------------------------------------------------

	if victoria != null:

		victoria.visible = true

		victoria.process_mode = (
			Node.PROCESS_MODE_ALWAYS
		)


	# -----------------------------------------------------
	# PERSONAJE
	# -----------------------------------------------------

	if personaje_victoria == null:

		print(
			"[VICTORIA] AnimatedSprite2D no encontrado"
		)

		get_tree().paused = true

		return


	personaje_victoria.visible = true

	personaje_victoria.play(
		"idle"
	)


	# -----------------------------------------------------
	# POSICIONES
	# -----------------------------------------------------

	var posicion_inicial := Vector2(
		-150.0,
		300.0
	)

	var posicion_final := Vector2(
		640.0,
		300.0
	)


	personaje_victoria.position = (
		posicion_inicial
	)


	# -----------------------------------------------------
	# PAUSAR
	# -----------------------------------------------------

	get_tree().paused = true


	# -----------------------------------------------------
	# TWEEN
	# -----------------------------------------------------

	var tween := create_tween()

	tween.set_pause_mode(
		Tween.TWEEN_PAUSE_PROCESS
	)

	tween.set_trans(
		Tween.TRANS_QUAD
	)

	tween.set_ease(
		Tween.EASE_OUT
	)


	tween.tween_property(
		personaje_victoria,
		"position",
		posicion_final,
		2.0
	)


	await tween.finished


	personaje_victoria.play(
		"idle"
	)


	print(
		"[VICTORIA] Personaje llegó al centro"
	)


	# -----------------------------------------------------
	# ESPERAR
	# -----------------------------------------------------

	var timer := get_tree().create_timer(
		tiempo_antes_siguiente_nivel,
		true
	)

	await timer.timeout


	cambiar_al_siguiente_nivel()


# =========================================================
# CAMBIAR DE NIVEL
# =========================================================

func cambiar_al_siguiente_nivel() -> void:

	get_tree().paused = false


	if siguiente_escena.is_empty():

		print(
			"[VICTORIA] No hay siguiente escena"
		)

		return


	print(
		"[VICTORIA] Cargando: ",
		siguiente_escena
	)


	get_tree().change_scene_to_file(
		siguiente_escena
	)


# =========================================================
# CONFIGURAR MODO DE JUEGO
# =========================================================

func configurar_modo_juego(
	es_coop: bool,
	jugadores: Array[Node2D]
) -> void:

	modo_coop = es_coop

	jugadores_activos = jugadores


	print(
		"[HUD SELVA] Modo coop: ",
		modo_coop
	)


	# -----------------------------------------------------
	# CONECTAR JUGADORES
	# -----------------------------------------------------

	for jugador_actual in jugadores_activos:

		if jugador_actual == null:
			continue

		if jugador_actual.has_signal(
			"golpe_recibido"
		):

			if not jugador_actual.golpe_recibido.is_connected(
				_on_jugador_golpe_recibido
			):

				jugador_actual.golpe_recibido.connect(
					_on_jugador_golpe_recibido
				)

# =========================================================
# CONFIGURAR VIDA DEL JEFE DESDE EL MUNDO
# =========================================================

func configurar_vida_jefe(nueva_vida: int) -> void:

	vida_maxima_enemigo = nueva_vida
	vida_enemigo = nueva_vida

	print(
		"[HUD SELVA] Vida del jefe configurada: ",
		vida_enemigo,
		"/",
		vida_maxima_enemigo
	)

	actualizar_barra_enemigo()

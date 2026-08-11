extends CanvasLayer
var juego_ganado: bool = false


# =========================================================
# MODO DE JUEGO
# =========================================================

var modo_coop: bool = false

var jugadores_activos: Array[Node2D] = []


# =========================================================
# CONFIGURACIÓN NORMAL
# =========================================================

const VIDA_NORMAL: float = 150.0


# =========================================================
# CONFIGURACIÓN COOPERATIVA
# =========================================================

const VIDA_COOP: float = 300.0


# =========================================================
# MULTIPLICADOR DE CAOS
# =========================================================

var multiplicador_caos: float = 1.0
# =========================================================
# JUGADOR
# =========================================================
# =========================================================
# VICTORIA
# =========================================================

@export_category("Victoria")

@export_file("*.tscn") var siguiente_escena: String

@export var tiempo_antes_siguiente_nivel: float = 4.0

@export_category("Jugador")
@export var jugador: Node2D

@onready var sonido_victoria: AudioStreamPlayer = $"../sonido_victoria"


@onready var spawn: Node2D = $"../Spawner"
@onready var spawn2: Node2D = $"../AtaqueNaves"
@onready var victoria: CanvasLayer = $"../CanvasLayer_victoria"
@onready var personaje_victoria: AnimatedSprite2D = $"../CanvasLayer_victoria/AnimatedSprite2D"

# =========================================================
# BARRA DE PROGRESO
# =========================================================

@onready var barra_progreso: ProgressBar = $BarraProgreso


# =========================================================
# CORAZONES
# =========================================================

@onready var corazones = [
	$Hearts/heart1,
	$Hearts/heart2,
	$Hearts/heart3,
	$Hearts/heart4,
	$Hearts/heart5
]


# =========================================================
# GAME OVER
# =========================================================

@export_file("*.tscn") var escena_game_over


# =========================================================
# VIDAS
# =========================================================

var vidas := 5


# =========================================================
# VIDA / PROGRESO DEL ENEMIGO
# =========================================================

@export_category("Vida del enemigo")

@export var vida_maxima_enemigo: float = 150.0

var progreso_enemigo: float = 150.0

# Cada cuánto daño se activa una oleada
# =========================================================
# ATAQUES POR PORCENTAJE DE VIDA
# =========================================================

@export_category("Ataques por vida")

# Cada cuánto porcentaje de vida perdida se activa un ataque
@export_range(1.0, 50.0, 1.0)
var porcentaje_por_ataque: float = 10.0

var siguiente_porcentaje_vida: float = 90.0
# =========================================================
# ATAQUES AUTOMÁTICOS
# =========================================================

@export_category("Ataques automáticos")

# Activar/desactivar ataques que ocurren sin hacer daño
@export var ataques_automaticos: bool = true

# Tiempo mínimo entre ataques automáticos
@export var tiempo_minimo_ataque: float = 4.0

# Tiempo máximo entre ataques automáticos
@export var tiempo_maximo_ataque: float = 8.0

var ataque_automatico_activo: bool = false


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	print("[HUD] READY")

	# ---------------------------------------------------------
	# COMPROBAR SPAWN
	# ---------------------------------------------------------

	if spawn == null:
		print("[HUD] ERROR: Spawner no encontrado")

	if spawn2 == null:
		print("[HUD] ERROR: AtaqueNaves no encontrado")


	# ---------------------------------------------------------
	# INICIAR SPAWN PRINCIPAL
	# ---------------------------------------------------------

	if spawn != null:
		spawn.call_deferred("iniciar_ataque")


	# ---------------------------------------------------------
	# INICIALIZAR CORAZONES
	# ---------------------------------------------------------

	for corazon in corazones:

		corazon.visible = true
		corazon.play("idle")


	# ---------------------------------------------------------
	# INICIALIZAR BARRA
	# ---------------------------------------------------------

	if barra_progreso:

		barra_progreso.max_value = vida_maxima_enemigo
		barra_progreso.value = progreso_enemigo
	siguiente_porcentaje_vida = 100.0 - porcentaje_por_ataque


	# ---------------------------------------------------------
	# INICIAR ATAQUES AUTOMÁTICOS
	# ---------------------------------------------------------

	if ataques_automaticos:

		call_deferred("iniciar_ataques_automaticos")


# =========================================================
# RECIBIR DAÑO EL ENEMIGO
# =========================================================

func disminuir_progreso(cantidad: float = 1.0) -> void:

	if juego_ganado:
		return

	if progreso_enemigo <= 0.0:
		return

	# ---------------------------------------------------------
	# RESTAR VIDA
	# ---------------------------------------------------------

	progreso_enemigo -= cantidad

	progreso_enemigo = max(
		0.0,
		progreso_enemigo
	)

	# ---------------------------------------------------------
	# ACTUALIZAR BARRA
	# ---------------------------------------------------------

	if barra_progreso:
		barra_progreso.value = progreso_enemigo

	print(
		"[HUD] Progreso del enemigo: ",
		progreso_enemigo,
		"/",
		vida_maxima_enemigo
	)

	# ---------------------------------------------------------
	# CALCULAR PORCENTAJE DE VIDA ACTUAL
	# ---------------------------------------------------------

	var porcentaje_vida_actual: float = (
		progreso_enemigo / vida_maxima_enemigo
	) * 100.0

	print(
		"[HUD] Vida: ",
		porcentaje_vida_actual,
		"%"
	)

	# ---------------------------------------------------------
	# ATAQUE CADA X% DE VIDA
	# ---------------------------------------------------------

	if (
		porcentaje_vida_actual <= siguiente_porcentaje_vida
		and progreso_enemigo > 0.0
	):

		print(
			"[HUD] Umbral de vida alcanzado: ",
			siguiente_porcentaje_vida,
			"%"
		)

		activar_spawn_ponderado()

		# Pasar al siguiente porcentaje
		siguiente_porcentaje_vida -= porcentaje_por_ataque

		# Evitar que siga bajando indefinidamente
		siguiente_porcentaje_vida = max(
			0.0,
			siguiente_porcentaje_vida
		)

	# ---------------------------------------------------------
	# DERROTA DEL JEFE
	# ---------------------------------------------------------

	if progreso_enemigo <= 0.0:

		ganar_juego()

func iniciar_ataques_automaticos() -> void:

	if ataque_automatico_activo:
		return


	ataque_automatico_activo = true

	print("[HUD] Sistema de ataques automáticos iniciado")


	while is_inside_tree() and progreso_enemigo > 0.0:

		# -----------------------------------------------------
		# ESPERAR TIEMPO ALEATORIO
		# -----------------------------------------------------

		var tiempo_espera: float = randf_range(
			tiempo_minimo_ataque,
			tiempo_maximo_ataque
		)

		print(
			"[HUD] Próximo ataque automático en ",
			tiempo_espera,
			" segundos"
		)


		await get_tree().create_timer(
			tiempo_espera
		).timeout


		# -----------------------------------------------------
		# COMPROBAR SI EL NODO SIGUE EXISTIENDO
		# -----------------------------------------------------

		if not is_inside_tree():
			return


		# -----------------------------------------------------
		# COMPROBAR SI EL ENEMIGO SIGUE VIVO
		# -----------------------------------------------------

		if progreso_enemigo <= 0.0:
			return


		# -----------------------------------------------------
		# LANZAR ATAQUE
		# -----------------------------------------------------

		print("======================================")
		print("=== ATAQUE AUTOMÁTICO ===")
		print(
			"Vida actual del enemigo: ",
			progreso_enemigo
		)
		print("======================================")


		activar_spawn_ponderado()


# =========================================================
# ACTIVAR SPAWN CON PROBABILIDAD
# =========================================================
#
# 65% = Spawn + AtaqueNaves
#
# 35% = solamente uno de los dos
#
# =========================================================
func activar_spawn_ponderado() -> void:

	var probabilidad: float = randf()


	# =====================================================
	# COOPERATIVO
	# =====================================================

	if modo_coop:

		print("======================================")
		print("[HUD] ATAQUE COOPERATIVO")
		print("======================================")


		# =================================================
		# 85% → ATAQUE MASIVO
		# SPAWNER + NAVES
		# =================================================

		if probabilidad <= 0.85:

			print(
				"[HUD] ¡ATAQUE MASIVO COOP!"
			)

			activar_spawner_principal()

			activar_spawner_naves()


			# ---------------------------------------------
			# 50% DE PROBABILIDAD DE REPETIR
			# ---------------------------------------------

			if randf() <= 0.50:

				await get_tree().create_timer(
					0.35
				).timeout

				if not juego_ganado:

					print(
						"[HUD] ¡SEGUNDA OLEADA COOP!"
					)

					activar_spawner_principal()

					activar_spawner_naves()


		# =================================================
		# 15% → SOLO UNO
		# =================================================

		else:

			print(
				"[HUD] Ataque individual COOP"
			)

			if randf() < 0.5:

				activar_spawner_principal()

			else:

				activar_spawner_naves()


		return


	# =====================================================
	# UN JUGADOR
	# =====================================================

	if probabilidad <= 0.65:

		print(
			"[HUD] ¡ATAQUE MASIVO!"
		)

		activar_spawner_principal()

		activar_spawner_naves()

	else:

		print(
			"[HUD] Ataque individual"
		)

		if randf() < 0.5:

			activar_spawner_principal()

		else:

			activar_spawner_naves()
# =========================================================
# GANAR JUEGO
# =========================================================
# =========================================================
# ACTIVAR SPAWNER PRINCIPAL
# =========================================================

func activar_spawner_principal() -> void:

	if spawn == null:
		return

	if spawn.has_method("iniciar_ataque"):

		print(
			"[HUD] → Activando Spawner"
		)

		spawn.call_deferred(
			"iniciar_ataque"
		)


# =========================================================
# ACTIVAR ATAQUE DE NAVES
# =========================================================

func activar_spawner_naves() -> void:

	if spawn2 == null:
		return

	if spawn2.has_method("iniciar_ataque"):

		print(
			"[HUD] → Activando AtaqueNaves"
		)

		spawn2.call_deferred(
			"iniciar_ataque"
		)
func ganar_juego() -> void:

	# ---------------------------------------------------------
	# EVITAR EJECUTAR VICTORIA DOS VECES
	# ---------------------------------------------------------

	if juego_ganado:
		return

	juego_ganado = true
	if sonido_victoria != null:
		print("sonido-victoria")
		sonido_victoria.process_mode = Node.PROCESS_MODE_ALWAYS 
		sonido_victoria.play()
		
	print("======================================")
	print("============== GANASTE ===============")
	print("======================================")

	# ---------------------------------------------------------
	# DETENER ATAQUES
	# ---------------------------------------------------------

	detener_todos_los_ataques()

	# ---------------------------------------------------------
	# HACER AL JUGADOR INVULNERABLE
	# ---------------------------------------------------------

	if jugador != null:

		if jugador.has_method("hacer_invulnerable"):
			jugador.hacer_invulnerable(true)

		elif "invulnerable" in jugador:
			jugador.invulnerable = true

		if jugador is CharacterBody2D:
			jugador.velocity = Vector2.ZERO

	# ---------------------------------------------------------
	# MOSTRAR VICTORIA
	# ---------------------------------------------------------

	if victoria != null:

		victoria.visible = true

		# Permitir que siga funcionando durante pausa
		victoria.process_mode = Node.PROCESS_MODE_ALWAYS

	# ---------------------------------------------------------
	# COMPROBAR PERSONAJE DE VICTORIA
	# ---------------------------------------------------------

	if personaje_victoria == null:

		print(
			"[VICTORIA] ERROR: AnimatedSprite2D no encontrado"
		)

		get_tree().paused = true

		return

	# ---------------------------------------------------------
	# MOSTRAR PERSONAJE
	# ---------------------------------------------------------

	personaje_victoria.visible = true

	personaje_victoria.play("idle")

	# ---------------------------------------------------------
	# POSICIÓN INICIAL
	# ---------------------------------------------------------

	var posicion_inicial := Vector2(
		-150.0,
		300.0
	)

	# ---------------------------------------------------------
	# POSICIÓN FINAL
	# ---------------------------------------------------------

	var posicion_final := Vector2(
		640.0,
		300.0
	)

	personaje_victoria.position = posicion_inicial

	# ---------------------------------------------------------
	# PAUSAR EL JUEGO
	# ---------------------------------------------------------

	get_tree().paused = true

	# ---------------------------------------------------------
	# CREAR TWEEN
	# ---------------------------------------------------------

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

	# ---------------------------------------------------------
	# ESPERAR QUE TERMINE EL MOVIMIENTO
	# ---------------------------------------------------------

	await tween.finished

	# ---------------------------------------------------------
	# IDLE EN EL CENTRO
	# ---------------------------------------------------------

	personaje_victoria.play("idle")

	print(
		"[VICTORIA] Personaje llegó al centro"
	)

	# ---------------------------------------------------------
	# ESPERAR ANTES DEL SIGUIENTE NIVEL
	# ---------------------------------------------------------

	print(
		"[VICTORIA] Esperando ",
		tiempo_antes_siguiente_nivel,
		" segundos..."
	)

	var timer := get_tree().create_timer(
		tiempo_antes_siguiente_nivel,
		true
	)

	await timer.timeout

	# ---------------------------------------------------------
	# CAMBIAR DE ESCENA
	# ---------------------------------------------------------

	cambiar_al_siguiente_nivel()
# =========================================================
# PERDER VIDA
# =========================================================

func perder_vida() -> void:

	if vidas <= 0:
		return


	# ---------------------------------------------------------
	# OBTENER CORAZÓN
	# ---------------------------------------------------------

	var indice := vidas - 1

	vidas -= 1


	# ---------------------------------------------------------
	# ANIMACIÓN DEL CORAZÓN
	# ---------------------------------------------------------

	if indice >= 0 and indice < corazones.size():

		var corazon: AnimatedSprite2D = corazones[indice]

		corazon.visible = true

		corazon.play("romper")

		await corazon.animation_finished

		corazon.visible = false


	# ---------------------------------------------------------
	# ACTUALIZAR CORAZONES
	# ---------------------------------------------------------

	actualizar_corazones()


	# ---------------------------------------------------------
	# GAME OVER
	# ---------------------------------------------------------

	if vidas <= 0:

		var jugador_actual = get_tree().get_first_node_in_group(
			"jugador"
		)


		if jugador_actual != null:

			if jugador_actual.has_method(
				"soltar_cuy_y_caer"
			):

				jugador_actual.soltar_cuy_y_caer()


		await get_tree().create_timer(
			2.0
		).timeout


		mostrar_game_over()


# =========================================================
# ACTUALIZAR CORAZONES
# =========================================================

func actualizar_corazones() -> void:

	for i in corazones.size():

		if i < vidas:

			corazones[i].visible = true

			corazones[i].play("idle")

		else:

			corazones[i].visible = false


# =========================================================
# GAME OVER
# =========================================================

func mostrar_game_over() -> void:

	get_tree().paused = false


	if escena_game_over != "":

		var escena_actual := get_tree().current_scene.scene_file_path

		print(
			"Escena actual: ",
			escena_actual
		)


		var game_over = load(
			escena_game_over
		).instantiate()


		game_over.configurar_escena_anterior(
			escena_actual
		)


		get_tree().current_scene.add_child(
			game_over
		)

	else:

		print(
			"NO HAY ESCENA GAME OVER ASIGNADA"
		)


# =========================================================
# PREPARAR GAME OVER
# =========================================================

func preparar_game_over() -> void:

	if jugador != null:

		if jugador.has_method(
			"soltar_cuy_y_caer"
		):

			await jugador.soltar_cuy_y_caer()


	mostrar_game_over()
func cambiar_al_siguiente_nivel() -> void:

	print("======================================")
	print("====== CAMBIANDO AL SIGUIENTE ========")
	print("======================================")

	# Quitar pausa antes de cambiar
	get_tree().paused = false

	# ---------------------------------------------------------
	# COMPROBAR ESCENA
	# ---------------------------------------------------------

	if siguiente_escena.is_empty():

		print(
			"[VICTORIA] ERROR: No se asignó siguiente_escena"
		)

		return

	# ---------------------------------------------------------
	# CAMBIAR ESCENA
	# ---------------------------------------------------------

	print(
		"[VICTORIA] Cargando: ",
		siguiente_escena
	)

	get_tree().change_scene_to_file(
		siguiente_escena
	)
func detener_todos_los_ataques() -> void:

	print("[HUD] DETENIENDO TODOS LOS ATAQUES")

	# ---------------------------------------------------------
	# DETENER SISTEMA DE ATAQUES AUTOMÁTICOS
	# ---------------------------------------------------------

	ataque_automatico_activo = false
	ataques_automaticos = false


	# ---------------------------------------------------------
	# DETENER SPAWNER PRINCIPAL
	# ---------------------------------------------------------

	if spawn != null:

		if spawn.has_method("detener_ataque"):

			spawn.detener_ataque()

			print("[HUD] Spawner detenido")


	# ---------------------------------------------------------
	# DETENER ATAQUE DE NAVES
	# ---------------------------------------------------------

	if spawn2 != null:

		if spawn2.has_method("detener_ataque"):

			spawn2.detener_ataque()

			print("[HUD] AtaqueNaves detenido")


	# ---------------------------------------------------------
	# ELIMINAR PROYECTILES EXISTENTES
	# ---------------------------------------------------------

	eliminar_proyectiles()


	# ---------------------------------------------------------
	# CONFIRMACIÓN
	# ---------------------------------------------------------

	print("[HUD] TODOS LOS ATAQUES DETENIDOS")
func eliminar_proyectiles() -> void:

	print("[HUD] Eliminando proyectiles existentes")

	var proyectiles := get_tree().get_nodes_in_group("proyectil")

	print(
		"[HUD] Proyectiles encontrados: ",
		proyectiles.size()
	)

	for proyectil in proyectiles:

		if is_instance_valid(proyectil):

			proyectil.queue_free()
# =========================================================
# CONFIGURAR MODO DE JUEGO
# =========================================================

func configurar_modo_juego(
	es_coop: bool,
	jugadores: Array[Node2D]
) -> void:

	modo_coop = es_coop

	jugadores_activos = jugadores


	# =====================================================
	# UN JUGADOR
	# =====================================================

	if not modo_coop:

		print("======================================")
		print("[HUD] DIFICULTAD: UN JUGADOR")
		print("======================================")

		vida_maxima_enemigo = VIDA_NORMAL

		multiplicador_caos = 1.0

		tiempo_minimo_ataque = 4.0
		tiempo_maximo_ataque = 8.0


	# =====================================================
	# COOPERATIVO
	# =====================================================

	else:

		print("======================================")
		print("[HUD] DIFICULTAD: COOPERATIVO")
		print("======================================")

		# DOBLE DE VIDA
		vida_maxima_enemigo = VIDA_COOP

		# Más caos
		multiplicador_caos = 2.0

		# Ataques más frecuentes
		tiempo_minimo_ataque = 2.0
		tiempo_maximo_ataque = 4.0


	# =====================================================
	# REINICIAR VIDA
	# =====================================================

	progreso_enemigo = vida_maxima_enemigo


	# =====================================================
	# CONFIGURAR BARRA
	# =====================================================

	if barra_progreso:

		barra_progreso.max_value = vida_maxima_enemigo
		barra_progreso.value = progreso_enemigo


	# =====================================================
	# PRÓXIMO ATAQUE
	# =====================================================

	siguiente_porcentaje_vida = (
		100.0 - porcentaje_por_ataque
	)


	print(
		"[HUD] Vida enemigo: ",
		vida_maxima_enemigo
	)

	print(
		"[HUD] Caos: x",
		multiplicador_caos
	)

	print(
		"[HUD] Tiempo ataques: ",
		tiempo_minimo_ataque,
		" - ",
		tiempo_maximo_ataque
	)

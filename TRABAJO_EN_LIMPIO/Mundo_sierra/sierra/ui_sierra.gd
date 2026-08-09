extends CanvasLayer

# =========================================================
# JUGADOR
# =========================================================

@export_category("Jugador")
@export var jugador: Node2D

@onready var spawn: Node2D = $"../Spawner"
@onready var spawn2: Node2D = $"../AtaqueNaves"


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

@export var vida_maxima_enemigo: float = 200.0

var progreso_enemigo: float = 200.0

# Cada cuánto daño se activa una oleada
var siguiente_umbral: float = 190.0


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


	# ---------------------------------------------------------
	# INICIAR ATAQUES AUTOMÁTICOS
	# ---------------------------------------------------------

	if ataques_automaticos:

		call_deferred("iniciar_ataques_automaticos")


# =========================================================
# RECIBIR DAÑO EL ENEMIGO
# =========================================================

func disminuir_progreso(cantidad: float = 1.0) -> void:

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
		progreso_enemigo
	)


	# ---------------------------------------------------------
	# ATAQUE POR CADA 10 PUNTOS
	# ---------------------------------------------------------

	if progreso_enemigo <= siguiente_umbral and progreso_enemigo > 0.0:

		print(
			"[HUD] Umbral alcanzado: ",
			siguiente_umbral
		)

		activar_spawn_ponderado()

		siguiente_umbral -= 10.0


	# ---------------------------------------------------------
	# DERROTA
	# ---------------------------------------------------------

	if progreso_enemigo <= 0.0:

		ganar_juego()


# =========================================================
# ATAQUES AUTOMÁTICOS
# =========================================================
#
# Estos ataques NO dependen de la vida.
#
# Aunque el jugador no dispare:
#
# 200
# ↓
# ataque automático
# ↓
# 200
# ↓
# ataque automático
# ↓
# 200
#
# =========================================================

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
	# 65% ATAQUE MASIVO
	# =====================================================

	if probabilidad <= 0.65:

		print(
			"[HUD] ¡ATAQUE MASIVO! ",
			"Spawn + AtaqueNaves"
		)


		# -------------------------------------------------
		# SPAWN PRINCIPAL
		# -------------------------------------------------

		if spawn != null:

			if spawn.has_method("iniciar_ataque"):

				spawn.call_deferred(
					"iniciar_ataque"
				)


		# -------------------------------------------------
		# ATAQUE DE NAVES
		# -------------------------------------------------

		if spawn2 != null:

			if spawn2.has_method("iniciar_ataque"):

				spawn2.call_deferred(
					"iniciar_ataque"
				)


	# =====================================================
	# 35% ATAQUE INDIVIDUAL
	# =====================================================

	else:

		print(
			"[HUD] Ataque individual"
		)


		# Elegir aleatoriamente cuál de los dos atacar

		if randf() < 0.5:

			# ---------------------------------------------
			# SOLO SPAWN
			# ---------------------------------------------

			print(
				"[HUD] → Solo Spawner"
			)


			if spawn != null:

				if spawn.has_method("iniciar_ataque"):

					spawn.call_deferred(
						"iniciar_ataque"
					)

		else:

			# ---------------------------------------------
			# SOLO ATAQUE NAVES
			# ---------------------------------------------

			print(
				"[HUD] → Solo AtaqueNaves"
			)


			if spawn2 != null:

				if spawn2.has_method("iniciar_ataque"):

					spawn2.call_deferred(
						"iniciar_ataque"
					)


# =========================================================
# GANAR JUEGO
# =========================================================

func ganar_juego() -> void:

	print("======================================")
	print("============== GANASTE ===============")
	print("======================================")


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

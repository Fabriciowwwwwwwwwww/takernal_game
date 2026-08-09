
extends CanvasLayer


# =========================================================
# ESTADO DEL JUEGO
# =========================================================

var puzzle_llamado: bool = false
var juego_ganado: bool = false

var cebolla_llamada: bool = false
var cafe_llamado: bool = false


# =========================================================
# MODO DE JUEGO / DIFICULTAD
# =========================================================

var es_coop: bool = false

var multiplicador_dificultad: float = 1.0
var multiplicador_ingredientes: float = 1.0
var multiplicador_spawn: float = 1.0


# =========================================================
# ESCENAS
# =========================================================

@export_category("Escenas")

@export_file("*.tscn")
var puzzle_scene: String

@export_file("*.tscn")
var escena_game_over: String


# =========================================================
# VICTORIA
# =========================================================

@export_category("Victoria")

@export var tiempo_antes_siguiente_nivel: float = 4.0

@onready var victoria: CanvasLayer = $"../CanvasLayer_victoria"

@onready var personaje_victoria: AnimatedSprite2D = $"../CanvasLayer_victoria/AnimatedSprite2D"


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
# VIDA
# =========================================================

var vidas: int = 5


# =========================================================
# BARRA DE PROGRESO
# =========================================================

@onready var barra: ProgressBar = $ProgressBar

var progreso: float = 0.0


# =========================================================
# PROBABILIDADES DE PEDIDO
# =========================================================

var probabilidad_pedido: Dictionary[String, float] = {

	"camote": 0.80,
	"cebolla": 0.75,
	"sal": 0.55,
	"limon": 0.60,
	"pan": 0.35,
	"chicharron": 0.55

}


# =========================================================
# OBJETIVOS
# =========================================================

var objetivo_ingredientes = {

	"camote": 0,
	"cebolla": 0,
	"sal": 0,
	"limon": 0,
	"pan": 0,
	"chicharron": 0

}


# =========================================================
# INGREDIENTES CONSEGUIDOS
# =========================================================

var ingredientes_conseguidos = {

	"camote": 0,
	"cebolla": 0,
	"sal": 0,
	"limon": 0,
	"pan": 0,
	"chicharron": 0

}


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	print("======================================")
	print("========== HUD PUZLE =================")
	print("======================================")


	# ---------------------------------------------------------
	# PROCESAR SI EL JUEGO ESTÁ PAUSADO
	# ---------------------------------------------------------

	process_mode = Node.PROCESS_MODE_ALWAYS


	# ---------------------------------------------------------
	# DETECTAR MODO DE JUEGO
	# ---------------------------------------------------------

	es_coop = (
		GameManager.modo_juego ==
		GameManager.ModoJuego.COOP
	)


	# ---------------------------------------------------------
	# CONFIGURAR DIFICULTAD
	# ---------------------------------------------------------

	if es_coop:

		multiplicador_dificultad = 2.0
		multiplicador_ingredientes = 2.0
		multiplicador_spawn = 2.0

		print("======================================")
		print("======= MODO COOPERATIVO =============")
		print("======= DIFICULTAD X2 =================")
		print("======= INGREDIENTES X2 ===============")
		print("======= SPAWN X2 ======================")
		print("======================================")

	else:

		multiplicador_dificultad = 1.0
		multiplicador_ingredientes = 1.0
		multiplicador_spawn = 1.0

		print("======================================")
		print("======= MODO UN JUGADOR ===============")
		print("======= DIFICULTAD NORMAL =============")
		print("======================================")


	# ---------------------------------------------------------
	# CONFIGURAR VICTORIA
	# ---------------------------------------------------------

	if victoria != null:

		victoria.visible = false

		victoria.process_mode = Node.PROCESS_MODE_ALWAYS


	if personaje_victoria != null:

		personaje_victoria.visible = false


	# ---------------------------------------------------------
	# GENERAR PEDIDO
	# ---------------------------------------------------------

	generar_objetivos()


	# ---------------------------------------------------------
	# ACTUALIZAR PANEL
	# ---------------------------------------------------------

	actualizar_panel3()


	# ---------------------------------------------------------
	# INICIALIZAR CORAZONES
	# ---------------------------------------------------------

	for corazon in corazones:

		if corazon != null:

			corazon.visible = true
			corazon.play("idle")


	# ---------------------------------------------------------
	# INICIALIZAR BARRA
	# ---------------------------------------------------------

	if barra != null:

		barra.min_value = 0
		barra.max_value = 100
		barra.value = 0


	print("[HUD PUZLE] Inicialización completada")


# =========================================================
# CONFIGURAR DIFICULTAD DESDE OTRO NODO
# =========================================================

func configurar_dificultad(
	dificultad: float,
	ingredientes: float,
	spawn: float
) -> void:

	multiplicador_dificultad = dificultad
	multiplicador_ingredientes = ingredientes
	multiplicador_spawn = spawn

	es_coop = dificultad >= 2.0

	print("======================================")
	print("[HUD] DIFICULTAD RECIBIDA")
	print("======================================")

	print(
		"[HUD] Cooperativo: ",
		es_coop
	)

	print(
		"[HUD] Dificultad: ",
		multiplicador_dificultad
	)

	print(
		"[HUD] Ingredientes: ",
		multiplicador_ingredientes
	)

	print(
		"[HUD] Spawn: ",
		multiplicador_spawn
	)


# =========================================================
# GENERAR OBJETIVOS
# =========================================================

func generar_objetivos() -> void:

	print("======================================")
	print("[HUD] GENERANDO OBJETIVOS")
	print("======================================")


	for ingrediente in objetivo_ingredientes:

		var cantidad: int = 0

		var prob: float = probabilidad_pedido[ingrediente]


		# -----------------------------------------------------
		# GENERACIÓN NORMAL
		# -----------------------------------------------------

		for i in range(30):

			if randf() <= prob:

				cantidad += 1


		# -----------------------------------------------------
		# MÍNIMO 1
		# -----------------------------------------------------

		cantidad = clamp(
			cantidad,
			1,
			30
		)


		# -----------------------------------------------------
		# COOPERATIVO
		# DOBLE DE INGREDIENTES
		# -----------------------------------------------------

		if es_coop:

			cantidad *= 2


		objetivo_ingredientes[ingrediente] = cantidad


		print(
			"[HUD] ",
			ingrediente,
			" = ",
			cantidad
		)


	# =====================================================
	# ACTUALIZAR PANEL 2
	# =====================================================

	$Panel2/HBoxContainer/ingre1/camote_label.text = str(
		objetivo_ingredientes["camote"]
	)

	$Panel2/HBoxContainer/ingre2/cebolla_label.text = str(
		objetivo_ingredientes["cebolla"]
	)

	$Panel2/HBoxContainer/ingre3/sal_label.text = str(
		objetivo_ingredientes["sal"]
	)

	$Panel2/HBoxContainer/ingre4/Limon_label.text = str(
		objetivo_ingredientes["limon"]
	)

	$Panel2/HBoxContainer/ingre5/pan_label.text = str(
		objetivo_ingredientes["pan"]
	)

	$Panel2/HBoxContainer/ingre6/chicharron_label.text = str(
		objetivo_ingredientes["chicharron"]
	)


# =========================================================
# SUMAR INGREDIENTE
# =========================================================

func agregar_ingrediente(nombre: String) -> void:

	if not nombre in ingredientes_conseguidos:

		print(
			"[HUD] Ingrediente desconocido: ",
			nombre
		)

		return


	ingredientes_conseguidos[nombre] += 1


	print(
		"[HUD] INGREDIENTE: ",
		nombre,
		" -> ",
		ingredientes_conseguidos[nombre]
	)


	actualizar_panel3()

	actualizar_progreso()


# =========================================================
# ACTUALIZAR PANEL 3
# =========================================================

func actualizar_panel3() -> void:

	$Panel3/HBoxContainer/ingre1/camote_label.text = str(
		ingredientes_conseguidos["camote"]
	)

	$Panel3/HBoxContainer/ingre2/cebolla_label.text = str(
		ingredientes_conseguidos["cebolla"]
	)

	$Panel3/HBoxContainer/ingre3/sal_label.text = str(
		ingredientes_conseguidos["sal"]
	)

	$Panel3/HBoxContainer/ingre4/Limon_label.text = str(
		ingredientes_conseguidos["limon"]
	)

	$Panel3/HBoxContainer/ingre5/pan_label.text = str(
		ingredientes_conseguidos["pan"]
	)

	$Panel3/HBoxContainer/ingre6/chicharron_label.text = str(
		ingredientes_conseguidos["chicharron"]
	)


# =========================================================
# ACTUALIZAR PROGRESO
# =========================================================

func actualizar_progreso() -> void:

	var total_necesario: int = 0
	var total_conseguido: int = 0


	for ingrediente in objetivo_ingredientes:

		total_necesario += objetivo_ingredientes[ingrediente]

		total_conseguido += ingredientes_conseguidos[ingrediente]


	if total_necesario > 0:

		progreso = (
			float(total_conseguido) /
			float(total_necesario)
		) * 100.0

	else:

		progreso = 0.0


	progreso = clamp(
		progreso,
		0.0,
		100.0
	)


	# ---------------------------------------------------------
	# BARRA
	# ---------------------------------------------------------

	if barra != null:

		barra.value = progreso


	print(
		"[HUD] Progreso: ",
		progreso,
		"%"
	)


	# =========================================================
	# EVENTO CEBOLLAS - 65%
	# =========================================================

	if progreso >= 65.0 and not cebolla_llamada:

		cebolla_llamada = true

		var spawner = get_tree().current_scene.get_node_or_null(
			"cebollaSpawner2"
		)


		if spawner != null:

			print(
				"[HUD] LLAMANDO EVENTO CEBOLLAS"
			)

			if spawner.has_method(
				"iniciar_evento_cebollas"
			):

				spawner.iniciar_evento_cebollas()

		else:

			print(
				"[HUD] NO EXISTE CEBOLLA SPAWNER"
			)


	# =========================================================
	# ATAQUE CAFÉ - 25%
	# =========================================================

	if progreso >= 25.0 and not cafe_llamado:

		cafe_llamado = true

		var cafe = get_tree().current_scene.get_node_or_null(
			"cafe_estado/Cafe"
		)


		if cafe != null:

			print(
				"[HUD] LLAMANDO ATAQUE CAFÉ"
			)

			if cafe.has_method("_ataque"):

				cafe._ataque()

		else:

			print(
				"[HUD] NO EXISTE CAFE"
			)


	# =========================================================
	# VICTORIA - 100%
	# =========================================================

	if progreso >= 100.0 and not puzzle_llamado:

		puzzle_llamado = true

		print("======================================")
		print("========= PUZLE COMPLETADO ===========")
		print("======================================")

		ganar_juego()


# =========================================================
# GANAR JUEGO
# =========================================================

func ganar_juego() -> void:

	# ---------------------------------------------------------
	# EVITAR DOBLE VICTORIA
	# ---------------------------------------------------------

	if juego_ganado:

		return


	juego_ganado = true


	print("======================================")
	print("============== GANASTE ===============")
	print("======================================")


	# ---------------------------------------------------------
	# DETENER JUGADORES
	# ---------------------------------------------------------

	var jugadores = get_tree().get_nodes_in_group(
		"jugador"
	)


	for jugador in jugadores:

		if not is_instance_valid(jugador):

			continue


		# ---------------------------------------------
		# HACER INVULNERABLE
		# ---------------------------------------------

		if jugador.has_method(
			"hacer_invulnerable"
		):

			jugador.hacer_invulnerable(true)


		elif "invulnerable" in jugador:

			jugador.invulnerable = true


		# ---------------------------------------------
		# DETENER MOVIMIENTO
		# ---------------------------------------------

		if jugador is CharacterBody2D:

			jugador.velocity = Vector2.ZERO


	# ---------------------------------------------------------
	# MOSTRAR VICTORIA
	# ---------------------------------------------------------

	if victoria == null:

		print(
			"[VICTORIA] ERROR: CanvasLayer_victoria no encontrado"
		)

		return


	victoria.visible = true

	victoria.process_mode = Node.PROCESS_MODE_ALWAYS


	# ---------------------------------------------------------
	# COMPROBAR PERSONAJE
	# ---------------------------------------------------------

	if personaje_victoria == null:

		print(
			"[VICTORIA] ERROR: AnimatedSprite2D no encontrado"
		)

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
	# PAUSAR JUEGO
	# ---------------------------------------------------------

	get_tree().paused = true


	# ---------------------------------------------------------
	# TWEEN
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
	# ESPERAR MOVIMIENTO
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
	# ESPERAR
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
	# CAMBIAR ESCENA
	# ---------------------------------------------------------

	cambiar_al_siguiente_nivel()


# =========================================================
# CAMBIAR AL SIGUIENTE NIVEL
# =========================================================

func cambiar_al_siguiente_nivel() -> void:

	print("======================================")
	print("====== CAMBIANDO AL SIGUIENTE ========")
	print("======================================")


	get_tree().paused = false


	# ---------------------------------------------------------
	# COMPROBAR ESCENA
	# ---------------------------------------------------------

	if puzzle_scene.is_empty():

		print(
			"[VICTORIA] ERROR: puzzle_scene no asignada"
		)

		return


	print(
		"[VICTORIA] Cargando: ",
		puzzle_scene
	)


	# ---------------------------------------------------------
	# CAMBIAR ESCENA
	# ---------------------------------------------------------

	SceneManager.change_scene(
		self,
		puzzle_scene
	)


# =========================================================
# PERDER VIDA
# =========================================================

func perder_vida() -> void:

	if vidas <= 0:

		return


	# ---------------------------------------------------------
	# CORAZÓN
	# ---------------------------------------------------------

	var indice: int = vidas - 1

	vidas -= 1


	# ---------------------------------------------------------
	# ROMPER CORAZÓN
	# ---------------------------------------------------------

	if indice >= 0 and indice < corazones.size():

		var corazon: AnimatedSprite2D = corazones[indice]


		if corazon != null:

			corazon.visible = true

			corazon.play("romper")


			await corazon.animation_finished


			corazon.visible = false


	# ---------------------------------------------------------
	# ACTUALIZAR
	# ---------------------------------------------------------

	actualizar_corazones()


	# ---------------------------------------------------------
	# GAME OVER
	# ---------------------------------------------------------

	if vidas <= 0:

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

			if corazones[i].animation != "idle":

				corazones[i].play("idle")

		else:

			corazones[i].visible = false


# =========================================================
# GAME OVER
# =========================================================

func mostrar_game_over() -> void:

	get_tree().paused = false


	if escena_game_over.is_empty():

		print(
			"[GAME OVER] No se asignó escena_game_over"
		)

		return


	var escena_actual: String = (
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
# ELEGIR INGREDIENTE DEL PEDIDO
# =========================================================

func elegir_ingrediente_pedido() -> String:

	var total := 0.0


	for ingrediente in probabilidad_pedido:

		total += probabilidad_pedido[ingrediente]


	var random := randf() * total

	var acumulado := 0.0


	for ingrediente in probabilidad_pedido:

		acumulado += probabilidad_pedido[ingrediente]


		if random <= acumulado:

			return ingrediente


	return "camote"


# =========================================================
# OBTENER MULTIPLICADOR DE DIFICULTAD
# =========================================================

func obtener_multiplicador_dificultad() -> float:

	return multiplicador_dificultad


# =========================================================
# OBTENER MULTIPLICADOR DE INGREDIENTES
# =========================================================

func obtener_multiplicador_ingredientes() -> float:

	return multiplicador_ingredientes


# =========================================================
# OBTENER MULTIPLICADOR DE SPAWN
# =========================================================

func obtener_multiplicador_spawn() -> float:

	return multiplicador_spawn


# =========================================================
# SABER SI ES COOP
# =========================================================

func es_modo_coop() -> bool:

	return es_coop

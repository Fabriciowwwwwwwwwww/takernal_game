extends Control


# =========================================================
# CONFIGURACIÓN
# =========================================================

@export_category("Créditos")
@onready var musica: AudioStreamPlayer2D = $sonido_mundo
@export var velocidad_creditos: float = 500.0

@export var posicion_inicial_y: float = 750.0

@export var posicion_final_y: float = -3500.0

@export_file("*.tscn")
var escena_menu: String


# =========================================================
# NODOS
# =========================================================

@onready var contenido_creditos: Control = $Mascara/Control

@onready var texto_creditos: Label = $Mascara/Control/TextoCreditos


# =========================================================
# VARIABLES
# =========================================================

var creditos_terminados: bool = false

var tween_creditos: Tween = null


# =========================================================
# READY
# =========================================================

func _ready() -> void:
	musica.play()
	PauseOverlay.puede_pausar = false

	print("======================================")
	print("=========== INICIANDO CREDITOS ========")
	print("======================================")


	# =====================================================
	# PROCESAR SIEMPRE
	# =====================================================

	process_mode = Node.PROCESS_MODE_ALWAYS

	get_tree().paused = false


	# =====================================================
	# COMPROBAR CONTENIDO
	# =====================================================

	if contenido_creditos == null:

		print(
			"[CREDITOS] ERROR: Mascara/Control no encontrado"
		)

		return


	# =====================================================
	# COMPROBAR TEXTO
	# =====================================================

	if texto_creditos == null:

		print(
			"[CREDITOS] ERROR: TextoCreditos no encontrado"
		)

		return


	# =====================================================
	# POSICIÓN INICIAL
	# =====================================================

	contenido_creditos.position = Vector2(
		contenido_creditos.position.x,
		posicion_inicial_y
	)


	# =====================================================
	# MOSTRAR TEXTO
	# =====================================================

	texto_creditos.visible = true


	print(
		"[CREDITOS] Texto cargado:"
	)

	print(
		texto_creditos.text
	)


	# =====================================================
	# INICIAR CRÉDITOS
	# =====================================================

	iniciar_creditos()


# =========================================================
# INPUT
# =========================================================
#
# ENTER = SALTAR CRÉDITOS
#
# También acepta ENTER DEL TECLADO NUMÉRICO.
#
# =========================================================

func _input(event: InputEvent) -> void:

	if creditos_terminados:

		return


	if event is InputEventKey:

		if event.pressed and not event.echo:

			if (
				event.keycode == KEY_ENTER
				or
				event.keycode == KEY_KP_ENTER
			):

				print("======================================")
				print("       ¡ENTER PRESIONADO!             ")
				print("======================================")

				saltar_creditos()


# =========================================================
# INICIAR CRÉDITOS
# =========================================================

func iniciar_creditos() -> void:

	if creditos_terminados:

		return


	# =====================================================
	# COMPROBAR VELOCIDAD
	# =====================================================

	if velocidad_creditos <= 0.0:

		print(
			"[CREDITOS] ERROR: velocidad_creditos inválida: ",
			velocidad_creditos
		)

		return


	# =====================================================
	# DISTANCIA
	# =====================================================

	var distancia: float = abs(
		posicion_inicial_y -
		posicion_final_y
	)


	# =====================================================
	# DURACIÓN
	# =====================================================

	var duracion: float = (
		distancia /
		velocidad_creditos
	)


	print(
		"[CREDITOS] Distancia: ",
		distancia
	)

	print(
		"[CREDITOS] Velocidad: ",
		velocidad_creditos
	)

	print(
		"[CREDITOS] Duración: ",
		duracion
	)


	# =====================================================
	# CREAR TWEEN
	# =====================================================

	tween_creditos = create_tween()

	tween_creditos.set_trans(
		Tween.TRANS_LINEAR
	)

	tween_creditos.set_ease(
		Tween.EASE_IN_OUT
	)


	# =====================================================
	# MOVER CRÉDITOS
	# =====================================================

	tween_creditos.tween_property(
		contenido_creditos,
		"position:y",
		posicion_final_y,
		duracion
	)


	# =====================================================
	# ESPERAR
	# =====================================================

	await tween_creditos.finished


	# =====================================================
	# COMPROBAR SI FUERON OMITIDOS
	# =====================================================

	if creditos_terminados:

		return


	# =====================================================
	# CRÉDITOS TERMINADOS
	# =====================================================

	creditos_terminados = true


	print("======================================")
	print("[CREDITOS] CRÉDITOS TERMINADOS")
	print("======================================")


	volver_al_menu()


# =========================================================
# SALTAR CRÉDITOS
# =========================================================

func saltar_creditos() -> void:

	print(
		"[CREDITOS] Saltando créditos..."
	)


	# =====================================================
	# EVITAR DOBLE EJECUCIÓN
	# =====================================================

	if creditos_terminados:

		return


	# =====================================================
	# MARCAR TERMINADO
	# =====================================================

	creditos_terminados = true


	# =====================================================
	# DETENER TWEEN
	# =====================================================

	if tween_creditos != null:

		if tween_creditos.is_valid():

			print(
				"[CREDITOS] Deteniendo Tween..."
			)

			tween_creditos.kill()


	# =====================================================
	# VOLVER AL MENÚ
	# =====================================================

	volver_al_menu()


# =========================================================
# VOLVER AL MENÚ
# =========================================================

func volver_al_menu() -> void:

	print(
		"[CREDITOS] Intentando volver al menú..."
	)


	# =====================================================
	# COMPROBAR ESCENA
	# =====================================================

	if escena_menu.is_empty():

		print(
			"[CREDITOS] ERROR: escena_menu está vacía"
		)

		return


	# =====================================================
	# QUITAR PAUSA
	# =====================================================

	get_tree().paused = false


	# =====================================================
	# CAMBIAR ESCENA
	# =====================================================

	print(
		"[CREDITOS] Volviendo al menú..."
	)

	print(
		"[CREDITOS] Escena: ",
		escena_menu
	)


	SceneManager.change_scene(
		self,
		escena_menu
	)

extends Control


# =========================================================
# CONFIGURACIÓN
# =========================================================

@export_category("Créditos")

@export var velocidad_creditos: float = 45.0

@export var posicion_inicial_y: float = 750.0

@export var posicion_final_y: float = -3500.0

@export_file("*.tscn")
var escena_menu: String


# =========================================================
# NODOS
# =========================================================

@onready var contenido_creditos: Control = $Mascara/Control

@onready var texto_creditos: Label = $Mascara/Control/TextoCreditos

@onready var boton_saltar: Button = $BotonSaltar


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	process_mode = Node.PROCESS_MODE_ALWAYS

	get_tree().paused = false


	# =====================================================
	# COMPROBAR NODOS
	# =====================================================

	if contenido_creditos == null:

		print("[CREDITOS] ERROR: No existe Mascara/Control")

		return


	if texto_creditos == null:

		print("[CREDITOS] ERROR: No existe TextoCreditos")

		return


	# =====================================================
	# POSICIÓN INICIAL
	# =====================================================

	contenido_creditos.position = Vector2(
		0.0,
		posicion_inicial_y
	)


	# =====================================================
	# CONFIGURAR TEXTO
	# =====================================================

	texto_creditos.visible = true


	texto_creditos.text = """NUESTRO JUEGO

COMIDA QUE NOS UNE

Un juego creado para la Game Jam


────────────────────


EQUIPO


PROGRAMACIÓN

Fabricio García


ARTE

Nombre del artista


MÚSICA

Nombre del músico


DISEÑO

Nombre del diseñador


────────────────────


AGRADECIMIENTOS


A nuestras familias

A nuestros amigos

A todas las personas que jugaron


────────────────────


GRACIAS POR JUGAR


❤️


FIN"""


	# =====================================================
	# BOTÓN OMITIR
	# =====================================================

	if boton_saltar != null:

		if not boton_saltar.pressed.is_connected(
			saltar_creditos
		):

			boton_saltar.pressed.connect(
				saltar_creditos
			)


	# =====================================================
	# INICIAR
	# =====================================================

	iniciar_creditos()


# =========================================================
# INICIAR CRÉDITOS
# =========================================================

func iniciar_creditos() -> void:

	if velocidad_creditos <= 0.0:

		print(
			"[CREDITOS] ERROR: velocidad_creditos inválida"
		)

		return


	# =====================================================
	# DISTANCIA
	# =====================================================

	var distancia: float = abs(
		posicion_inicial_y - posicion_final_y
	)


	# =====================================================
	# DURACIÓN
	# =====================================================

	var duracion: float = distancia / velocidad_creditos


	print("======================================")
	print("[CREDITOS] INICIANDO")
	print("======================================")

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
	# TWEEN
	# =====================================================

	var tween: Tween = create_tween()

	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)


	tween.tween_property(
		contenido_creditos,
		"position:y",
		posicion_final_y,
		duracion
	)


	# =====================================================
	# ESPERAR
	# =====================================================

	await tween.finished


	print("[CREDITOS] CRÉDITOS TERMINADOS")


	volver_al_menu()


# =========================================================
# OMITIR
# =========================================================

func saltar_creditos() -> void:

	print("[CREDITOS] Créditos omitidos")

	volver_al_menu()


# =========================================================
# VOLVER AL MENÚ
# =========================================================

func volver_al_menu() -> void:

	if escena_menu.is_empty():

		print(
			"[CREDITOS] ERROR: escena_menu no asignada"
		)

		return


	get_tree().paused = false


	print("[CREDITOS] Volviendo al menú")


	SceneManager.change_scene(
		self,
		escena_menu
	)

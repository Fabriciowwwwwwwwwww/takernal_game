extends Node2D

# =====================================================
# SIGUIENTE NIVEL
# =====================================================

@export_category("Siguiente nivel")
@export_file("*.tscn") var siguiente_escena: String

signal nivel_superado

@onready var musica: AudioStreamPlayer2D = $sonido_mundo


# =====================================================
# CONFIGURACIÓN DEL TABLERO
# =====================================================

const TAM_CASILLA: int = 64
const TAMAÑO: int = 7

@export_category("Posición del Puzzle")
@export var posicion_tablero: Vector2 = Vector2(160, 100)


# =====================================================
# PANEL DE INGREDIENTES
# =====================================================

@export_category("Panel de ingredientes")
@export var posicion_panel: Vector2 = Vector2(750, 100)
@export var tamaño_panel: Vector2 = Vector2(180, 450)


# =====================================================
# IMÁGENES
# =====================================================

@export_category("Ingredientes")
@export var imagenes: Array[Texture2D] = []


# =====================================================
# VARIABLES DEL PUZZLE
# =====================================================

var dibujando: bool = false

var camino: Array[Vector2i] = []

var linea: Line2D

var mapa_puntos: Dictionary = {}

var orden_indices: Array[int] = []

var indice_meta_actual: int = 1

var nivel_completado: bool = false


# =====================================================
# PUZZLE DE 6 INGREDIENTES
# =====================================================
#
# 1 → 2 → 3 → 4 → 5 → 6
#
# =====================================================

var posiciones_puntos: Array[Vector2i] = [
	Vector2i(3, 3), # 1
	Vector2i(1, 1), # 2
	Vector2i(5, 5), # 3
	Vector2i(0, 6), # 4
	Vector2i(6, 6), # 5
	Vector2i(6, 0)  # 6
]


# =====================================================
# READY
# =====================================================

func _ready() -> void:

	if musica:
		musica.play()


	# =================================================
	# CREAR MAPA DE PUNTOS
	# =================================================

	var cantidad: int = mini(
		posiciones_puntos.size(),
		imagenes.size()
	)

	for i: int in range(cantidad):

		if imagenes[i] != null:

			mapa_puntos[posiciones_puntos[i]] = i

			orden_indices.append(i)


	# =================================================
	# CREAR LÍNEA
	# =================================================

	linea = Line2D.new()

	linea.width = 16.0
	linea.default_color = Color("f97316")
	linea.z_index = 5

	linea.joint_mode = Line2D.LINE_JOINT_ROUND
	linea.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linea.end_cap_mode = Line2D.LINE_CAP_ROUND

	add_child(linea)


	# =================================================
	# CREAR INGREDIENTES
	# =================================================

	crear_sprites_mapa()

	crear_sprites_tablero_lateral()

	queue_redraw()


# =====================================================
# DIBUJAR TABLERO
# =====================================================

func _draw() -> void:

	for x: int in range(TAMAÑO):

		for y: int in range(TAMAÑO):

			var rect: Rect2 = Rect2(
				posicion_tablero.x + x * TAM_CASILLA,
				posicion_tablero.y + y * TAM_CASILLA,
				TAM_CASILLA,
				TAM_CASILLA
			)


			# Fondo

			draw_rect(
				rect,
				Color("fff7ed"),
				true
			)


			# Borde

			draw_rect(
				rect,
				Color("d6b98c"),
				false,
				3.0
			)


	# =================================================
	# TEXTO DE PROGRESO
	# =================================================

	var font: Font = ThemeDB.fallback_font

	var texto_estado: String = (
		"Casillas: "
		+ str(camino.size())
		+ " / "
		+ str(TAMAÑO * TAMAÑO)
	)


	draw_string(
		font,
		Vector2(
			posicion_tablero.x,
			posicion_tablero.y
			+ TAMAÑO * TAM_CASILLA
			+ 35
		),
		texto_estado,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		18,
		Color.BLACK
	)


	# =================================================
	# PANEL
	# =================================================

	var rect_panel: Rect2 = Rect2(
		posicion_panel,
		tamaño_panel
	)


	draw_rect(
		rect_panel,
		Color("fff7ed"),
		true
	)


	draw_rect(
		rect_panel,
		Color("c08457"),
		false,
		4.0
	)


# =====================================================
# CREAR INGREDIENTES EN EL MAPA
# =====================================================

func crear_sprites_mapa() -> void:

	for pos: Vector2i in mapa_puntos.keys():

		var idx: int = int(mapa_puntos[pos])


		if idx >= imagenes.size():
			continue


		if imagenes[idx] == null:
			continue


		# =================================================
		# CENTRO DE LA CASILLA
		# =================================================

		var centro: Vector2 = Vector2(
			posicion_tablero.x
			+ pos.x * TAM_CASILLA
			+ TAM_CASILLA / 2,

			posicion_tablero.y
			+ pos.y * TAM_CASILLA
			+ TAM_CASILLA / 2
		)


		# =================================================
		# SPRITE
		# =================================================

		var sprite: Sprite2D = Sprite2D.new()

		sprite.texture = imagenes[idx]

		sprite.position = centro

		sprite.z_index = 3


		# =================================================
		# ESCALA
		# =================================================

		var tamaño: Vector2 = sprite.texture.get_size()


		if tamaño.x > 0.0 and tamaño.y > 0.0:

			sprite.scale = Vector2(
				40.0 / tamaño.x,
				40.0 / tamaño.y
			)


		add_child(sprite)


# =====================================================
# PANEL LATERAL
# =====================================================

func crear_sprites_tablero_lateral() -> void:

	var alto_fila: float = 55.0


	for i: int in range(orden_indices.size()):

		var pos_y: float = (
			posicion_panel.y
			+ 60
			+ i * alto_fila
		)


		# =================================================
		# NÚMERO
		# =================================================

		var label: Label = Label.new()

		label.text = str(i + 1)

		label.position = Vector2(
			posicion_panel.x + 25,
			pos_y
		)

		label.add_theme_font_size_override(
			"font_size",
			22
		)

		label.add_theme_color_override(
			"font_color",
			Color.BLACK
		)

		add_child(label)


		# =================================================
		# IMAGEN
		# =================================================

		var sprite: Sprite2D = Sprite2D.new()

		sprite.texture = imagenes[i]

		sprite.position = Vector2(
			posicion_panel.x + 90,
			pos_y + 10
		)

		sprite.z_index = 3


		var tex_size: Vector2 = sprite.texture.get_size()


		if tex_size.x > 0.0 and tex_size.y > 0.0:

			sprite.scale = Vector2(
				35.0 / tex_size.x,
				35.0 / tex_size.y
			)


		add_child(sprite)


# =====================================================
# INPUT
# =====================================================

func _input(event: InputEvent) -> void:

	if nivel_completado:
		return


	# =================================================
	# CLICK IZQUIERDO
	# =================================================

	if event is InputEventMouseButton:

		var mouse_event: InputEventMouseButton = event


		if mouse_event.button_index == MOUSE_BUTTON_LEFT:

			if mouse_event.pressed:

				intentar_iniciar_o_continuar()

			else:

				dibujando = false


	# =================================================
	# MOVIMIENTO DEL RATÓN
	# =================================================

	if event is InputEventMouseMotion:

		if dibujando:

			var mouse_motion: InputEventMouseMotion = event

			mover(mouse_motion.position)


# =====================================================
# INICIAR O CONTINUAR
# =====================================================

func intentar_iniciar_o_continuar() -> void:

	var casilla: Vector2i = obtener_casilla(
		get_global_mouse_position()
	)


	# =================================================
	# COMENZAR DESDE INGREDIENTE 1
	# =================================================

	if mapa_puntos.has(casilla):

		if orden_indices.size() > 0:

			var ingrediente: int = int(
				mapa_puntos[casilla]
			)


			if ingrediente == orden_indices[0]:

				camino.clear()

				linea.clear_points()

				dibujando = true

				indice_meta_actual = 1

				nivel_completado = false

				agregar_casilla(casilla)

				return


	# =================================================
	# CONTINUAR DESDE EL ÚLTIMO PUNTO
	# =================================================

	if camino.size() > 0:

		if casilla == camino[-1]:

			dibujando = true


	# =================================================
	# RETROCEDER
	# =================================================

	elif camino.size() > 1:

		if casilla == camino[-2]:

			retroceder()

			dibujando = true


# =====================================================
# MOVER
# =====================================================

func mover(pos: Vector2) -> void:

	var casilla: Vector2i = obtener_casilla(pos)


	# =================================================
	# FUERA DEL TABLERO
	# =================================================

	if casilla == Vector2i(-1, -1):
		return


	if camino.size() == 0:
		return


	var ultima: Vector2i = camino[-1]


	# =================================================
	# RETROCEDER
	# =================================================

	if camino.size() > 1:

		if casilla == camino[-2]:

			retroceder()

			return


	# =================================================
	# DEBE SER ADYACENTE
	# =================================================

	if distancia(ultima, casilla) != 1:
		return


	# =================================================
	# NO REPETIR CASILLAS
	# =================================================

	if camino.has(casilla):
		return


	# =================================================
	# COMPROBAR INGREDIENTE
	# =================================================

	if mapa_puntos.has(casilla):

		if indice_meta_actual < orden_indices.size():

			var meta_esperada: int = (
				orden_indices[indice_meta_actual]
			)


			var ingrediente: int = int(
				mapa_puntos[casilla]
			)


			# =================================================
			# INGREDIENTE INCORRECTO
			# =================================================

			if ingrediente != meta_esperada:

				return


			# =================================================
			# INGREDIENTE CORRECTO
			# =================================================

			indice_meta_actual += 1

		else:

			return


	# =================================================
	# AGREGAR CASILLA
	# =================================================

	agregar_casilla(casilla)


# =====================================================
# AGREGAR CASILLA
# =====================================================

func agregar_casilla(casilla: Vector2i) -> void:

	camino.append(casilla)


	var pos_pixel: Vector2 = Vector2(
		posicion_tablero.x
		+ casilla.x * TAM_CASILLA
		+ TAM_CASILLA / 2,

		posicion_tablero.y
		+ casilla.y * TAM_CASILLA
		+ TAM_CASILLA / 2
	)


	linea.add_point(pos_pixel)

	queue_redraw()

	comprobar_victoria()


# =====================================================
# RETROCEDER
# =====================================================

func retroceder() -> void:

	if camino.size() <= 1:
		return


	var casilla_removida: Vector2i = camino.pop_back()


	# =================================================
	# SI ERA INGREDIENTE
	# =================================================

	if mapa_puntos.has(casilla_removida):

		if indice_meta_actual > 1:

			var ultimo_ingrediente: int = (
				orden_indices[indice_meta_actual - 1]
			)


			var ingrediente: int = int(
				mapa_puntos[casilla_removida]
			)


			if ingrediente == ultimo_ingrediente:

				indice_meta_actual -= 1


	# =================================================
	# QUITAR LÍNEA
	# =================================================

	if linea.get_point_count() > 0:

		linea.remove_point(
			linea.get_point_count() - 1
		)


	queue_redraw()


# =====================================================
# COMPROBAR VICTORIA
# =====================================================

func comprobar_victoria() -> void:

	var total_puntos_validos: int = (
		orden_indices.size()
	)

	var total_casillas: int = (
		TAMAÑO * TAMAÑO
	)


	# =================================================
	# COMPROBAR TABLERO COMPLETO
	# =================================================

	if camino.size() != total_casillas:
		return


	# =================================================
	# COMPROBAR LOS 6 INGREDIENTES
	# =================================================

	if indice_meta_actual < total_puntos_validos:
		return


	# =================================================
	# EVITAR REPETIR
	# =================================================

	if nivel_completado:
		return


	# =================================================
	# PUZZLE COMPLETADO
	# =================================================

	nivel_completado = true

	dibujando = false


	print("======================================")
	print("========= PUZZLE COMPLETADO ==========")
	print("======================================")

	print(
		"[PUZZLE] Casillas completadas: ",
		camino.size(),
		"/",
		total_casillas
	)


	# =================================================
	# AVISAR
	# =================================================

	nivel_superado.emit()


	# =================================================
	# COMPROBAR SIGUIENTE ESCENA
	# =================================================

	if siguiente_escena.is_empty():

		print(
			"[PUZZLE] ERROR: No hay siguiente escena asignada"
		)

		return


	print(
		"[PUZZLE] Cambiando a: ",
		siguiente_escena
	)


	# =================================================
	# PEQUEÑA ESPERA
	# =================================================

	await get_tree().create_timer(0.5).timeout


	# =================================================
	# SCENE MANAGER
	# =================================================

	SceneManager.change_scene(
		self,
		siguiente_escena
	)


# =====================================================
# OBTENER CASILLA
# =====================================================

func obtener_casilla(pos: Vector2) -> Vector2i:

	var x: int = int(
		(pos.x - posicion_tablero.x)
		/ TAM_CASILLA
	)

	var y: int = int(
		(pos.y - posicion_tablero.y)
		/ TAM_CASILLA
	)


	# =================================================
	# FUERA DEL TABLERO
	# =================================================

	if x < 0 or y < 0:
		return Vector2i(-1, -1)


	if x >= TAMAÑO or y >= TAMAÑO:
		return Vector2i(-1, -1)


	return Vector2i(x, y)


# =====================================================
# DISTANCIA
# =====================================================

func distancia(a: Vector2i, b: Vector2i) -> int:

	return abs(a.x - b.x) + abs(a.y - b.y)

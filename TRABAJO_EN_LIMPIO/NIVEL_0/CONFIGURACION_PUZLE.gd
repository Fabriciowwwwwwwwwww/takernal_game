extends Node2D

# --- SEÑAL AÑADIDA ---
# Esta señal avisará a cualquier otro script que el nivel se completó
signal nivel_superado

const TAM_CASILLA = 64
const TAMAÑO = 7
const ANCHO_TABLERO_LATERAL = 220
@export_category("Posición del Puzzle")

@export var posicion_tablero: Vector2 = Vector2(160,100)
@export_category("Panel de ingredientes")

@export var posicion_panel: Vector2 = Vector2(750,100)

@export var tamaño_panel: Vector2 = Vector2(180,450)
var dibujando = false
var camino = []
var linea : Line2D

@export var imagenes : Array[Texture2D] = []

var plantillas = [
	[Vector2i(3, 3), Vector2i(1, 1), Vector2i(5, 5), Vector2i(0, 6), Vector2i(6, 6), Vector2i(6, 0), Vector2i(0, 0), Vector2i(4, 4), Vector2i(2, 2)],
	[Vector2i(3, 4), Vector2i(4, 3), Vector2i(5, 4), Vector2i(2, 3), Vector2i(0, 5), Vector2i(6, 5), Vector2i(0, 1), Vector2i(6, 1)]
]

var posiciones_puntos = []
var mapa_puntos = {}
var orden_indices = []
var indice_meta_actual = 1

var nivel_completado = false

func _ready():
	randomize()
	var indice_plantilla = randi() % plantillas.size()
	posiciones_puntos = plantillas[indice_plantilla]

	var max_puntos = min(posiciones_puntos.size(), imagenes.size())
	for i in range(max_puntos):
		if imagenes[i] != null:
			mapa_puntos[posiciones_puntos[i]] = i
			orden_indices.append(i)

	linea = Line2D.new()
	linea.width = 16
	linea.default_color = Color("f97316")
	linea.z_index = 5
	linea.joint_mode = Line2D.LINE_JOINT_ROUND
	linea.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linea.end_cap_mode = Line2D.LINE_CAP_ROUND

	add_child(linea)

	crear_sprites_mapa()
	crear_sprites_tablero_lateral()
	
	queue_redraw()
func _draw():

	for x in range(TAMAÑO):
		for y in range(TAMAÑO):

			var rect = Rect2(
				posicion_tablero.x + x*TAM_CASILLA,
				posicion_tablero.y + y*TAM_CASILLA,
				TAM_CASILLA,
				TAM_CASILLA
			)

			draw_rect(rect, Color("fff7ed"), true)
			draw_rect(rect, Color("d6b98c"), false,3)


			var font = ThemeDB.fallback_font


			var texto_estado = "Casillas: " + str(camino.size()) + " / " + str(TAMAÑO * TAMAÑO)


			draw_string(
				font,
				Vector2(
					posicion_tablero.x,
					posicion_tablero.y + (TAMAÑO * TAM_CASILLA) + 35
				),
				texto_estado,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				18,
				Color.BLACK
			)


	var rect_panel = Rect2(
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
		4
	)

	draw_rect(rect_panel,Color("fafafa"),true)
	draw_rect(rect_panel,Color("9ca3af"),false,3)


func crear_sprites_mapa():

	for pos in mapa_puntos.keys():

		var idx = mapa_puntos[pos]


		var centro = Vector2(
			posicion_tablero.x + pos.x*TAM_CASILLA + TAM_CASILLA/2,
			posicion_tablero.y + pos.y*TAM_CASILLA + TAM_CASILLA/2
		)


		var sprite = Sprite2D.new()

		sprite.texture = imagenes[idx]
		sprite.position = centro
		sprite.z_index = 3


		var tamaño = sprite.texture.get_size()

		sprite.scale = Vector2(
			40.0/tamaño.x,
			40.0/tamaño.y
		)


		add_child(sprite)
func crear_sprites_tablero_lateral():

	var alto_fila = 55


	for pos in mapa_puntos.keys():

		var i = mapa_puntos[pos]


		var pos_y = posicion_panel.y + 60 + (i * alto_fila)



		# Número 1,2,3...
		var label = Label.new()

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



		# Imagen ingrediente
		var sprite = Sprite2D.new()

		sprite.texture = imagenes[i]

		sprite.position = Vector2(
			posicion_panel.x + 90,
			pos_y + 10
		)

		sprite.z_index = 3


		var tex_size = sprite.texture.get_size()

		sprite.scale = Vector2(
			35.0 / tex_size.x,
			35.0 / tex_size.y
		)


		add_child(sprite)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			intentar_iniciar_o_continuar()
		else:
			dibujando = false

	if event is InputEventMouseMotion and dibujando and not nivel_completado:
		mover(get_global_mouse_position())

func intentar_iniciar_o_continuar():
	var casilla = obtener_casilla(get_global_mouse_position())

	if mapa_puntos.has(casilla) and orden_indices.size() > 0 and mapa_puntos[casilla] == orden_indices[0]:
		camino.clear()
		linea.clear_points()
		dibujando = true
		indice_meta_actual = 1
		nivel_completado = false
		agregar_casilla(casilla)
		return

	if nivel_completado:
		return

	if camino.size() > 0 and casilla == camino[-1]:
		dibujando = true
	elif camino.size() > 1 and casilla == camino[-2]:
		retroceder()
		dibujando = true

func mover(pos):
	var casilla = obtener_casilla(pos)

	if casilla == Vector2i(-1, -1) or camino.size() == 0:
		return

	var ultima = camino[-1]

	if camino.size() > 1 and casilla == camino[-2]:
		retroceder()
		return

	if distancia(ultima, casilla) == 1:
		if not camino.has(casilla):
			if casilla in mapa_puntos:
				if indice_meta_actual < orden_indices.size():
					var meta_esperada = orden_indices[indice_meta_actual]
					if mapa_puntos[casilla] != meta_esperada:
						return
					else:
						indice_meta_actual += 1
				else:
					return
			
			agregar_casilla(casilla)

func agregar_casilla(casilla):
	camino.append(casilla)
	var pos_pixel = Vector2(
		posicion_tablero.x + casilla.x*TAM_CASILLA + TAM_CASILLA/2,
		posicion_tablero.y + casilla.y*TAM_CASILLA + TAM_CASILLA/2
	)
	linea.add_point(pos_pixel)
	queue_redraw()
	comprobar_victoria()

func retroceder():
	var casilla_removida = camino.pop_back()
	if casilla_removida in mapa_puntos:
		if indice_meta_actual > 1 and mapa_puntos[casilla_removida] == orden_indices[indice_meta_actual - 1]:
			indice_meta_actual -= 1
	linea.remove_point(linea.get_point_count() - 1)
	queue_redraw()

func comprobar_victoria():
	var total_puntos_validos = orden_indices.size()
	var total_casillas = TAMAÑO * TAMAÑO

	if camino.size() == total_casillas and indice_meta_actual >= total_puntos_validos:
		# Verificamos si no hemos ganado ya para no emitir la señal varias veces
		if not nivel_completado:
			nivel_completado = true
			
			emit_signal("nivel_superado")
			prints("completado puzle")
func obtener_casilla(pos):

	var x = int(
		(pos.x - posicion_tablero.x) / TAM_CASILLA
	)

	var y = int(
		(pos.y - posicion_tablero.y) / TAM_CASILLA
	)


	if x < 0 or y < 0 or x >= TAMAÑO or y >= TAMAÑO:
		return Vector2i(-1,-1)


	return Vector2i(x,y)
func distancia(a, b):
	return abs(a.x - b.x) + abs(a.y - b.y)

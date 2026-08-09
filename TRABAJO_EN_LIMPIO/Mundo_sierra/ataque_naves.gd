extends Node2D


# =========================================================
# ESCENA
# =========================================================

@export_category("Nave")
@export var nave_scene: PackedScene


# =========================================================
# SPAWN
# =========================================================

@export_category("Spawn")
@export var spawn_marker: Marker2D


# =========================================================
# TIPO DE ATAQUE
# =========================================================

enum TipoAtaque {
	ALEATORIO,
	GRAVITUS,
	SERPIENTE,
	FORMACION
}

@export_category("Tipo de Ataque")
@export var tipo_ataque: TipoAtaque = TipoAtaque.ALEATORIO


# =========================================================
# FORMACION
# =========================================================

@export_category("Formación")

@export var cantidad_naves: int = 5
@export var separacion_vertical: float = 70.0
@export var intervalo_salida: float = 0.45


# =========================================================
# MOVIMIENTO NORMAL
# =========================================================

@export_category("Movimiento")

@export var velocidad_nave: float = 250.0
@export var amplitud_nave: float = 90.0
@export var frecuencia_nave: float = 3.5


# =========================================================
# SERPIENTE NOKIA
# =========================================================

@export_category("Serpiente Nokia")

# Cantidad de rocotos
@export var cantidad_serpiente: int = 8

# Distancia entre rocotos
@export var separacion_segmentos: float = 75.0

# Velocidad general de la serpiente
@export var velocidad_nokia: float = 260.0

# Cuánto avanza horizontalmente antes de quebrar
@export var distancia_quiebre: float = 300.0

# Cuánto sube o baja
@export var distancia_vertical_quiebre: float = 180.0

# Spawns múltiples para la serpiente (agrega 3 en el inspector)
@export var spawns_serpiente: Array[Marker2D] = []

# Límites del mapa
@export var limite_izquierdo_nokia: float = 100.0
@export var limite_derecho_nokia: float = 1800.0
@export var limite_arriba_nokia: float = 150.0
@export var limite_abajo_nokia: float = 850.0

# Cantidad de quiebres
@export var cantidad_quiebres_nokia: int = 8

# Margen adicional
@export var margen_pantalla: float = 60.0


# =========================================================
# VARIABLES GENERALES
# =========================================================

var atacando: bool = false

var posiciones: Array[float] = []
var orden_salida: Array[int] = []


# =========================================================
# SERPIENTE
# =========================================================

var naves_serpiente: Array[Area2D] = []

var historial_serpiente: PackedVector2Array = []

var movimiento_serpiente: bool = false


# =========================================================
# CABEZA
# =========================================================

var cabeza_serpiente: Vector2 = Vector2.ZERO


# Dirección actual
var direccion_serpiente: Vector2 = Vector2.LEFT


# Dirección horizontal
# -1 = izquierda
#  1 = derecha
var direccion_horizontal: float = -1.0


# Dirección vertical
# -1 = arriba
#  1 = abajo
var direccion_vertical: float = 1.0


# =========================================================
# DISTANCIAS
# =========================================================

var distancia_recorrida_horizontal: float = 0.0
var distancia_recorrida_vertical: float = 0.0


# =========================================================
# FASE
# =========================================================

# 0 = horizontal
# 1 = vertical

var fase_serpiente: int = 0


# =========================================================
# QUIEBRES
# =========================================================

var quiebres_nokia: int = 0


# =========================================================
# FINAL
# =========================================================

var serpiente_terminando: bool = false


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	print("")
	print("======================================")
	print("[ATAQUE NAVES] READY")
	print("======================================")

	if nave_scene == null:

		print(
			"[ERROR] nave_scene NO asignada"
		)

	else:

		print(
			"[OK] nave_scene existe"
		)


	if spawn_marker == null:

		print(
			"[ERROR] spawn_marker NO asignado"
		)

	else:

		print(
			"[OK] spawn_marker existe"
		)


# =========================================================
# INICIAR ATAQUE
# =========================================================

func iniciar_ataque() -> void:

	print("")
	print("[DEBUG] iniciar_ataque() fue llamado")


	if atacando:

		print(
			"[DEBUG] Ya hay un ataque activo"
		)

		return


	if nave_scene == null:

		push_error(
			"[ERROR] nave_scene es NULL"
		)

		return


	if spawn_marker == null:

		push_error(
			"[ERROR] spawn_marker es NULL"
		)

		return


	atacando = true


	var ataque_actual: TipoAtaque = tipo_ataque


	# =====================================================
	# ALEATORIO
	# =====================================================

	if ataque_actual == TipoAtaque.ALEATORIO:

		var ataques_posibles: Array[TipoAtaque] = [
			TipoAtaque.GRAVITUS,
			TipoAtaque.SERPIENTE,
			TipoAtaque.FORMACION
		]

		ataque_actual = ataques_posibles.pick_random()


	print(
		"[DEBUG] Ataque configurado: ",
		TipoAtaque.keys()[ataque_actual]
	)


	# =====================================================
	# EJECUTAR
	# =====================================================

	match ataque_actual:

		TipoAtaque.GRAVITUS:

			print(
				"[DEBUG] Entrando en GRAVITUS"
			)

			ataque_gravitus()


		TipoAtaque.SERPIENTE:

			print(
				"[DEBUG] Entrando en SERPIENTE"
			)

			ataque_serpiente()


		TipoAtaque.FORMACION:

			print(
				"[DEBUG] Entrando en FORMACION"
			)

			ataque_formacion()


	print(
		"[DEBUG] iniciar_ataque() terminó"
	)


# =========================================================
# GRAVITUS
# =========================================================

func ataque_gravitus() -> void:

	print("")
	print("[GRAVITUS] =======================")
	print("[GRAVITUS] INICIANDO")
	print("[GRAVITUS] =======================")


	var nave: Area2D = crear_nave(
		spawn_marker.global_position
	)


	if nave == null:

		print(
			"[GRAVITUS] ERROR creando nave"
		)

		atacando = false

		return


	if nave.has_method("configurar_movimiento"):

		nave.configurar_movimiento(
			velocidad_nave,
			amplitud_nave,
			frecuencia_nave,
			0.0,
			0
		)


	print(
		"[GRAVITUS] Nave creada correctamente"
	)


	atacando = false


# =========================================================
# SERPIENTE (CON MULTI-SPAWN ALEATORIO)
# =========================================================
func ataque_serpiente() -> void:
	direccion_horizontal = -1.0
	direccion_vertical = 1.0
	
	fase_serpiente = 0
	distancia_recorrida_horizontal = 0.0
	distancia_recorrida_vertical = 0.0
	quiebres_nokia = 0
	serpiente_terminando = false
	movimiento_serpiente = false

	naves_serpiente.clear()
	historial_serpiente.clear()

	# Elegir un spawn aleatorio de los 3 configurados (si existen)
	var spawn_pos: Vector2 = spawn_marker.global_position
	
	if not spawns_serpiente.is_empty():
		var marker_elegido: Marker2D = spawns_serpiente.pick_random()
		if is_instance_valid(marker_elegido):
			spawn_pos = marker_elegido.global_position
			print("[SERPIENTE] Spawn aleatorio seleccionado en: ", spawn_pos)

	for i in range(cantidad_serpiente):
		var posicion: Vector2 = spawn_pos + Vector2(i * separacion_segmentos, 0.0)
		var nave: Area2D = crear_nave(posicion)
		if nave:
			if nave.has_method("detener_movimiento"): 
				nave.detener_movimiento()
			naves_serpiente.append(nave)

	if naves_serpiente.is_empty():
		atacando = false
		return

	cabeza_serpiente = naves_serpiente[0].global_position

	var paso_historial: float = 2.0 
	var puntos_iniciales: int = int((cantidad_serpiente * separacion_segmentos) / paso_historial) + 50

	for i in range(puntos_iniciales):
		historial_serpiente.append(spawn_pos + Vector2(i * paso_historial, 0.0))

	movimiento_serpiente = true
	atacando = false


# =========================================================
# FORMACION
# =========================================================

func ataque_formacion() -> void:

	print("")
	print(
		"[FORMACION] INICIANDO"
	)


	crear_formacion()


	for indice in orden_salida:

		lanzar_nave(
			posiciones[indice]
		)


	print(
		"[FORMACION] TERMINADA"
	)


	atacando = false


# =========================================================
# CREAR FORMACION
# =========================================================

func crear_formacion() -> void:

	posiciones.clear()
	orden_salida.clear()


	var centro_y: float = (
		spawn_marker.global_position.y
	)


	var mitad: float = (
		(cantidad_naves - 1) / 2.0
	)


	for i in range(
		cantidad_naves
	):

		var y: float = (
			centro_y
			+ (
				(i - mitad)
				* separacion_vertical
			)
		)


		posiciones.append(y)
		orden_salida.append(i)


	orden_salida.shuffle()


# =========================================================
# LANZAR NAVE FORMACION
# =========================================================

func lanzar_nave(y: float) -> void:

	var posicion: Vector2 = Vector2(
		spawn_marker.global_position.x,
		y
	)


	var nave: Area2D = crear_nave(
		posicion
	)


	if nave == null:

		return


	var desfase: float = randf_range(
		0.0,
		TAU
	)


	if nave.has_method(
		"configurar_movimiento"
	):

		nave.configurar_movimiento(
			velocidad_nave,
			amplitud_nave,
			frecuencia_nave,
			desfase,
			0
		)


# =========================================================
# CREAR NAVE
# =========================================================

func crear_nave(
	posicion: Vector2
) -> Area2D:

	if nave_scene == null:

		return null


	var nodo: Node = (
		nave_scene.instantiate()
	)


	if nodo == null or not nodo is Area2D:

		if nodo:
			nodo.queue_free()

		return null


	var nave: Area2D = (
		nodo as Area2D
	)

	nave.global_position = posicion

	var escena_actual: Node = (
		get_tree().current_scene
	)


	if escena_actual == null:

		nave.queue_free()

		return null


	escena_actual.call_deferred(
		"add_child",
		nave
	)


	return nave


# =========================================================
# MOVIMIENTO DE SERPIENTE
# =========================================================

func mover_serpiente(delta: float) -> void:
	if not movimiento_serpiente or naves_serpiente.is_empty(): 
		return
	var cabeza: Area2D = naves_serpiente[0]
	if not is_instance_valid(cabeza):
		movimiento_serpiente = false
		return

	if fase_serpiente == 0:
		var movimiento_x := direccion_horizontal * velocidad_nokia * delta
		cabeza_serpiente.x += movimiento_x
		distancia_recorrida_horizontal += abs(movimiento_x)

		if distancia_recorrida_horizontal >= distancia_quiebre:
			distancia_recorrida_horizontal = 0.0
			fase_serpiente = 1 
			distancia_recorrida_vertical = 0.0
			quiebres_nokia += 1
			direccion_vertical *= -1.0 

	elif fase_serpiente == 1:
		var movimiento_y := direccion_vertical * velocidad_nokia * delta
		cabeza_serpiente.y += movimiento_y
		distancia_recorrida_vertical += abs(movimiento_y)

		var cambio_fase: bool = false
		
		if cabeza_serpiente.y <= limite_arriba_nokia:
			cabeza_serpiente.y = limite_arriba_nokia
			cambio_fase = true
		elif cabeza_serpiente.y >= limite_abajo_nokia:
			cabeza_serpiente.y = limite_abajo_nokia
			cambio_fase = true
		elif distancia_recorrida_vertical >= distancia_vertical_quiebre:
			cambio_fase = true

		if cambio_fase:
			terminar_quiebre_vertical()

	cabeza.global_position = cabeza_serpiente

	if historial_serpiente.is_empty() or cabeza_serpiente.distance_to(historial_serpiente[0]) > 0.5:
		historial_serpiente.insert(0, cabeza_serpiente)

	var historial_maximo := 6000
	if historial_serpiente.size() > historial_maximo:
		historial_serpiente.resize(historial_maximo)

	actualizar_cuerpo_serpiente()


# =========================================================
# TERMINAR QUIEBRE VERTICAL
# =========================================================

func terminar_quiebre_vertical() -> void:
	fase_serpiente = 0
	distancia_recorrida_horizontal = 0.0
	distancia_recorrida_vertical = 0.0
	direccion_horizontal = -1.0

	if quiebres_nokia >= cantidad_quiebres_nokia:
		iniciar_salida_serpiente()

func iniciar_salida_serpiente() -> void:
	if serpiente_terminando: 
		return
	serpiente_terminando = true
	fase_serpiente = 0
	direccion_horizontal = -1.0


# =========================================================
# ACTUALIZAR CUERPO (ESTABLE E INTERPOLADO)
# =========================================================
func actualizar_cuerpo_serpiente() -> void:
	if historial_serpiente.size() < 2: 
		return

	for i in range(1, naves_serpiente.size()):
		var nave: Area2D = naves_serpiente[i]
		if not is_instance_valid(nave): 
			continue

		var distancia_objetivo: float = i * separacion_segmentos
		var acumulado: float = 0.0
		var objetivo: Vector2 = historial_serpiente[historial_serpiente.size() - 1]

		for j in range(historial_serpiente.size() - 1):
			var punto_a: Vector2 = historial_serpiente[j]
			var punto_b: Vector2 = historial_serpiente[j + 1]
			var distancia: float = punto_a.distance_to(punto_b)

			if acumulado + distancia >= distancia_objetivo:
				var restante: float = distancia_objetivo - acumulado
				var t: float = restante / distancia if distancia > 0.0 else 0.0
				objetivo = punto_a.lerp(punto_b, t)
				break

			acumulado += distancia

		nave.global_position = objetivo


# =========================================================
# PHYSICS PROCESS
# =========================================================

func _physics_process(delta: float) -> void:
	if movimiento_serpiente: 
		mover_serpiente(delta)

	for i in range(naves_serpiente.size() - 1, -1, -1):
		if not is_instance_valid(naves_serpiente[i]):
			naves_serpiente.remove_at(i)

	if naves_serpiente.is_empty() and movimiento_serpiente:
		movimiento_serpiente = false
		historial_serpiente.clear()
		return

	if serpiente_terminando:
		if naves_serpiente.is_empty() or naves_serpiente[0].global_position.x < limite_izquierdo_nokia - 300.0:
			finalizar_serpiente()

func finalizar_serpiente() -> void:
	movimiento_serpiente = false
	serpiente_terminando = false
	for nave in naves_serpiente:
		if is_instance_valid(nave): 
			nave.queue_free()
	naves_serpiente.clear()
	historial_serpiente.clear()

extends CharacterBody2D

@export_category("Posición 3 flechas (Markers)")
@export var marker_flecha_arriba: Marker2D
@export var marker_flecha_centro: Marker2D
@export var marker_flecha_abajo: Marker2D

var contador_herido: int = 0

@export_category("Patrón de flechas")
@export var cantidad_flecha_grande: int = 25
@export var cantidad_flecha_pequena: int = 13
@export var escala_flecha_grande: float = 1.8
@export var escala_flecha_pequena: float = 1.0
@export var velocidad_movimiento_ataque: float = 500.0
@export var pausa_entre_flechas: float = 0.2

@export_category("Duración animaciones")
@export var duracion_animacion_ataque: float = 3.0
@export var duracion_animacion_herido: float = 3.0

var animacion_ataque_activa: bool = false
var animacion_herido_activa: bool = false

@export_category("Ráfaga especial")
@export var tiempo_rafaga_especial: float = 12.0
@export var cantidad_flecha_lateral: int = 10
@export var separacion_especial: float = 28.0

var tiempo_especial: float = 0.0

# =========================================================
# PROYECTILES
# =========================================================
@export_category("Proyectiles")
@export var rocoto_pequeno_scene: PackedScene
@export var rocoto_teledirigido_scene: PackedScene

var jugadores: Array[Node2D] = []

func asignar_jugadores(lista_jugadores: Array[Node2D]) -> void:
	jugadores = lista_jugadores
	print("Jugadores recibidos por enemigo: ", jugadores.size())

# =========================================================
# MOVIMIENTO DEL ENEMIGO
# =========================================================
@export_category("Movimiento")
@export var velocidad_vertical: float = 250.0
@export var limite_arriba: float = 100.0
@export var limite_abajo: float = 600.0

var direccion_vertical := 1.0

# =========================================================
# ATAQUES
# =========================================================
@export_category("Ataques")
@export var tiempo_entre_ataques: float = 1
@export var tiempo_entre_proyectiles: float = 0.08
@export var cantidad_por_flecha: int = 5
@export var separacion_flecha: float = 32.0

var atacando: bool = false

# =========================================================
# NODOS Y ANIMACIONES
# =========================================================
@onready var marker_disparo: Marker2D = $MarkerDisparo
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export_category("Posición 3 flechas")
# Ajustadas para que no queden tan extremas y se centren mejor en pantalla
@export var altura_flecha_arriba: float = 220.0
@export var altura_flecha_abajo: float = 460.0


# =========================================================
# MOVIMIENTO DEL ENEMIGO
# =========================================================


# Contador para la animación de herido
@export_category("Posición 3 flechas")

@export_category("Patrón de flechas")

@export_category("Ráfaga especial")


# =========================================================
# PROYECTILES
# =========================================================



# =========================================================
# MOVIMIENTO DEL ENEMIGO
# =========================================================



# =========================================================
# ATAQUES
# =========================================================



# =========================================================
# READY
# =========================================================
func _physics_process(delta: float) -> void:
	if not atacando:
		mover_vertical(delta)
func _ready():

	randomize()

	await get_tree().create_timer(1.0).timeout

	iniciar_patron()


# =========================================================
# PHYSICS
# =========================================================

func ataque_tres_flechas() -> void:
	if atacando:
		return

	if rocoto_pequeno_scene == null:
		return

	atacando = true

	print("======================================")
	print("=== ATAQUE 3 FLECHAS ===")
	print("=== ORDEN: CENTRO -> ARRIBA -> ABAJO ===")
	print("======================================")

	reproducir_animacion_ataque()

	# =====================================================
	# 1. FLECHA DEL CENTRO
	# =====================================================

	if marker_flecha_centro:
		print(">>> 1. DISPARANDO FLECHA CENTRO")
		disparar_flecha_con_forma(
			marker_flecha_centro.global_position
		)

	await get_tree().create_timer(
		pausa_entre_flechas
	).timeout

	# =====================================================
	# 2. FLECHA DE ARRIBA
	# =====================================================

	if marker_flecha_arriba:
		print(">>> 2. DISPARANDO FLECHA ARRIBA")
		disparar_flecha_con_forma(
			marker_flecha_arriba.global_position
		)

	await get_tree().create_timer(
		pausa_entre_flechas
	).timeout

	# =====================================================
	# 3. FLECHA DE ABAJO
	# =====================================================

	if marker_flecha_abajo:
		print(">>> 3. DISPARANDO FLECHA ABAJO")
		disparar_flecha_con_forma(
			marker_flecha_abajo.global_position
		)

	await get_tree().create_timer(0.8).timeout

	print("======================================")
	print("=== 3 FLECHAS TERMINADAS ===")
	print("======================================")

	atacando = false



func mover_a_altura(altura: float, velocidad_movimiento: float = -1.0) -> void:
	var velocidad_usada: float = velocidad_vertical
	if velocidad_movimiento > 0.0:
		velocidad_usada = velocidad_movimiento

	while abs(global_position.y - altura) > 3.0:
		global_position.y = move_toward(global_position.y, altura, velocidad_usada * get_process_delta_time())
		await get_tree().process_frame
	global_position.y = altura


# =========================================================
# FORMA DE FLECHA REAL (Diseño geométrico de punta de flecha)
# =========================================================
func disparar_flecha_con_forma(posicion: Vector2) -> void:
	if rocoto_pequeno_scene == null:
		return

	var s: float = separacion_flecha * escala_flecha_pequena

	# Coordenadas relativas en forma de flecha apuntando a la izquierda (<)
	var posiciones: Array[Vector2] = [
		# Punta delantera
		Vector2(0, 0),
		
		# Ala superior (diagonal superior)
		Vector2(1, -1),
		Vector2(2, -2),
		Vector2(3, -3),
		Vector2(4, -4),
		
		# Ala inferior (diagonal inferior)
		Vector2(1, 1),
		Vector2(2, 2),
		Vector2(3, 3),
		Vector2(4, 4),
		
		# Cuerpo / Eje central hacia atrás
		Vector2(2, 0),
		Vector2(4, 0),
		Vector2(6, 0),
		Vector2(8, 0)
	]

	for i in range(posiciones.size()):
		var bala: Node2D = rocoto_pequeno_scene.instantiate()
		get_tree().current_scene.add_child(bala)
		bala.global_position = posicion + Vector2(
			posiciones[i].x * s,
			posiciones[i].y * s
		)
		if bala.has_method("configurar_direccion"):
			bala.configurar_direccion(Vector2.LEFT)
func mover_vertical(delta: float) -> void:
	velocity.x = 0.0
	velocity.y = direccion_vertical * velocidad_vertical
	move_and_slide()

	if global_position.y <= limite_arriba:
		global_position.y = limite_arriba
		direccion_vertical = 1.0
	elif global_position.y >= limite_abajo:
		global_position.y = limite_abajo
		direccion_vertical = -1.0


# =========================================================
# FUNCIÓN PARA RECIBIR DAÑO (Llamada desde la bala)
# =========================================================
func recibir_daño() -> void:
	contador_herido += 1
	print("Enemigo golpeado. Acumulados: ", contador_herido)

	if contador_herido >= 6:
		contador_herido = 0
		reproducir_animacion_herido()


# =========================================================
# CONTROL DE ATAQUES
# =========================================================
func iniciar_patron() -> void:
	var ataques: Array[int] = [0, 1, 2,3]
	var ultimo_ataque: int = -1

	while is_inside_tree():
		ataques.shuffle()
		while ataques[0] == ultimo_ataque:
			ataques.shuffle()

		for tipo_ataque in ataques:
			if not is_inside_tree():
				return

			ultimo_ataque = tipo_ataque

			match tipo_ataque:
				0:
					print(">>> ATAQUE: 3 FLECHAS")
					await ataque_tres_flechas()
				1:
					print(">>> ATAQUE: DIAGONAL")
					await ataque_diagonal()
				2:
					print(">>> ATAQUE: MISIL TELEDIRIGIDO")
					await ataque_teledirigido()
				3:
					print(">>> ATAQUE: MISIL ataque_rafaga_especial")
					await ataque_rafaga_especial()

			await get_tree().create_timer(tiempo_entre_ataques).timeout


func ataque_teledirigido() -> void:
	if jugadores.is_empty():
		return

	if rocoto_teledirigido_scene == null:
		return

	atacando = true
	print("=== ATAQUE ROCOTO TELEDIRIGIDO ===")

	var jugador_objetivo: Node2D = jugadores.pick_random()
	var altura_objetivo: float = jugador_objetivo.global_position.y

	while abs(global_position.y - altura_objetivo) > 3.0:
		global_position.y = move_toward(
			global_position.y,
			altura_objetivo,
			velocidad_vertical * get_process_delta_time()
		)
		await get_tree().process_frame

	global_position.y = altura_objetivo

	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("ataque"):
		animated_sprite.play("ataque")

	var bala: Node2D = rocoto_teledirigido_scene.instantiate()
	get_tree().current_scene.add_child(bala)
	bala.global_position = marker_disparo.global_position

	print("ROCOTO TELEDIRIGIDO DISPARADO")
	
	await get_tree().create_timer(0.5).timeout
	atacando = false


# =========================================================
# ATAQUE 3 FLECHAS CON 3 MARKERS ESPECÍFICOS
# =========================================================


func disparar_flecha_grande(posicion: Vector2) -> void:
	if rocoto_pequeno_scene == null:
		return
	var s: float = separacion_flecha * escala_flecha_grande
	var posiciones = [Vector2(4,-4),Vector2(3,-3),Vector2(2,-2),Vector2(1,-1),Vector2(0,-2),Vector2(0,-1),Vector2(0,0),Vector2(0,1),Vector2(0,2),Vector2(1,1),Vector2(2,2),Vector2(3,3),Vector2(4,4)]
	for offset in posiciones:
		var bala = rocoto_pequeno_scene.instantiate()
		get_tree().current_scene.add_child(bala)
		bala.global_position = posicion + Vector2(offset.x * s, offset.y * s)
		if bala.has_method("configurar_direccion"):
			bala.configurar_direccion(Vector2.LEFT)


func disparar_flecha_horizontal(posicion: Vector2, escala: float = 1.0) -> void:
	if rocoto_pequeno_scene == null:
		return

	var s: float = separacion_flecha * escala
	var posiciones: Array[Vector2] = [
		Vector2(4, -4),
		Vector2(3, -3),
		Vector2(2, -2),
		Vector2(1, -1),
		Vector2(0, -2),
		Vector2(0, -1),
		Vector2(0, 0),
		Vector2(0, 1),
		Vector2(0, 2),
		Vector2(1, 1),
		Vector2(2, 2),
		Vector2(3, 3),
		Vector2(4, 4)
	]

	for i in range(posiciones.size()):
		var bala: Node2D = rocoto_pequeno_scene.instantiate()
		get_tree().current_scene.add_child(bala)
		bala.global_position = posicion + Vector2(
			posiciones[i].x * s,
			posiciones[i].y * s
		)
		if bala.has_method("configurar_direccion"):
			bala.configurar_direccion(Vector2.LEFT)


func ataque_diagonal() -> void:
	if atacando:
		return
	atacando = true
	var direccion_vertical_val = -1 if randi() % 2 == 0 else 1
	disparar_flecha_diagonal(marker_disparo.global_position, direccion_vertical_val, escala_flecha_pequena)
	await get_tree().create_timer(pausa_entre_flechas).timeout
	atacando = false


func disparar_flecha_diagonal(
	posicion: Vector2,
	direccion_vertical_flecha: int,
	escala: float = 1.0
) -> void:
	if rocoto_pequeno_scene == null:
		return

	var total_diagonal: int = 9
	var distancia_x: float = 35.0 * escala
	var distancia_y: float = 28.0 * escala

	for i in range(total_diagonal):
		var bala: Node2D = rocoto_pequeno_scene.instantiate()
		get_tree().current_scene.add_child(bala)

		var x: float = (float(i) - float(total_diagonal - 1) / 2.0) * distancia_x
		var y: float = (float(i) - float(total_diagonal - 1) / 2.0) * distancia_y * float(direccion_vertical_flecha)

		bala.global_position = posicion + Vector2(x, y)

		if bala.has_method("configurar_direccion"):
			bala.configurar_direccion(Vector2.LEFT)


# =========================================================
# ANIMACIONES
# =========================================================
func reproducir_animacion_ataque() -> void:
	if animated_sprite == null or not animated_sprite.sprite_frames.has_animation("ataque"):
		return

	animacion_ataque_activa = true
	animated_sprite.play("ataque")

	await get_tree().create_timer(duracion_animacion_ataque).timeout
	if not is_inside_tree():
		return

	animacion_ataque_activa = false
	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")


func reproducir_animacion_herido() -> void:
	if animated_sprite == null or not animated_sprite.sprite_frames.has_animation("herido"):
		return

	animacion_herido_activa = true
	animated_sprite.play("herido")

	await get_tree().create_timer(duracion_animacion_herido).timeout
	if not is_inside_tree():
		return

	animacion_herido_activa = false
	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")



# =========================================================
# FUNCIÓN PARA RECIBIR DAÑO (Llamada desde la bala)
# =========================================================

func reproducir_animacion(nombre: String) -> void:

	if animated_sprite == null:
		return

	if animated_sprite.sprite_frames == null:
		return

	if not animated_sprite.sprite_frames.has_animation(nombre):
		return

	animated_sprite.play(nombre)

# =========================================================
# CONTROL DE ATAQUES
# =========================================================

# =========================================================
# MOVIMIENTO VERTICAL
# =========================================================



func disparar_flecha(
	posicion: Vector2,
	direccion: Vector2
) -> void:

	if rocoto_pequeno_scene == null:
		return


	var s: float = separacion_flecha


	# =====================================================
	# FLECHA DE 13 PROYECTILES
	#
	#          X
	#         X
	#        X
	#       X
	#      XXXXX
	#       X
	#        X
	#         X
	#          X
	#
	# =====================================================

	var posiciones: Array[Vector2] = [

		# Punta superior
		Vector2(4, -4),

		# Lado superior
		Vector2(3, -3),
		Vector2(2, -2),
		Vector2(1, -1),

		# Línea central
		Vector2(0, -2),
		Vector2(0, -1),
		Vector2(0, 0),
		Vector2(0, 1),
		Vector2(0, 2),

		# Lado inferior
		Vector2(1, 1),
		Vector2(2, 2),
		Vector2(3, 3),

		# Punta inferior
		Vector2(4, 4)
	]


	for offset: Vector2 in posiciones:

		var bala: Node2D = rocoto_pequeno_scene.instantiate()

		get_tree().current_scene.add_child(bala)


		bala.global_position = posicion + Vector2(
			offset.x * s,
			offset.y * s
		)


		if bala.has_method("configurar_direccion"):

			bala.configurar_direccion(
				direccion.normalized()
			)

# =========================================================
# ROCOTO GRANDE
# =========================================================




func ataque_rafaga_especial() -> void:
	if atacando:
		return

	if rocoto_pequeno_scene == null:
		return

	atacando = true

	print("======================================")
	print("=== INICIANDO RAFAGA ESPECIAL ===")
	print("======================================")

	var posicion: Vector2 = marker_disparo.global_position

	# =====================================================
	# CONFIGURACIÓN DEL ATAQUE
	# =====================================================

	# Tiempo entre cada grupo de proyectiles
	var pausa_entre_grupos: float = 0.45

	# =====================================================
	# ELEGIR QUÉ LATERAL SALE PRIMERO
	# =====================================================

	var direccion_lateral: int = 1

	if randi() % 2 == 0:
		direccion_lateral = -1

	# =====================================================
	# 1. RAFAGA CENTRAL
	# =====================================================

	print(">>> 1. RAFAGA CENTRAL")

	await disparar_flecha_especial(
		posicion,
		Vector2.LEFT,
		cantidad_flecha_grande,
		0.0
	)

	# Espera antes del siguiente grupo
	await get_tree().create_timer(
		pausa_entre_grupos
	).timeout

	# =====================================================
	# 2. RAFAGA LATERAL
	# =====================================================

	print(">>> 2. RAFAGA LATERAL")

	await disparar_flecha_lateral_especial(
		posicion,
		direccion_lateral,
		cantidad_flecha_lateral
	)

	# Espera antes del último grupo
	await get_tree().create_timer(
		pausa_entre_grupos
	).timeout

	# =====================================================
	# 3. RAFAGA LATERAL CONTRARIA
	# =====================================================

	print(">>> 3. RAFAGA LATERAL CONTRARIA")

	await disparar_flecha_lateral_especial(
		posicion,
		-direccion_lateral,
		cantidad_flecha_lateral
	)

	# =====================================================
	# FINAL
	# =====================================================

	await get_tree().create_timer(0.6).timeout

	atacando = false

	print("======================================")
	print("=== RAFAGA ESPECIAL TERMINADA ===")
	print("======================================")



func disparar_flecha_especial(
	posicion: Vector2,
	direccion: Vector2,
	cantidad: int,
	offset_y: float
) -> void:

	if rocoto_pequeno_scene == null:
		return


	var separacion: float = separacion_especial


	for i: int in range(cantidad):

		var bala: Node2D = rocoto_pequeno_scene.instantiate()

		get_tree().current_scene.add_child(bala)


		var desplazamiento_y: float = (
			float(i)
			- float(cantidad - 1) / 2.0
		) * separacion


		bala.global_position = posicion + Vector2(
			0.0,
			desplazamiento_y + offset_y
		)


		if bala.has_method("configurar_direccion"):

			bala.configurar_direccion(
				direccion.normalized()
			)


		await get_tree().create_timer(
			0.035
		).timeout
func disparar_flecha_lateral_especial(
	posicion: Vector2,
	direccion_vertical: int,
	cantidad: int
) -> void:

	if rocoto_pequeno_scene == null:
		return


	var direccion: Vector2 = Vector2(
		-1.0,
		float(direccion_vertical) * 0.55
	).normalized()


	for i: int in range(cantidad):

		var bala: Node2D = rocoto_pequeno_scene.instantiate()

		get_tree().current_scene.add_child(bala)


		var desplazamiento: float = (
			float(i)
			- float(cantidad - 1) / 2.0
		) * separacion_especial


		bala.global_position = (
			posicion
			+ Vector2(
				0.0,
				desplazamiento
			)
		)


		if bala.has_method("configurar_direccion"):

			bala.configurar_direccion(
				direccion
			)


		await get_tree().create_timer(
			0.035
		).timeout
		
		

extends Area2D


# =========================================================
# MODOS
# =========================================================

enum ModoMovimiento {
	GRAVITUS,
	SERPIENTE,
	ZIGZAG
}


@export_category("Movimiento")

@export var modo: ModoMovimiento = ModoMovimiento.GRAVITUS

@export var velocidad: float = 250.0

@export var amplitud: float = 80.0

@export var frecuencia: float = 3.0


# =========================================================
# SERPIENTE
# =========================================================

@export_category("Serpiente")

@export var velocidad_vertical: float = 220.0

@export var limite_vertical: float = 120.0


# =========================================================
# DAÑO
# =========================================================

@export_category("Daño")

@export var destruir_con_bala: bool = true
@onready var animacion_rocoto: AnimatedSprite2D = $animacion_rocoto

# =========================================================
# VARIABLES
# =========================================================

var tiempo: float = 0.0

var desfase: float = 0.0

var posicion_inicial: Vector2 = Vector2.ZERO

var destruida: bool = false


# =========================================================
# VARIABLES SERPIENTE
# =========================================================

var serpiente_id: int = 0

var direccion_vertical: float = 1.0

var posicion_y_inicial: float = 0.0


# =========================================================
# READY
# =========================================================

func _ready() -> void:
	animacion_rocoto.play("idle")
	
	# Asegurarnos de escuchar cuando termine la animación de destrucción
	if not animacion_rocoto.animation_finished.is_connected(_on_animacion_terminada):
		animacion_rocoto.animation_finished.connect(_on_animacion_terminada)

	posicion_inicial = global_position
	posicion_y_inicial = global_position.y


	# -----------------------------------------------------
	# COLISIONES
	# -----------------------------------------------------

	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


# =========================================================
# CONFIGURAR MOVIMIENTO NORMAL
# =========================================================

func configurar_movimiento(
	velocidad_nueva: float,
	amplitud_nueva: float,
	frecuencia_nueva: float,
	desfase_nuevo: float,
	modo_nuevo: ModoMovimiento = ModoMovimiento.GRAVITUS
) -> void:

	velocidad = velocidad_nueva
	amplitud = amplitud_nueva
	frecuencia = frecuencia_nueva
	desfase = desfase_nuevo
	modo = modo_nuevo
	tiempo = 0.0
	posicion_inicial = global_position
	posicion_y_inicial = global_position.y


# =========================================================
# CONFIGURAR SERPIENTE
# =========================================================

func configurar_serpiente(
	velocidad_nueva: float,
	velocidad_vertical_nueva: float,
	limite_vertical_nuevo: float,
	id_nuevo: int
) -> void:

	velocidad = velocidad_nueva
	velocidad_vertical = velocidad_vertical_nueva
	limite_vertical = limite_vertical_nuevo
	serpiente_id = id_nuevo
	modo = ModoMovimiento.SERPIENTE
	tiempo = 0.0
	posicion_inicial = global_position
	posicion_y_inicial = global_position.y
	direccion_vertical = 1.0


# =========================================================
# AREA2D (Detecta balas del jugador)
# =========================================================

func _on_area_entered(area: Area2D) -> void:
	if destruida:
		return

	# Verificamos si es la bala del jugador (por grupo o por método)
	if area.is_in_group("balas_jugador") or area.has_method("iniciar"):

		print("[ROCOTO] Chocó con la bala del jugador")

		# Destruir la bala del jugador
		if area.has_method("destruir"):
			area.destruir()
		else:
			area.queue_free()

		# Destruir este rocoto con animación
		destruir()


# =========================================================
# PHYSICSBODY (Detecta al Jugador)
# =========================================================

func _on_body_entered(body: Node2D) -> void:
	if destruida:
		return

	if body.has_method("recibir_daño"):
		print("[ROCOTO] Golpeó al jugador")
		body.recibir_daño()
		destruir()


# =========================================================
# DESTRUIR
# =========================================================

func destruir() -> void:
	if destruida:
		return

	destruida = true

	# Desactivar colisiones para que no siga interactuando mientras explota
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Reproducir animación de destrucción
	animacion_rocoto.play("destruir")

	print("[ROCOTO] DESTRUCCIÓN INICIADA: ", name)


# Callback cuando termina la animación "destruir"
func _on_animacion_terminada() -> void:
	if animacion_rocoto.animation == "destruir":
		queue_free()


# =========================================================
# PROCESS
# =========================================================

func _process(delta: float) -> void:
	if destruida:
		return

	tiempo += delta

	match modo:
		ModoMovimiento.GRAVITUS:
			movimiento_gravitus(delta)
		ModoMovimiento.SERPIENTE:
			movimiento_serpiente(delta)
		ModoMovimiento.ZIGZAG:
			movimiento_zigzag(delta)

	if global_position.x < -250.0:
		queue_free()


# =========================================================
# MOVIMIENTOS
# =========================================================

func movimiento_gravitus(delta: float) -> void:
	global_position.x -= velocidad * delta
	global_position.y = posicion_inicial.y + sin(tiempo * frecuencia + desfase) * amplitud

func movimiento_serpiente(delta: float) -> void:
	global_position.x -= velocidad * delta
	global_position.y += direccion_vertical * velocidad_vertical * delta

	var limite_superior: float = posicion_y_inicial - limite_vertical
	var limite_inferior: float = posicion_y_inicial + limite_vertical

	if global_position.y <= limite_superior:
		global_position.y = limite_superior
		direccion_vertical = 1.0
	elif global_position.y >= limite_inferior:
		global_position.y = limite_inferior
		direccion_vertical = -1.0

func movimiento_zigzag(delta: float) -> void:
	global_position.x -= velocidad * delta
	global_position.y = posicion_inicial.y + sin(tiempo * frecuencia + desfase) * amplitud

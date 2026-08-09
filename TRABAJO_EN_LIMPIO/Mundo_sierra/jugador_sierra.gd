extends CharacterBody2D

@export_category("Jugador")
@export_enum("Jugador 1", "Jugador 2") var jugador := "Jugador 1"
@export_category("Muerte")
@export var sprite_frame: SpriteFrames
@export_category("Animaciones")

@export var sprite_frames_condor: SpriteFrames
@export var sprite_frames_cuy: SpriteFrames
@onready var condor: AnimatedSprite2D = $Condor
@onready var cuy: AnimatedSprite2D = $Cuy
@export var velocidad_caida_cuy: float = 250.0

var muriendo: bool = false
@export_category("Movimiento")
@export var speed := 350.0

@export_category("Disparo")
@export var fire_rate := 0.15
@export var bullet_scene: PackedScene

@export_category("Dash")
@export var dash_speed := 900.0
@export var dash_duration := 0.20
@export var dash_cooldown := 0.5

@export_category("Daño")
@export var duracion_daño := 0.8

@onready var marker_disparo: Marker2D = $MarkerDisparo
@onready var cooldown_disparo: Timer = $CooldownDisparo

var left_action := ""
var right_action := ""
var up_action := ""
var down_action := ""
var shoot_action := ""
var dash_action := ""
var en_dash: bool = false
var puede_hacer_dash: bool = true
var can_shoot := true
var puede_recibir_daño := true

var hud: CanvasLayer
func _ready():
	add_to_group("jugador")
	
	hud = get_tree().get_first_node_in_group("hud")

	if hud == null:
		print("ADVERTENCIA: No se encontró el HUD")
	else:
		print("HUD encontrado correctamente")
	# =========================================================
	# APLICAR SPRITE FRAMES
	# =========================================================

	if sprite_frames_condor != null:
		condor.sprite_frames = sprite_frames_condor

	if sprite_frames_cuy != null:
		cuy.sprite_frames = sprite_frames_cuy


	# =========================================================
	# CONTROLES
	# =========================================================

	if jugador == "Jugador 1":

		left_action = "p1_left"
		right_action = "p1_right"
		up_action = "p1_jump"
		down_action = "p1_down"
		shoot_action = "p1_shoot"
		dash_action = "p1_dash"

	else:

		left_action = "p2_left"
		right_action = "p2_right"
		up_action = "p2_jump"
		down_action = "p2_down"
		shoot_action = "p2_shoot"
		dash_action = "p2_dash"

	print("Controles asignados:", jugador)


	# =========================================================
	# TIMER DE DISPARO
	# =========================================================

	cooldown_disparo.wait_time = fire_rate
	cooldown_disparo.one_shot = true

	if not cooldown_disparo.timeout.is_connected(
		_on_cooldown_disparo_timeout
	):
		cooldown_disparo.timeout.connect(
			_on_cooldown_disparo_timeout
		)


	# =========================================================
	# ANIMACIÓN INICIAL
	# =========================================================

	condor.play("idle")
	cuy.play("idle")
func _physics_process(_delta):

	if not en_dash:
		mover()

		disparar()

		dash()

	move_and_slide()


# =========================================================
# MOVIMIENTO
# =========================================================
func soltar_cuy_y_caer() -> void:

	if muriendo:
		return

	muriendo = true

	# Detener el movimiento del jugador
	velocity = Vector2.ZERO

	# =================================================
	# EL CUY SE SEPARA DEL CONDOR
	# =================================================

	var posicion_cuy: Vector2 = cuy.global_position

	# Sacarlo del jugador para que pueda caer independientemente
	var padre_actual := cuy.get_parent()

	padre_actual.remove_child(cuy)

	get_tree().current_scene.add_child(cuy)

	cuy.global_position = posicion_cuy

	# =================================================
	# CONDOR
	# =================================================

	condor.play("idle")

	# =================================================
	# ANIMACIÓN DEL CUY
	# =================================================

	cuy.play("idle")

	# =================================================
	# CAÍDA
	# =================================================

	while cuy.global_position.y < get_viewport_rect().size.y + 100.0:

		cuy.global_position.y += (
			velocidad_caida_cuy *
			get_process_delta_time()
		)

		await get_tree().process_frame
func mover():

	var direccion := Input.get_vector(
		left_action,
		right_action,
		up_action,
		down_action
	)

	velocity = direccion * speed


# =========================================================
# DISPARO
# =========================================================

func disparar():

	if not Input.is_action_pressed(shoot_action):
		return

	if not can_shoot:
		return

	if bullet_scene == null:
		return


	var bala = bullet_scene.instantiate()

	get_tree().current_scene.add_child(bala)

	bala.global_position = marker_disparo.global_position

	bala.global_rotation = marker_disparo.global_rotation


	if bala.has_method("configurar_direccion"):

		var direccion := Vector2.RIGHT.rotated(
			marker_disparo.global_rotation
		)

		bala.configurar_direccion(direccion)


	can_shoot = false

	cooldown_disparo.start()


func _on_cooldown_disparo_timeout():

	can_shoot = true


# =========================================================
# DASH
# =========================================================
func dash() -> void:

	if en_dash:
		return

	if not puede_hacer_dash:
		return

	if not Input.is_action_just_pressed(dash_action):
		return


	var direccion := Input.get_vector(
		left_action,
		right_action,
		up_action,
		down_action
	)


	# =====================================================
	# SI NO HAY DIRECCIÓN
	# =====================================================

	if direccion == Vector2.ZERO:
		direccion = Vector2.RIGHT


	# =====================================================
	# INICIAR DASH
	# =====================================================

	en_dash = true
	puede_hacer_dash = false

	velocity = direccion.normalized() * dash_speed

	print("DASH:", jugador)


	# =====================================================
	# DURACIÓN DEL DASH
	# =====================================================

	await get_tree().create_timer(
		dash_duration
	).timeout


	en_dash = false

	velocity = Vector2.ZERO


	# =====================================================
	# COOLDOWN
	# =====================================================

	await get_tree().create_timer(
		dash_cooldown
	).timeout


	puede_hacer_dash = true

	print("DASH DISPONIBLE")

# =========================================================
# DAÑO
# =========================================================
func recibir_daño() -> void:

	if not puede_recibir_daño:
		return

	if muriendo:
		return

	puede_recibir_daño = false

	print("Jugador recibió daño")


	# =====================================================
	# ANIMACIÓN DE DAÑO INMEDIATA
	# =====================================================

	condor.play("daño")
	cuy.play("daño")


	# =====================================================
	# QUITAR CORAZÓN
	# =====================================================

	if hud != null:

		if hud.has_method("perder_vida"):
			hud.perder_vida()

	else:

		print("ERROR: HUD es NULL")


	# =====================================================
	# DURACIÓN DEL DAÑO
	# =====================================================

	await get_tree().create_timer(
		duracion_daño
	).timeout


	# Si murió durante el daño, no volver a idle
	if muriendo:
		return


	# =====================================================
	# VOLVER A IDLE
	# =====================================================

	condor.play("idle")
	cuy.play("idle")


	# =====================================================
	# INVULNERABILIDAD EXTRA
	# =====================================================

	await get_tree().create_timer(
		0.15
	).timeout


	puede_recibir_daño = true

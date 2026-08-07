extends CharacterBody2D
var siendo_lanzado := false
@export var tiempo_invencible := 5.0
@export var tiempo_parpadeo := 2.0
var invencible := false
@export var tiempo_lanzamiento := 0.35
@export var angulo_lanzamiento := 35.0
@export var throw_force := 1200.0
var grab_action := ""
var jugador_cargado: CharacterBody2D = null
var siendo_cargado := false
var cargando := false
@export var speed := 260.0
@export var jump_force := -520.0
@export var gravity := 1400.0
@export var fire_rate := 0.15
@export var drop_time := 0.2
@export_enum("Jugador 1", "Jugador 2") var jugador := "Jugador 1"
var dropping := false
var can_shoot := true
var left_action := ""
var right_action := ""
var jump_action := ""
var dash_action := ""
var down_action := ""
@export var dash_speed := 650.0
@export var dash_time := 0.18
@export var dash_cooldown := 0.35
@export var bullet_scene: PackedScene
@export var sprite_frame: SpriteFrames
@onready var animacion_recurso: AnimatedSprite2D = $AnimatedSprite2D

var facing := 1

var is_dashing := false
var dash_timer := 0.0
var cooldown_timer := 0.0

func _ready():
	animacion_recurso.sprite_frames = sprite_frame
	$Arrow.visible = false

	if jugador == "Jugador 1":
		left_action = "p1_left"
		right_action = "p1_right"
		jump_action = "p1_jump"
		dash_action = "p1_dash"
		down_action = "p1_down"
		grab_action = "p1_grab"

	else:
		left_action = "p2_left"
		right_action = "p2_right"
		jump_action = "p2_jump"
		dash_action = "p2_dash"
		down_action = "p2_down"
		grab_action = "p2_grab"


	print("Controles asignados:", jugador)
func _physics_process(delta):

	# Si está siendo lanzado mantiene la fuerza recibida
	if siendo_lanzado:

		tiempo_lanzamiento -= delta

		move_and_slide()

		if tiempo_lanzamiento <= 0:
			siendo_lanzado = false
			tiempo_lanzamiento = 0.35

		return
	if Input.is_action_just_pressed(grab_action):

		if cargando:
			lanzar_companero()
		else:
			intentar_cargar()


	# Flecha mientras carga
	if cargando:

		$Arrow.visible = true

		var aim := Input.get_vector(
			left_action,
			right_action,
			jump_action,
			down_action
		)

		if aim != Vector2.ZERO:
			$Arrow.global_rotation = aim.angle()

	else:
		$Arrow.visible = false

	if siendo_cargado:
		velocity = Vector2.ZERO
		global_position = get_parent().global_position
		return

	# Gravedad
	if !is_on_floor() and !is_dashing:
		velocity.y += gravity * delta


	# Dash
	if is_dashing:

		dash_timer -= delta
		velocity.y = 0
		velocity.x = facing * dash_speed

		if dash_timer <= 0:
			is_dashing = false

	else:

		var dir := Input.get_axis(left_action, right_action)

		if dir != 0:
			facing = sign(dir)

		velocity.x = dir * speed


		# Salto
# Entrada de salto
		if Input.is_action_just_pressed(jump_action):

			if Input.is_action_pressed(down_action):
				drop_from_platform()

			elif is_on_floor():
				$salto_audio.play()
				velocity.y = jump_force

		# Después aplicar gravedad
		if !is_on_floor() and !is_dashing:
			velocity.y += gravity * delta

		# Dash
		cooldown_timer -= delta

		if Input.is_action_just_pressed(dash_action) and cooldown_timer <= 0:
			comenzar_dash()


	
# Flip personaje
	if facing > 0:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true


	move_and_slide()

	actualizar_animacion()



func actualizar_animacion():

	# Dash
	if is_dashing:
		$AnimatedSprite2D.play("dash")
		return


	# En el aire
	if !is_on_floor():

		if velocity.y < 0:
			$AnimatedSprite2D.play("jump")
		else:
			$AnimatedSprite2D.play("fall")

		return


	# Corriendo
	if abs(velocity.x) > 10:
		$AnimatedSprite2D.play("run")
		return


	# Quieto
	$AnimatedSprite2D.play("idle")



func comenzar_dash():

	is_dashing = true
	dash_timer = dash_time
	cooldown_timer = dash_cooldown






func drop_from_platform():
	

	print("BAJANDO")

	if dropping:
		return

	dropping = true

	set_collision_mask_value(2, false)

	# Fuerza a atravesar
	velocity.y = 200


	await get_tree().create_timer(drop_time).timeout


	set_collision_mask_value(2, true)

	dropping = false
	
func perder_vida():

	if invencible:
		return

	invencible = true

	$"../Ui".perder_vida()

	parpadear_invencible()

	await get_tree().create_timer(tiempo_invencible).timeout

	invencible = false
func cargar_companero(companero: CharacterBody2D):

	if cargando:
		return

	jugador_cargado = companero
	cargando = true

	companero.siendo_cargado = true
	companero.velocity = Vector2.ZERO

	# Poner detrás del jugador que carga
	companero.z_index = -1

	# Desactivar colisión mientras está encima
	companero.get_node("CollisionShape2D").set_deferred("disabled", true)

	companero.reparent($CarryMarker)
	companero.position = Vector2.ZERO

	$Arrow.visible = true

func lanzar_companero():

	if jugador_cargado == null:
		return

	var direccion := Vector2.ZERO

	if cos($Arrow.global_rotation) >= 0:
		direccion = Vector2.RIGHT.rotated(deg_to_rad(-angulo_lanzamiento))
	else:
		direccion = Vector2.LEFT.rotated(deg_to_rad(angulo_lanzamiento))

	direccion = direccion.normalized()


	jugador_cargado.reparent(get_parent())

	# Restaurar orden al salir
	jugador_cargado.z_index = 0

	jugador_cargado.global_position = $CarryMarker.global_position


	jugador_cargado.get_node("CollisionShape2D").set_deferred("disabled", false)


	jugador_cargado.siendo_cargado = false
	jugador_cargado.siendo_lanzado = true
	jugador_cargado.tiempo_lanzamiento = tiempo_lanzamiento


	jugador_cargado.velocity = direccion * throw_force


	jugador_cargado = null
	cargando = false

	$Arrow.visible = false
func intentar_cargar():

	if cargando:
		return

	for body in $GrabArea.get_overlapping_bodies():

		if body != self and body is CharacterBody2D:
			cargar_companero(body)
			break
func parpadear_invencible() -> void:

	var tiempo := 0.0

	while tiempo < tiempo_parpadeo:

		# Rojo
		$AnimatedSprite2D.modulate = Color(1, 0.2, 0.2)

		await get_tree().create_timer(0.15).timeout

		# Normal
		$AnimatedSprite2D.modulate = Color(1, 1, 1)

		await get_tree().create_timer(0.15).timeout

		tiempo += 0.3

	# Dejar color normal
	$AnimatedSprite2D.modulate = Color(1, 1, 1)

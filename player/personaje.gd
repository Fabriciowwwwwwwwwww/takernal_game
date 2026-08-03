extends CharacterBody2D

@export var speed := 260.0
@export var jump_force := -520.0
@export var gravity := 1400.0
@export var fire_rate := 0.15
@export var drop_time := 0.2

var dropping := false
var can_shoot := true

@export var dash_speed := 650.0
@export var dash_time := 0.18
@export var dash_cooldown := 0.35

@export var bullet_scene: PackedScene

var facing := 1

var is_dashing := false
var dash_timer := 0.0
var cooldown_timer := 0.0


func _physics_process(delta):

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

		var dir := Input.get_axis("move_left", "move_right")

		if dir != 0:
			facing = sign(dir)

		velocity.x = dir * speed


		# Salto
		if Input.is_action_just_pressed("ui_accept"):
			$salto_audio.play()

			if Input.is_action_pressed("down"):
				drop_from_platform()

			elif is_on_floor():
				velocity.y = jump_force


		# Dash
		cooldown_timer -= delta

		if Input.is_action_just_pressed("dash") and cooldown_timer <= 0:
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



func _process(delta):

	if Input.is_action_pressed("shoot") and can_shoot:
		disparar()



func disparar():

	can_shoot = false

	if bullet_scene == null:
		return


	var bala = bullet_scene.instantiate()

	get_tree().current_scene.add_child(bala)


	bala.global_position = $arma/Marker2D.global_position

	var mouse = get_global_mouse_position()

	bala.direction = (mouse - bala.global_position).normalized()


	await get_tree().create_timer(fire_rate).timeout

	can_shoot = true



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

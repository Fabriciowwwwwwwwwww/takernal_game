extends CharacterBody2D

@export var bala_escena: PackedScene
@export var tiempo_cooldown_disparo: float = 3.0

@export var vida_maxima: int = 3
var vida_actual: int

@export var speed := 260.0
@export var jump_force := -520.0
@export var gravity := 1400.0
@export var dash_speed := 650.0
@export var dash_time := 0.18
@export var dash_cooldown := 0.35

@export_enum("Jugador 1", "Jugador 2") var jugador := "Jugador 1"

var left_action := ""
var right_action := ""
var jump_action := ""
var dash_action := ""
var shoot_action := ""

var is_dashing := false
var dash_timer := 0.0
var cooldown_timer := 0.0
var invencible := false
var is_charging := false
var puede_disparar := true
var direccion_mirada := 1 

@onready var animacion: AnimatedSprite2D = $cuysin
@onready var punto_disparo: Marker2D = $Marker2D
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var salto_audio = $salto_audio

var pos_inicial_marcador: float

func _ready() -> void:
	vida_actual = vida_maxima
	
	if punto_disparo:
		pos_inicial_marcador = abs(punto_disparo.position.x)

	if jugador == "Jugador 1":
		left_action = "p1_left"
		right_action = "p1_right"
		jump_action = "p1_jump"
		dash_action = "p1_dash"
		shoot_action = "p1_shoot"
	else:
		left_action = "p2_left"
		right_action = "p2_right"
		jump_action = "p2_jump"
		dash_action = "p2_dash"
		shoot_action = "p1_shoot"

func _physics_process(delta: float) -> void:
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	if is_dashing:
		dash_timer -= delta
		velocity.y = 0
		velocity.x = dash_speed * direccion_mirada
			
		if dash_timer <= 0:
			is_dashing = false
			
	elif is_charging:
		velocity.x = 0
		
	else:
		var dir := Input.get_axis(left_action, right_action)
		velocity.x = dir * speed

		if dir != 0:
			direccion_mirada = sign(dir)
			
			if direccion_mirada == 1:
				animacion.flip_h = false
				if punto_disparo:
					punto_disparo.position.x = pos_inicial_marcador
					
			elif direccion_mirada == -1:
				animacion.flip_h = true
				if punto_disparo:
					punto_disparo.position.x = -pos_inicial_marcador

		if Input.is_action_just_pressed(jump_action) and is_on_floor():
			velocity.y = jump_force
			if salto_audio:
				salto_audio.play()

		cooldown_timer -= delta
		if Input.is_action_just_pressed(dash_action) and cooldown_timer <= 0:
			comenzar_dash()
			
		if Input.is_action_just_pressed(shoot_action) and puede_disparar and not is_on_floor():
			iniciar_ataque()

	move_and_slide()
	actualizar_animacion()

func actualizar_animacion() -> void:
	if is_charging:
		return
	if is_dashing:
		animacion.play("dash")
		return
	if not is_on_floor():
		animacion.play("jump")
		return
	if velocity.x != 0:
		animacion.play("move")
		return

	animacion.play("idle")

func iniciar_ataque() -> void:
	puede_disparar = false
	is_charging = true
	animacion.play("carga")
	
	if animacion.is_playing():
		await animacion.animation_finished
	
	disparar()
	is_charging = false
	
	await get_tree().create_timer(tiempo_cooldown_disparo).timeout
	puede_disparar = true

func disparar() -> void:
	if bala_escena == null:
		return
		
	var nueva_bala = bala_escena.instantiate()
	if "direccion" in nueva_bala:
		nueva_bala.direccion = direccion_mirada 
		
	if punto_disparo:
		nueva_bala.global_position = punto_disparo.global_position
	else:
		nueva_bala.global_position = global_position
	
	get_tree().current_scene.add_child(nueva_bala)

func comenzar_dash() -> void:
	is_dashing = true
	dash_timer = dash_time
	cooldown_timer = dash_cooldown

func recibir_daño(cantidad: int) -> void:
	if invencible:
		return

	vida_actual -= cantidad
	
	var ui = get_node_or_null("../Ui")
	if ui and ui.has_method("perder_vida"):
		ui.perder_vida()
		
	if vida_actual <= 0:
		morir()
	else:
		activar_parpadeo_rojo()

func activar_parpadeo_rojo() -> void:
	invencible = true
	var tween = create_tween()
	tween.set_loops(5) 
	tween.tween_property(animacion, "modulate", Color(1, 0.2, 0.2), 0.15)
	tween.tween_property(animacion, "modulate", Color(1, 1, 1), 0.15)
	await tween.finished
	animacion.modulate = Color(1, 1, 1)
	invencible = false

func morir() -> void:
	queue_free()

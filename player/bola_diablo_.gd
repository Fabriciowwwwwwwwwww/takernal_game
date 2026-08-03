extends CharacterBody2D

@export var velocidad := 300.0

var direccion := Vector2.ZERO
var rebotes := 0
var limite_rebotes := 0

var puede_rebotar := true


func _ready():
	limite_rebotes = [6, 7, 10].pick_random()


func iniciar_movimiento(dir):
	direccion = dir.normalized()
	velocity = direccion * velocidad


func _physics_process(delta):

	move_and_slide()


	if get_slide_collision_count() > 0 and puede_rebotar:

		var choque = get_slide_collision(0)

		var normal = choque.get_normal()

		direccion = direccion.bounce(normal)

		velocity = direccion * velocidad

		contar_rebote()

		# evita múltiples rebotes instantáneos
		puede_rebotar = false

		await get_tree().create_timer(0.1).timeout

		puede_rebotar = true



func contar_rebote():

	rebotes += 1

	print("Rebote: ", rebotes, "/", limite_rebotes)

	if rebotes >= limite_rebotes:
		queue_free()

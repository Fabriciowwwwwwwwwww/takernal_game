extends Area2D


@export var velocidad := 350.0
@export var tiempo_vida := 10.0


var direccion := Vector2.ZERO



@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D



func disparar(dir:Vector2):

	direccion = dir.normalized()

	

	sprite.play("idle")


	await get_tree().create_timer(tiempo_vida).timeout

	queue_free()



func _physics_process(delta):

	position += direccion * velocidad * delta

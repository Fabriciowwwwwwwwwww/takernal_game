extends Area2D

@export var velocidad := 350.0
@export var tiempo_vida := 10.0
@export var daño := 1

var direccion := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():

	body_entered.connect(_on_body_entered)

	sprite.play("idle")


func disparar(dir: Vector2):

	direccion = dir.normalized()

	await get_tree().create_timer(tiempo_vida).timeout

	queue_free()


func _physics_process(delta):

	position += direccion * velocidad * delta



func _on_body_entered(body: Node2D):

	if body.is_in_group("player"):

		print("CAFE GOLPEO A:", body.name)

		if body.has_method("perder_vida"):
			body.perder_vida()

		queue_free()

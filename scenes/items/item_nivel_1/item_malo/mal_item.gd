extends RigidBody2D

@export var tiempo_vida: float = 2.0

func _ready():
	await get_tree().create_timer(tiempo_vida).timeout
	queue_free()

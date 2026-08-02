extends RigidBody2D

@export var tiempo_vida: float = 5.0

func _ready():
	await get_tree().create_timer(tiempo_vida).timeout
	queue_free()

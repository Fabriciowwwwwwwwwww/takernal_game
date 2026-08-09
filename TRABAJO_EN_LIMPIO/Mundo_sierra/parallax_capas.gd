
extends ParallaxLayer

@export var velocidad: float = 20.0

func _process(delta):
	motion_offset.x -= velocidad * delta

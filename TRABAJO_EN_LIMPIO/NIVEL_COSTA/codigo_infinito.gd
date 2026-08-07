extends ParallaxBackground


@export var velocidad_scroll: float = 150.0

func _process(delta):

	scroll_offset.x -= velocidad_scroll * delta

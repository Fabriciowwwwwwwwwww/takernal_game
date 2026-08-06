extends ParallaxBackground


@export var velocidad_scroll: float = 150.0

func _process(delta):
	# Restamos a la posición X para que el fondo se mueva hacia la izquierda
	# Si quieres que se mueva a la derecha, usa += en lugar de -=
	scroll_offset.x -= velocidad_scroll * delta

extends Camera2D

@export var distancia_maxima := 120.0
@export var suavizado := 8.0
@export var zona_muerta := 150.0 # píxeles desde el centro

func _process(delta):

	var centro = get_viewport_rect().size * 0.5
	var mouse = get_viewport().get_mouse_position()

	var direccion = mouse - centro
	var distancia = direccion.length()

	var objetivo := Vector2.ZERO

	if distancia > zona_muerta:
		var t = (distancia - zona_muerta) / (centro.length() - zona_muerta)
		t = clamp(t, 0.0, 1.0)

		objetivo = direccion.normalized() * distancia_maxima * t

	position = position.lerp(objetivo, suavizado * delta)

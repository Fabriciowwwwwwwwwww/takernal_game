extends Area2D

@export var velocidad_chifle = 300
var direccion = -1

func _ready() -> void:
	await get_tree().create_timer(30.0).timeout
	if is_inside_tree():
		queue_free()

func _process(delta: float) -> void:
	position.x += velocidad_chifle * direccion * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("recibir_daño"):
		body.recibir_daño(1)
		queue_free() 

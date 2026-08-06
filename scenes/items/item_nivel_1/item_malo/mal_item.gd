extends RigidBody2D

var desapareciendo := false

@onready var animacion: AnimatedSprite2D = $Sprite2D

func _ready() -> void:
	# Layer 4
	collision_layer = 1 << 3

	# Detectar Layer 1 (jugador) y Layer 2 (plataforma)
	collision_mask = (1 << 0) | (1 << 1)

func _on_body_entered(body: Node) -> void:
	if desapareciendo:
		return

	if body.is_in_group("player"):
		desapareciendo = true
		body.perder_vida()
		animacion_desaparicion()

	elif body.is_in_group("plataforma"):
		desapareciendo = true
		animacion_desaparicion()

func animacion_desaparicion() -> void:

	# esperar a que termine la consulta de física
	set_deferred("freeze", true)
	set_deferred("linear_velocity", Vector2.ZERO)

	animacion.play("romper")


	await animacion.animation_finished


	queue_free()

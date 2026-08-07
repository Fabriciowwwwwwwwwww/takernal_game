extends RigidBody2D


var desapareciendo := false


@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D


@onready var sonidos := [
	$roto1,
	$roto2,
	$roto3
]

func _ready():


	contact_monitor = true
	max_contacts_reported = 10
	# Evita que atraviese al jugador cuando cae rápido
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE



func _on_body_entered(body: Node) -> void:

	if desapareciendo:
		return


	print("Objeto golpeó a: ", body.name)


	# Daño al jugador
	if body.is_in_group("player"):

		print("DAÑO AL JUGADOR")

		desapareciendo = true

		if body.has_method("perder_vida"):
			body.perder_vida()

		call_deferred("animacion_desaparicion")

		return



	# Romper al tocar plataforma
	if body.is_in_group("plataforma"):

		print("Golpeó plataforma")

		desapareciendo = true

		call_deferred("animacion_desaparicion")



func animacion_desaparicion() -> void:


	

	linear_velocity = Vector2.ZERO

	angular_velocity = 0



	# sonido aleatorio

	if sonidos.size() > 0:

		var sonido = sonidos.pick_random()

		sonido.play()



	# animación

	if animacion.sprite_frames.has_animation("explosion"):

		animacion.play("explosion")


	elif animacion.sprite_frames.has_animation("romper"):

		animacion.play("romper")


	else:

		queue_free()

		return



	await animacion.animation_finished


	queue_free()

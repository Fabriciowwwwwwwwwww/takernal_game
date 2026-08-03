extends RigidBody2D

var sobre_plataforma := false
@export var nombre := "pan"

func _on_body_entered(body):

	if body.is_in_group("plataforma") and !sobre_plataforma:
		sobre_plataforma = true
		await get_tree().create_timer(2.0).timeout
		queue_free()

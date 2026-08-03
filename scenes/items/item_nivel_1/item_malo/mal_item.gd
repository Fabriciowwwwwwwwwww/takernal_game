extends RigidBody2D

var desapareciendo := false

func _on_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		body.perder_vida()
		queue_free()
		
	if desapareciendo:
		return
		desapareciendo = true
		animacion_desaparicion()

	elif body.is_in_group("plataforma"):
		desapareciendo = true
		animacion_desaparicion()


func animacion_desaparicion():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()

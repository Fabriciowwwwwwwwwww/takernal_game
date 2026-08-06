extends RigidBody2D

var desapareciendo := false
var puede_chocar := false


@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _audios := [$roto1, $roto2, $roto3]

func _ready() -> void:
	_sprite.play("lanzamiento")
	await _sprite.animation_finished
	puede_chocar = true

func _on_body_entered(body):
	if not puede_chocar:
		return
	if desapareciendo:
		return

	_audios.pick_random().play()

	if body.is_in_group("player"):
		body.perder_vida()
		desapareciendo = true
		body.perder_vida()
		animacion_desaparicion()
	elif body.is_in_group("plataforma"):
		desapareciendo = true
		animacion_desaparicion()


func animacion_desaparicion():

	_sprite.play("explosion")
	await _sprite.animation_finished
	queue_free()

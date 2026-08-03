extends Area2D

@export var speed := 900.0
@export var damage := 1

var direction := Vector2.RIGHT


func iniciar(nueva_direccion: Vector2):

	direction = nueva_direccion.normalized()

	rotation = direction.angle()



func _physics_process(delta):

	global_position += direction * speed * delta



func _on_visible_on_screen_notifier_2d_screen_exited():

	queue_free()

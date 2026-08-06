@tool
extends Area2D

@export var speed := 900.0
@export var damage := 1

@export var sprite_frames: SpriteFrames:
	set(value):
		sprite_frames = value
		if is_node_ready():
			$AnimatedSprite2D.sprite_frames = value
			if value and value.has_animation("idle"):
				$AnimatedSprite2D.play("idle")

var direction := Vector2.RIGHT

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():

	if sprite_frames:
		sprite.sprite_frames = sprite_frames

	if sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


func iniciar(nueva_direccion: Vector2):

	direction = nueva_direccion.normalized()
	rotation = direction.angle()


func _physics_process(delta):

	global_position += direction * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited():

	queue_free()

@tool
extends Node2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


@export var character_frames: Dictionary[String, SpriteFrames] = {}


@export var current_character: String = "":
	set(value):
		current_character = value
		change_character()


@export var talking: bool = false:
	set(value):
		talking = value
		update_animation()



func _ready():
	change_character()



func change_character():

	if not is_instance_valid(animated_sprite):
		return

	var name = current_character.strip_edges()

	if name.is_empty():
		return

	if not character_frames.has(name):
		print("No existe personaje: [", name, "]")
		print("Personajes disponibles: ", character_frames.keys())
		return

	animated_sprite.sprite_frames = character_frames[name]

	update_animation()

func update_animation():

	if not is_instance_valid(animated_sprite):
		return


	if talking:

		if animated_sprite.sprite_frames.has_animation("talk"):
			animated_sprite.play("talk")

	else:

		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")

extends CanvasLayer

@onready var animation: AnimationPlayer = $transitionAnimation
var last_scene_name: String
var scene_dir_path := "res://scenes/"

func change_scene(from, to_scene_name: String) -> void:

	last_scene_name = from.name

	animation.play("transition_out")
	await animation.animation_finished
	var full_path = scene_dir_path + to_scene_name + ".tscn"

	get_tree().call_deferred("change_scene_to_file", full_path)

	# Esperar que cargue la nueva escena
	await get_tree().process_frame
	await get_tree().process_frame


	# Animación de entrada
	animation.play("transition_in")
	await animation.animation_finished

extends CanvasLayer

@onready var animation: AnimationPlayer = $transitionAnimation


var last_scene_name:String


func change_scene(from, to_scene_path:String) -> void:


	print("===== CAMBIO DE ESCENA =====")

	last_scene_name = from.name


	print("Recibido:")
	print(to_scene_path)



	animation.play("transition_out")

	await animation.animation_finished



	if ResourceLoader.exists(to_scene_path):

		print("✅ ESCENA EXISTE")


	else:

		print("❌ NO EXISTE")


	get_tree().call_deferred(
		"change_scene_to_file",
		to_scene_path
	)


	await get_tree().process_frame
	await get_tree().process_frame


	animation.play("transition_in")

	await animation.animation_finished

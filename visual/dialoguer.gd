extends Node2D

@export var dialogue: DialogueResource

@export_file("*.tscn") var next_scene: String


func _ready():

	print("===== DIALOGO INICIADO =====")

	print("Escena actual:",
		get_tree().current_scene.name
	)

	print("Escena siguiente:",
		next_scene
	)


	DialogueManager.dialogue_ended.connect(
		_on_dialogue_finished
	)


	DialogueManager.show_dialogue_balloon(dialogue)



func _on_dialogue_finished(_resource: DialogueResource):

	print("===== DIALOGO TERMINADO =====")

	print("Voy a cargar:",
		next_scene
	)


	SceneManager.change_scene(
		self,
		next_scene
	)

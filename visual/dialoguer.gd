extends Node2D

@export var dialogue: DialogueResource
@onready var sprite:Sprite2D = $CanvasLayer2/Sprite2D
@export_file("*.tscn") var next_scene: String
@onready var musica: AudioStreamPlayer2D = $sonido_mundo


func _ready():
	musica.play()
	BackgroundManager.registrar_fondo(sprite)
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

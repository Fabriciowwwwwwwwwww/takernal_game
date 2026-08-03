extends Node2D

@export var dialogue: DialogueResource
@export_file("*.tscn") var next_scene: String = "res://mundo.tscn"


func _ready():

	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

	DialogueManager.show_dialogue_balloon(dialogue)


func _on_dialogue_finished(_resource: DialogueResource):

	SceneManager.change_scene(self, "mundo")

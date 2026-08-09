extends Node2D

@export_file("*.tscn") var next_scene: String
@onready var musica: AudioStreamPlayer2D = $sonido_mundo

func _ready() -> void:
	musica.play()
	PauseOverlay.puede_pausar = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and next_scene != "":
		SceneManager.change_scene(self, next_scene)

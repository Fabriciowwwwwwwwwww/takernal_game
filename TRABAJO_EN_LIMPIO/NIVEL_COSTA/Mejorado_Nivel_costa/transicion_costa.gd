extends Node2D

@export_file("*.tscn") var escena_jefe: String
var tiempo_transicion: float = 11.0

@onready var voz_causa: AudioStreamPlayer = $voz_causa


func _ready() -> void:
	get_tree().paused = false
	
	await get_tree().create_timer(2.0).timeout
	voz_causa.play()


func _process(delta: float) -> void:
	tiempo_transicion -= delta
	
	if tiempo_transicion <= 0.0:
		iniciar_batalla_jefe()


func iniciar_batalla_jefe() -> void:
	set_process(false)
	SceneManager.change_scene(self, escena_jefe)

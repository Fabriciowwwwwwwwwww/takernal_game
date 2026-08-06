extends CanvasLayer


@export_file("*.tscn") var retry_scene: String
@export_file("*.tscn") var menu_scene: String


@onready var retry_button: Button = $PauseContainer/RightPanel/VBoxContainer/RetryButton
@onready var exit_button: Button = $PauseContainer/RightPanel/VBoxContainer/ExitButton


func _ready() -> void:

	process_mode = Node.PROCESS_MODE_ALWAYS
	
	visible = true
	
	get_tree().paused = true


	if retry_button:
		retry_button.grab_focus()



func mostrar_game_over():

	visible = true
	
	get_tree().paused = true



func _on_retry_button_pressed() -> void:

	print("REINTENTAR NIVEL")

	get_tree().paused = false

	SceneManager.change_scene(
		self,
		retry_scene
	)



func _on_title_screen_button_pressed() -> void:

	print("VOLVER AL MENU")

	get_tree().paused = false

	SceneManager.change_scene(
		self,
		menu_scene
	)

extends CanvasLayer


@onready var pause_menu: Control = %PauseMenu
@onready var resume_button: Button = %ResumeButton


# Por defecto el juego puede pausarse
var puede_pausar: bool = true



func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS



func _unhandled_input(event: InputEvent) -> void:


	if not puede_pausar:
		return

	if event.is_action_pressed(&"pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:

	var nuevo_estado := not get_tree().paused


	get_tree().paused = nuevo_estado
	visible = nuevo_estado



	if nuevo_estado:
		pause_menu.show()

		if resume_button:
			resume_button.grab_focus()


	else:
		pause_menu.hide()


func activar_pausa(valor: bool) -> void:
	puede_pausar = valor






func _on_options_back() -> void:

	pause_menu.show()

	if resume_button:
		resume_button.grab_focus()



func _on_resume_button_pressed() -> void:
	toggle_pause()



func _on_title_screen_button_pressed() -> void:

	# Quitar pausa
	get_tree().paused = false

	# Ocultar menú de pausa
	visible = false

	# Cambiar escena
	SceneManager.change_scene(self, "Menu")

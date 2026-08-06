extends CanvasLayer


@onready var pause_menu: Control = $PauseContainer/RightPanel
@onready var resume_button: Button = $PauseContainer/RightPanel/VBoxContainer/ResumeButton
@export_file("*.tscn") var menu_scene: String
# Nodo donde están los adornos animados
@onready var adorno: Node2D = $Adorno


# Por defecto el juego puede pausarse
var puede_pausar: bool = true



func _ready() -> void:

	visible = false
	
	process_mode = Node.PROCESS_MODE_ALWAYS




func _unhandled_input(event: InputEvent) -> void:


	if not puede_pausar:
		return


	if event.is_action_pressed("pause"):

		toggle_pause()

		get_viewport().set_input_as_handled()




func toggle_pause() -> void:


	var nuevo_estado := not get_tree().paused


	get_tree().paused = nuevo_estado


	visible = nuevo_estado



	if nuevo_estado:

		pause_menu.show()

		activar_adornos()


		if resume_button:
			resume_button.grab_focus()


	else:

		pause_menu.hide()




# ==============================
# ACTIVAR ANIMACIONES DEL ADORNO
# ==============================

func activar_adornos():

	if not adorno:
		return


	var sprites = adorno.find_children("*", "AnimatedSprite2D", true)


	for sprite in sprites:

		sprite.play("idle")





func activar_pausa(valor: bool) -> void:

	puede_pausar = valor





func _on_resume_button_pressed() -> void:

	toggle_pause()





func _on_retry_button_pressed() -> void:


	get_tree().paused = false

	visible = false

	get_tree().reload_current_scene()





func _on_title_screen_button_pressed() -> void:

	print("VOLVER AL MENU")

	get_tree().paused = false

	SceneManager.change_scene(
		self,
		menu_scene
	)

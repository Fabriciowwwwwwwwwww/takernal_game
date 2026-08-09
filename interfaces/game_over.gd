extends CanvasLayer


var escena_anterior: String = ""
@export_file("*.tscn") var menu_scene: String

@onready var sprite_1: AnimatedSprite2D = $Background
@onready var sprite_2: AnimatedSprite2D = $cuy

@onready var retry_button: Button = $PauseContainer/RightPanel/VBoxContainer/RetryButton
@onready var exit_button: Button = $PauseContainer/RightPanel/VBoxContainer/ExitButton


func _ready() -> void:
	sprite_1.play("idle")
	sprite_2.play("idle")

	process_mode = Node.PROCESS_MODE_ALWAYS
	
	visible = true
	
	get_tree().paused = true


	if retry_button:
		retry_button.grab_focus()


func configurar_escena_anterior(ruta: String) -> void:
	escena_anterior = ruta
func mostrar_game_over():

	visible = true
	
	get_tree().paused = true



func _on_retry_button_pressed() -> void:

	print("REINTENTAR NIVEL")

	get_tree().paused = false

	if escena_anterior == "":
		print("ERROR: No se encontró la escena anterior")
		return

	SceneManager.change_scene(
		self,
		escena_anterior
	)



func _on_title_screen_button_pressed() -> void:

	print("VOLVER AL MENU")

	get_tree().paused = false

	SceneManager.change_scene(
		self,
		menu_scene
	)

extends Control

var tipo_boton = null


func _ready() -> void:

	$"Sombras_transición".show()
	$"Sombras_transición/AnimationPlayer".play("Sombra_off")

	#ANIMACIÓN CON SHADERS SOLO AFECTA A LOS HIJOS DEL NODO CONTROL (SPRITE2D_TITULO, BOTONES):

	#$Start.grab_focus()

func _on_start_pressed() -> void:
	print("Start presionado")
	tipo_boton = "start"
	$"Sombras_transición".show()
	$"Sombras_transición/Sombra_time".start()
	$"Sombras_transición/AnimationPlayer".play("Sombra_on")

func _on_tutorial_pressed() -> void:
	tipo_boton = "tutorial"
	

func _on_options_pressed() -> void:
	tipo_boton = "options"
	$"Sombras_transición".show()
	$"Sombras_transición/Sombra_time".start()
	$"Sombras_transición/AnimationPlayer".play("Sombra_on")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_sombra_time_timeout() -> void:
	if tipo_boton == 'start' :
		get_tree().change_scene_to_file("res://visual/visual.tscn") 
	
	elif tipo_boton == 'options' :
		get_tree().change_scene_to_file("res://Scenes/Interfaz/Menú/Opciones_Menu.tscn") 
		


		
		
		

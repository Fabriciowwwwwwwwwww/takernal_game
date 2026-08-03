extends Control

var tipo_boton := ""

func _ready() -> void:
	PauseOverlay.puede_pausar = false
	$"Sombras_transición".show()
	$"Sombras_transición/AnimationPlayer".play("Sombra_off")

	$Control/Single_Player.grab_focus()


func iniciar_transicion() -> void:
	$"Sombras_transición".show()
	$"Sombras_transición/Sombra_time".start()
	$"Sombras_transición/AnimationPlayer".play("Sombra_on")


func _on_single_player_pressed() -> void:
	GameManager.modo_juego = GameManager.ModoJuego.SINGLE
	tipo_boton = "start"
	iniciar_transicion()


func _on_multi_player_pressed() -> void:
	GameManager.modo_juego = GameManager.ModoJuego.COOP
	tipo_boton = "start"
	iniciar_transicion()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_sombra_time_timeout() -> void:
	if tipo_boton == "start":
		get_tree().change_scene_to_file("res://visual/visual.tscn")

extends Control

var tipo_boton := ""
@onready var musica: AudioStreamPlayer2D = $sonido_mundo
@onready var camion: AnimatedSprite2D =$carro
@onready var cuy_1: AnimatedSprite2D =$cuy1
@onready var cuy_2: AnimatedSprite2D =$cuy2
func _ready() -> void:
	musica.play()
	camion.play("idle")
	cuy_1.play("idle")
	cuy_2.play("idle")
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

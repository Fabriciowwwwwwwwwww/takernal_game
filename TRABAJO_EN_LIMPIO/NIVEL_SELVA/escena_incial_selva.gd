extends Node2D

@export var chifle_1_escena: PackedScene
@export var chifle_2_escena: PackedScene 

@export var tiempo_espera_chifle_1: float = 3.5 
@export var tiempo_espera_chifle_2: float = 5.5 

@onready var mi_marcador: Marker2D = $Marker2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	audio_stream_player_2d.play()
	randomize()
	secuencia_de_lanzamiento()

func secuencia_de_lanzamiento() -> void:
	await get_tree().create_timer(3.0).timeout

	while is_inside_tree():
		var tipo_disparo = randi() % 2
		
		if tipo_disparo == 0:
			lanzar_objeto(chifle_1_escena)
			await get_tree().create_timer(tiempo_espera_chifle_1).timeout
		else:
			lanzar_objeto(chifle_2_escena)
			await get_tree().create_timer(tiempo_espera_chifle_2).timeout

func lanzar_objeto(escena_a_instanciar: PackedScene) -> void:
	if escena_a_instanciar == null:
		return
		
	var nuevo_objeto = escena_a_instanciar.instantiate()
	nuevo_objeto.global_position = mi_marcador.global_position
	get_tree().current_scene.add_child(nuevo_objeto)

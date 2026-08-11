extends CanvasLayer

@export_file("*.tscn") var escena_game_over: String

@onready var corazones: Array = [
	$Hearts/heart1,
	$Hearts/heart2,
	$Hearts/heart3,
	$Hearts/heart4,
	$Hearts/heart5
]
@onready var barra_salsas: ProgressBar = $BarraProgreso

var vidas: int = 5

func _ready() -> void:
	actualizar_corazones()
	if barra_salsas != null:
		barra_salsas.max_value = 30.0
		barra_salsas.value = 0.0

func actualizar_tiempo(tiempo: float) -> void:
	if barra_salsas != null:
		barra_salsas.value = tiempo

func configurar_modo_juego(es_coop: bool, jugadores: Array[Node2D]) -> void:
	pass

func perder_vida() -> void:
	if vidas <= 0:
		return
		
	vidas -= 1
	actualizar_corazones()
	
	if vidas <= 0:
		mostrar_game_over()

func actualizar_corazones() -> void:
	for i in range(corazones.size()):
		if i < vidas:
			corazones[i].visible = true
		else:
			corazones[i].visible = false

func mostrar_game_over() -> void:
	get_tree().paused = true
	
		
	if escena_game_over != "":
		var game_over = load(escena_game_over).instantiate()
		get_tree().current_scene.add_child(game_over)

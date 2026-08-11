extends Node2D

@export_file("*.tscn") var escena_transicion: String
@export var jugador1: PackedScene
@export var jugador2: PackedScene

@onready var posicion_inicial: Marker2D = $Node/SpawnJugador1
@onready var musica: AudioStreamPlayer = $MusicaFondo
@onready var hud: CanvasLayer = $Ui

var tiempo_actual: float = 0.0
var tiempo_limite: float = 30.0

func _ready() -> void:
	get_tree().paused = false
	if musica:
		musica.play()

	var es_coop: bool = (GameManager.modo_juego == GameManager.ModoJuego.COOP)
	var centro: Vector2 = posicion_inicial.global_position
	var jugadores: Array[Node2D] = []

	var p1 = jugador1.instantiate()
	p1.jugador = "Jugador 1"
	add_child(p1)
	p1.global_position = centro + Vector2(-40, 0)
	jugadores.append(p1)

	if es_coop:
		var p2 = jugador2.instantiate()
		p2.jugador = "Jugador 2"
		add_child(p2)
		p2.global_position = centro + Vector2(40, 0)
		jugadores.append(p2)

	if hud != null and hud.has_method("configurar_modo_juego"):
		hud.configurar_modo_juego(es_coop, jugadores)

func _process(delta: float) -> void:
	tiempo_actual += delta
	
	if hud != null and hud.has_method("actualizar_tiempo"):
		hud.actualizar_tiempo(tiempo_actual)
	
	if tiempo_actual >= tiempo_limite:
		pasar_a_transicion()

func pasar_a_transicion() -> void:
	set_process(false)
	SceneManager.change_scene(self, escena_transicion)

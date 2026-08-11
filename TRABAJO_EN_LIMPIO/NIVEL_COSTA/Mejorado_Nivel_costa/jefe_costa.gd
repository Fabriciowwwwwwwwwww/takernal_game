extends Node2D
@export var jugador1: PackedScene
@export var jugador2: PackedScene
@onready var posicion_inicial: Marker2D = $Node/SpawnJugador1
@onready var hud: CanvasLayer = $Ui
@onready var musica: AudioStreamPlayer = $AudioStreamPlayer
@onready var anim: AnimationPlayer = $AnimationPlayer
var juego_terminado: bool = false
var es_coop: bool = false
var jugadores: Array[Node2D] = []

func _ready() -> void:
	get_tree().paused = false
	
	if musica != null:
		musica.play()
		
	es_coop = (GameManager.modo_juego == GameManager.ModoJuego.COOP)
	var centro: Vector2 = posicion_inicial.global_position
	var p1 = jugador1.instantiate()
	p1.jugador = "Jugador 1"
	add_child(p1)
	jugadores.append(p1)
	if es_coop:
		p1.global_position = centro + Vector2(-40, 0)
		var p2 = jugador2.instantiate()
		p2.jugador = "Jugador 2"
		add_child(p2)
		p2.global_position = centro + Vector2(40, 0)
		jugadores.append(p2)
	else:
		p1.global_position = centro
	if hud != null and hud.has_method("configurar_modo_juego"):
		hud.configurar_modo_juego(es_coop, jugadores)
	# (se quitó hud.actualizar_barra(100.0): el HUD ya controla su barra solo)
	iniciar_patron_ataque()

func _process(delta: float) -> void:
	if juego_terminado:
		return

func ganar_juego() -> void:
	juego_terminado = true
	
	var proyectiles = get_tree().get_nodes_in_group("proyectil")
	for p in proyectiles:
		if is_instance_valid(p):
			p.queue_free()

func iniciar_patron_ataque() -> void:
	while is_inside_tree() and not juego_terminado:
		anim.play("idle")
		await get_tree().create_timer(7.0).timeout 
		if juego_terminado: return
		
		anim.play("posicion_ataque")
		await anim.animation_finished 
		if juego_terminado: return
		
		anim.play("ataque_escalera")
		await get_tree().create_timer(20.0).timeout 
		if juego_terminado: return
		
		anim.play("subida")
		await anim.animation_finished

func _on_patas_body_entered(body: Node2D) -> void:
	if body.has_method("perder_vida"):
		body.perder_vida()
func _on_piernas_body_entered(body: Node2D) -> void:
	if body.has_method("perder_vida"):
		body.perder_vida()
func _on_cuello_body_entered(body: Node2D) -> void:
	if body.has_method("perder_vida"):
		body.perder_vida()
func _on_boca_body_entered(body: Node2D) -> void:
	if body.has_method("perder_vida"):
		body.perder_vida()
func _on_cabeza_body_entered(body: Node2D) -> void:
	if body.has_method("perder_vida"):
		body.perder_vida()


func _on_eliminador_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	if hud != null and hud.has_method("matar_instantaneo"):
		hud.matar_instantaneo()
	
	if is_instance_valid(body):
		body.queue_free()

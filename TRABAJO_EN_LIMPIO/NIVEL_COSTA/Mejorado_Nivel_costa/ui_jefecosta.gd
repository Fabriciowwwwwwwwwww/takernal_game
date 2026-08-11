extends CanvasLayer

@export_file("*.tscn") var escena_game_over: String
@export_file("*.tscn") var siguiente_escena: String
@export var tiempo_antes_siguiente_nivel: float = 4.0

@export var duracion_nivel: float = 90.0  # 1 minuto 30 segundos

@onready var corazones: Array = [
	$Hearts/heart1,
	$Hearts/heart2,
	$Hearts/heart3,
	$Hearts/heart4,
	$Hearts/heart5
]
@onready var barra_progreso: ProgressBar = $BarraProgreso

@onready var sonido_victoria: AudioStreamPlayer = $"../sonido_victoria"
@onready var victoria: CanvasLayer = $"../CanvasLayer_victoria"
@onready var personaje_victoria: AnimatedSprite2D = $"../CanvasLayer_victoria/AnimatedSprite2D"

var vidas: int = 5
var juego_ganado: bool = false

var tiempo_transcurrido: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	actualizar_corazones()
	
	if barra_progreso != null:
		barra_progreso.max_value = 100.0
		barra_progreso.value = 0.0
		
	if victoria != null:
		victoria.visible = false
		victoria.process_mode = Node.PROCESS_MODE_ALWAYS
		
	if personaje_victoria != null:
		personaje_victoria.visible = false

func _process(delta: float) -> void:
	if juego_ganado or get_tree().paused:
		return

	tiempo_transcurrido += delta

	var porcentaje: float = (tiempo_transcurrido / duracion_nivel) * 100.0
	porcentaje = min(porcentaje, 100.0)

	if barra_progreso != null:
		barra_progreso.value = porcentaje

	if porcentaje >= 100.0:
		ganar_juego()

func configurar_modo_juego(es_coop: bool, jugadores: Array[Node2D]) -> void:
	pass

func perder_vida() -> void:
	if vidas <= 0 or juego_ganado:
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

# =========================================================
# GANAR JUEGO
# =========================================================
func ganar_juego() -> void:
	if juego_ganado:
		return
		
	juego_ganado = true
	get_tree().paused = true
	
	var proyectiles = get_tree().get_nodes_in_group("proyectil")
	for p in proyectiles:
		if is_instance_valid(p):
			p.queue_free()
			
	if sonido_victoria != null:
		sonido_victoria.process_mode = Node.PROCESS_MODE_ALWAYS
		sonido_victoria.play()
		
	var jugadores = get_tree().get_nodes_in_group("jugador")
	for jugador in jugadores:
		if is_instance_valid(jugador):
			if jugador.has_method("hacer_invulnerable"):
				jugador.hacer_invulnerable(true)
			if jugador is CharacterBody2D:
				jugador.velocity = Vector2.ZERO
				
	if victoria != null:
		victoria.visible = true
		
	if personaje_victoria != null:
		personaje_victoria.visible = true
		personaje_victoria.play("idle")
		personaje_victoria.position = Vector2(-150.0, 300.0)
		
		var tween := create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(personaje_victoria, "position", Vector2(640.0, 300.0), 2.0)
		
		await tween.finished
		personaje_victoria.play("idle")
	
	print("[VICTORIA] Esperando ", tiempo_antes_siguiente_nivel, " segundos...")
	
	var timer := get_tree().create_timer(tiempo_antes_siguiente_nivel, true)
	await timer.timeout
	
	cambiar_al_siguiente_nivel()


# =========================================================
# MUERTE INSTANTÁNEA (ej: caída a un pozo)
# =========================================================
func matar_instantaneo() -> void:
	if juego_ganado or vidas <= 0:
		return
	
	vidas = 0
	actualizar_corazones()
	mostrar_game_over()
# =========================================================
# CAMBIAR DE ESCENA
# =========================================================
func cambiar_al_siguiente_nivel() -> void:
	print("======================================")
	print("====== CAMBIANDO AL SIGUIENTE ========")
	print("======================================")

	get_tree().paused = false

	if siguiente_escena.is_empty():
		print("[VICTORIA] ERROR: No se asignó siguiente_escena")
		return

	print("[VICTORIA] Cargando: ", siguiente_escena)
	get_tree().change_scene_to_file(siguiente_escena)
	
	

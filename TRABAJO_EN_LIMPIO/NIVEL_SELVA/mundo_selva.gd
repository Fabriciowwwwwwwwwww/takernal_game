extends Node

@export_category("Escenas del Nivel")
@export var escena_round_1: PackedScene
@export var escena_interludio: PackedScene
@export var escena_round_2: PackedScene

@export_category("Jugadores")
@export var jugador_1: Node2D
@export var jugador_2: Node2D

@export_category("Tiempos")
@export var tiempo_round_1: float = 20.0

var round_actual: Node = null
var interludio_actual: Node = null

func _ready():
	iniciar_flujo_juego()

func iniciar_flujo_juego():
	# --- INICIO DEL ROUND 1 ---
	round_actual = escena_round_1.instantiate()
	add_child(round_actual)
	
	if jugador_1 and round_actual.has_node("PosicionP1"):
		jugador_1.global_position = round_actual.get_node("PosicionP1").global_position
		
	if jugador_2 and round_actual.has_node("PosicionP2"):
		jugador_2.global_position = round_actual.get_node("PosicionP2").global_position
	
	await get_tree().create_timer(tiempo_round_1).timeout
	
	# --- INICIA EL INTERLUDIO ---
	interludio_actual = escena_interludio.instantiate()
	add_child(interludio_actual)
	
	await interludio_actual.pantalla_cerrada
	
	# --- LIMPIEZA Y OCULTAR JUGADORES ---
	if round_actual:
		round_actual.queue_free()
		await get_tree().process_frame 
		
	if jugador_1:
		jugador_1.visible = false
		jugador_1.process_mode = Node.PROCESS_MODE_DISABLED
	if jugador_2:
		jugador_2.visible = false
		jugador_2.process_mode = Node.PROCESS_MODE_DISABLED
	
	# La pausa de 6.5 segundos
	await get_tree().create_timer(6.5).timeout
	
	# --- CARGA DEL ROUND 2 ---
	round_actual = escena_round_2.instantiate()
	add_child(round_actual)
	
	# Pausamos el round 2 hasta que el interludio termine de irse
	round_actual.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Ubicamos a los jugadores en los nuevos Markers y los hacemos visibles
	if jugador_1 and round_actual.has_node("PosicionP1"):
		jugador_1.global_position = round_actual.get_node("PosicionP1").global_position
		jugador_1.visible = true
		
	if jugador_2 and round_actual.has_node("PosicionP2"):
		jugador_2.global_position = round_actual.get_node("PosicionP2").global_position
		jugador_2.visible = true
	
	# --- FIN DEL INTERLUDIO ---
	await interludio_actual.terminado
	interludio_actual.queue_free()
	
	# --- REACTIVAR MOVIMIENTOS Y ESCENA ---
	if round_actual:
		round_actual.process_mode = Node.PROCESS_MODE_INHERIT
	if jugador_1:
		jugador_1.process_mode = Node.PROCESS_MODE_INHERIT
	if jugador_2:
		jugador_2.process_mode = Node.PROCESS_MODE_INHERIT

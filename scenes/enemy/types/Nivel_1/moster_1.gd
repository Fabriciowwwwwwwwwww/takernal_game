extends "res://scenes/enemy/monster_base.gd"

@export var pan_scene: PackedScene
@export var cebolla_scene: PackedScene
@export var camote_scene: PackedScene
@export var limon_scene: PackedScene
@export var sal_especial_scene: PackedScene
@export var chicharron_scene: PackedScene
@export var basura_scene: PackedScene
@export var ladrillo_scene: PackedScene

@export var intervalo_lanzamiento: float = 1.5
@export var intervalo_entre_disparos: float = 0.2
@export var probabilidad_doble_malo: float = 0.65
@export var limite_izquierdo: float = 160.0
@export var limite_derecho: float = 1158.0
@export var margen_frenado: float = 250.0
@export var velocidad_minima_factor: float = 0.1
@export var tiempo_preparacion: float = 1.0
@export var fuerza_parabola: float = 350.0
@export var fuerza_extremo_min: float = 500.0
@export var fuerza_extremo_max: float = 750.0

var _spawn_points: Array[Marker2D] = []
var _spawn_timer: float = 0.0
var _velocidad_normal: float
var _pool_buenos: Array = []
var _pool_malos: Array = []
var _marker_izq_extremo: Marker2D = null
var _marker_der_extremo: Marker2D = null

var _lanzando := false
var activo := true

@onready var _audio_lanzamiento: AudioStreamPlayer2D = $AudioStreamPlayer
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

enum Estado { PATRULLANDO, ATACANDO }
var _estado: Estado = Estado.PATRULLANDO

func _ready():
	_velocidad_normal = velocidad
	for child in get_children():
		if child is Marker2D:
			_spawn_points.append(child)
			
	_pool_buenos = [
		{ "escena": pan_scene,          "prob": 0.02 },
		{ "escena": cebolla_scene,      "prob": 0.08 },
		{ "escena": camote_scene,       "prob": 0.07 },
		{ "escena": limon_scene,        "prob": 0.06 },
		{ "escena": sal_especial_scene, "prob": 0.05 },
		{ "escena": chicharron_scene,   "prob": 0.05 },
	]
	
	_pool_malos = [
		{ "escena": basura_scene,       "prob": 0.42 },
		{ "escena": ladrillo_scene,     "prob": 0.29 },
	]
	
	for m in _spawn_points:
		if _marker_izq_extremo == null or m.global_position.x < _marker_izq_extremo.global_position.x:
			_marker_izq_extremo = m
		if _marker_der_extremo == null or m.global_position.x > _marker_der_extremo.global_position.x:
			_marker_der_extremo = m

func set_activo(valor: bool) -> void:
	activo = valor
	if not activo:
		velocidad = 0.0
		_lanzando = false
		if _sprite:
			_sprite.play("idle")
			_sprite.speed_scale = 1.0
	else:
		velocidad = _velocidad_normal
		_spawn_timer = 0.0
		_estado = Estado.PATRULLANDO

func _process(delta):
	if not activo:
		return
		
	if _estado != Estado.PATRULLANDO:
		return
		
	_ajustar_velocidad_por_borde()
	mover(delta)
	_actualizar_animacion_patrulla()
	
	if position.x <= limite_izquierdo:
		direccion = 1
		_llegar_a_extremo()
	elif position.x >= limite_derecho:
		direccion = -1
		_llegar_a_extremo()
		
	_spawn_timer += delta
	if _spawn_timer >= intervalo_lanzamiento:
		_spawn_timer = 0.0
		spawnear_tanda()

func _actualizar_animacion_patrulla():
	if _sprite == null or _lanzando:
		return
	_sprite.flip_h = direccion < 0
	if _sprite.animation != "run":
		_sprite.play("run")
	_sprite.speed_scale = clamp(velocidad / _velocidad_normal, 0.15, 1.0)

func _ajustar_velocidad_por_borde():
	var distancia_izq = position.x - limite_izquierdo
	var distancia_der = limite_derecho - position.x
	var distancia_al_borde = min(distancia_izq, distancia_der)
	
	if distancia_al_borde < margen_frenado:
		var t = distancia_al_borde / margen_frenado
		velocidad = lerp(_velocidad_normal * velocidad_minima_factor, _velocidad_normal, t)
	else:
		velocidad = _velocidad_normal

func _reproducir_animacion_lanzar(nombre: String) -> void:
	if _sprite == null or _sprite.sprite_frames == null or not _sprite.sprite_frames.has_animation(nombre):
		return
	_lanzando = true
	_sprite.speed_scale = 1.0
	_sprite.play(nombre)
	
	var fotogramas = _sprite.sprite_frames.get_frame_count(nombre)
	var velocidad_anim = _sprite.sprite_frames.get_animation_speed(nombre)
	var duracion = float(fotogramas) / max(velocidad_anim, 0.01)
	
	await get_tree().create_timer(duracion).timeout
	if activo:
		_lanzando = false

func _elegir_item_random(pool: Array) -> PackedScene:
	var total_prob := 0.0
	for entrada in pool:
		total_prob += entrada["prob"]
	var r := randf() * total_prob
	var acumulado := 0.0
	for entrada in pool:
		acumulado += entrada["prob"]
		if r <= acumulado:
			return entrada["escena"]
	return pool[-1]["escena"]

func spawnear_tanda(nombre_animacion: String = "lanzar"):
	if not activo:
		return
	if _spawn_points.size() < 2:
		return
		
	if _audio_lanzamiento:
		_audio_lanzamiento.play()
		
	_reproducir_animacion_lanzar(nombre_animacion)
	
	var markers = _spawn_points.duplicate()
	markers.shuffle()
	var pool_1: Array
	var pool_2: Array
	
	if randf() < probabilidad_doble_malo:
		pool_1 = _pool_malos
		pool_2 = _pool_malos
	else:
		if randf() < 0.5:
			pool_1 = _pool_buenos
			pool_2 = _pool_malos
		else:
			pool_1 = _pool_malos
			pool_2 = _pool_buenos
			
	spawnear_item(markers[0], pool_1)
	
	await get_tree().create_timer(intervalo_entre_disparos).timeout
	
	if not activo:
		return
		
	spawnear_item(markers[1], pool_2)

func spawnear_item(punto: Marker2D, pool: Array):
	var escena: PackedScene = _elegir_item_random(pool)
	if escena == null:
		return
		
	var item = escena.instantiate()
	item.global_position = punto.global_position
	get_tree().current_scene.add_child(item)
	
	if item is RigidBody2D:
		var centro = (limite_izquierdo + limite_derecho) / 2.0
		var lado = 1.0 if punto.global_position.x < centro else -1.0
		var es_extremo = punto == _marker_izq_extremo or punto == _marker_der_extremo
		var magnitud: float
		if es_extremo:
			magnitud = randf_range(fuerza_extremo_min, fuerza_extremo_max)
		else:
			magnitud = randf_range(0.0, fuerza_parabola)
		item.linear_velocity = Vector2(lado * magnitud, 0)

func _llegar_a_extremo():
	if not activo:
		return
	if _estado != Estado.PATRULLANDO:
		return
		
	_spawn_timer = 0.0
	_estado = Estado.ATACANDO
	_secuencia_de_ataque()

func _secuencia_de_ataque() -> void:
	velocidad = 0.0
	if _sprite:
		_sprite.speed_scale = 1.0
		_sprite.play("idle")
		
	await get_tree().create_timer(tiempo_preparacion).timeout
	
	if not activo:
		return
		
	spawnear_tanda("lanzar")
	
	if activo:
		velocidad = _velocidad_normal
		_estado = Estado.PATRULLANDO
		_spawn_timer = 0.0


func entrar_modo_frenetico(aumento_velocidad: float = 1.5, nuevo_intervalo: float = 0.8):
	_velocidad_normal *= aumento_velocidad
	if activo:
		velocidad = _velocidad_normal
	intervalo_lanzamiento = nuevo_intervalo
	intervalo_entre_disparos = 0.1

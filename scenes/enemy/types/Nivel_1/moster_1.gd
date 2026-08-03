extends "res://scenes/enemy/monster_base.gd"
@export var pan_scene: PackedScene
@export var cebolla_scene: PackedScene
@export var camote_scene: PackedScene
@export var limon_scene: PackedScene
@export var sal_especial_scene: PackedScene
@export var chicharron_scene: PackedScene
@export var basura_scene: PackedScene
@export var ladrillo_scene: PackedScene
@export var intervalo_min: float = 1.2
@export var intervalo_max: float = 2.5
@export var limite_izquierdo: float = 160.0
@export var limite_derecho: float = 1158.0
@export var margen_frenado: float = 250.0
@export var velocidad_minima_factor: float = 0.1
@export var tiempo_preparacion_min: float = 0.6
@export var tiempo_preparacion_max: float = 1.4
@export var fuerza_parabola: float = 350.0
@export var fuerza_extremo_min: float = 500.0
@export var fuerza_extremo_max: float = 750.0
var _spawn_points: Array[Marker2D] = []
var _spawn_timer: float = 0.0
var _proximo_intervalo: float = 0.0
var _velocidad_normal: float
var _pool_buenos: Array = []
var _pool_malos: Array = []
var _marker_izq_extremo: Marker2D = null
var _marker_der_extremo: Marker2D = null
enum Estado { PATRULLANDO, ATACANDO }
var _estado: Estado = Estado.PATRULLANDO
func _ready():
	_velocidad_normal = velocidad
	for child in get_children():
		if child is Marker2D:
			_spawn_points.append(child)
	_pool_buenos = [
		{ "escena": pan_scene,          "prob": 0.08 },
		{ "escena": cebolla_scene,      "prob": 0.06 },
		{ "escena": camote_scene,       "prob": 0.05 },
		{ "escena": limon_scene,        "prob": 0.04 },
		{ "escena": sal_especial_scene, "prob": 0.03 },
		{ "escena": chicharron_scene,   "prob": 0.03 },
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
	_proximo_intervalo = randf_range(intervalo_min, intervalo_max)
func _process(delta):
	if _estado != Estado.PATRULLANDO:
		return
	_ajustar_velocidad_por_borde()
	mover(delta)
	if position.x <= limite_izquierdo:
		direccion = 1
		_llegar_a_extremo()
	elif position.x >= limite_derecho:
		direccion = -1
		_llegar_a_extremo()
	_spawn_timer += delta
	if _spawn_timer >= _proximo_intervalo:
		_spawn_timer = 0.0
		_proximo_intervalo = randf_range(intervalo_min, intervalo_max)
		spawnear_tanda()
func _ajustar_velocidad_por_borde():
	var distancia_izq = position.x - limite_izquierdo
	var distancia_der = limite_derecho - position.x
	var distancia_al_borde = min(distancia_izq, distancia_der)
	if distancia_al_borde < margen_frenado:
		var t = distancia_al_borde / margen_frenado
		velocidad = lerp(_velocidad_normal * velocidad_minima_factor, _velocidad_normal, t)
	else:
		velocidad = _velocidad_normal
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
func spawnear_tanda():
	if _spawn_points.is_empty():
		return
	var markers = _spawn_points.duplicate()
	markers.shuffle()
	var indice_bueno = randi() % markers.size()
	for i in range(markers.size()):
		if i == indice_bueno:
			spawnear_item(markers[i], _pool_buenos)
		else:
			spawnear_item(markers[i], _pool_malos)
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
	if _estado != Estado.PATRULLANDO:
		return
	_estado = Estado.ATACANDO
	_secuencia_de_ataque()
func _secuencia_de_ataque() -> void:
	velocidad = 0.0
	await get_tree().create_timer(randf_range(tiempo_preparacion_min, tiempo_preparacion_max)).timeout
	spawnear_tanda()
	velocidad = _velocidad_normal
	_estado = Estado.PATRULLANDO

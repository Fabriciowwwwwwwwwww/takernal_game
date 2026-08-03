extends "res://scenes/enemy/monster_base.gd"
@export var pan_scene: PackedScene
@export var cebolla_scene: PackedScene
@export var camote_scene: PackedScene
@export var limon_scene: PackedScene
@export var sal_especial_scene: PackedScene
@export var chicharron_scene: PackedScene
@export var basura_scene: PackedScene
@export var ladrillo_scene: PackedScene
@export var intervalo_min: float = 0.4
@export var intervalo_max: float = 1.1
@export var items_por_tanda_min: int = 1
@export var items_por_tanda_max: int = 3
@export var limite_izquierdo: float = 160.0
@export var limite_derecho: float = 1158.0
@export var margen_frenado: float = 250.0
@export var velocidad_minima_factor: float = 0.1
@export var tiempo_preparacion_min: float = 0.6
@export var tiempo_preparacion_max: float = 1.4
@export var fuerza_parabola: float = 350.0
var _spawn_points: Array[Marker2D] = []
var _spawn_timer: float = 0.0
var _proximo_intervalo: float = 0.0
var _velocidad_normal: float
var _pool: Array = []
enum Estado { PATRULLANDO, ATACANDO }
var _estado: Estado = Estado.PATRULLANDO
func _ready():
	_velocidad_normal = velocidad
	for child in get_children():
		if child is Marker2D:
			_spawn_points.append(child)
	_pool = [
		{ "escena": pan_scene,          "prob": 0.08 },
		{ "escena": cebolla_scene,      "prob": 0.06 },
		{ "escena": camote_scene,       "prob": 0.05 },
		{ "escena": limon_scene,        "prob": 0.04 },
		{ "escena": sal_especial_scene, "prob": 0.03 },
		{ "escena": chicharron_scene,   "prob": 0.03 },
		{ "escena": basura_scene,       "prob": 0.42 },
		{ "escena": ladrillo_scene,     "prob": 0.29 },
	]
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
func _elegir_item_random() -> PackedScene:
	var total_prob := 0.0
	for entrada in _pool:
		total_prob += entrada["prob"]
	var r := randf() * total_prob
	var acumulado := 0.0
	for entrada in _pool:
		acumulado += entrada["prob"]
		if r <= acumulado:
			return entrada["escena"]
	return _pool[-1]["escena"]
func spawnear_tanda():
	if _spawn_points.is_empty():
		return
	var cantidad = randi_range(items_por_tanda_min, items_por_tanda_max)
	cantidad = min(cantidad, _spawn_points.size())
	var markers_disponibles = _spawn_points.duplicate()
	markers_disponibles.shuffle()
	for i in range(cantidad):
		spawnear_item(markers_disponibles[i])
func spawnear_item(punto: Marker2D = null):
	if _spawn_points.is_empty():
		return
	var escena: PackedScene = _elegir_item_random()
	if escena == null:
		return
	if punto == null:
		punto = _spawn_points[randi() % _spawn_points.size()]
	var item = escena.instantiate()
	item.global_position = punto.global_position
	get_tree().current_scene.add_child(item)
	if item is RigidBody2D:
		var centro = (limite_izquierdo + limite_derecho) / 2.0
		var lado = 1.0 if punto.global_position.x < centro else -1.0
		var magnitud = randf_range(0.0, fuerza_parabola)
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

extends "res://scenes/enemy/monster_base.gd"

@export var pan_scene: PackedScene
@export var cebolla_scene: PackedScene
@export var camote_scene: PackedScene
@export var limon_scene: PackedScene
@export var sal_especial_scene: PackedScene
@export var chicharron_scene: PackedScene

@export var basura_scene: PackedScene
@export var ladrillo_scene: PackedScene

@export var spawn_interval: float = 0.8

@export var limite_izquierdo: float = 160.0
@export var limite_derecho: float = 1158.0
@export var margen_frenado: float = 250.0
@export var velocidad_minima_factor: float = 0.1
@export var tiempo_preparacion: float = 1.0

var _spawn_points: Array[Marker2D] = []
var _spawn_timer: float = 0.0
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
	if _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		spawnear_item()

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

func spawnear_item():
	if _spawn_points.is_empty():
		return

	var escena: PackedScene = _elegir_item_random()
	if escena == null:
		return
	var punto: Marker2D = _spawn_points[randi() % _spawn_points.size()]
	var item = escena.instantiate()
	item.global_position = punto.global_position
	get_tree().current_scene.add_child(item)
func _llegar_a_extremo():
	if _estado != Estado.PATRULLANDO:
		return
	_estado = Estado.ATACANDO
	_secuencia_de_ataque()
func _secuencia_de_ataque() -> void:
	velocidad = 0.0
	await get_tree().create_timer(tiempo_preparacion).timeout
	spawnear_item()
	velocidad = _velocidad_normal
	_estado = Estado.PATRULLANDO

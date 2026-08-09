extends "res://scenes/enemy/monster_base.gd"
@export var cantidad_items_solo_buenos: int = 2

@export var pan_scene: PackedScene
@export var cebolla_scene: PackedScene
@export var camote_scene: PackedScene
@export var limon_scene: PackedScene
@export var sal_especial_scene: PackedScene
@export var chicharron_scene: PackedScene

@export var basura_scene: PackedScene
@export var ladrillo_scene: PackedScene

@export var cantidad_items_por_tanda: int = 3
@export var intervalo_lanzamiento: float = 1.2
@export var intervalo_entre_disparos: float = 0.15

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

var _spawn_timer := 0.0

var _velocidad_normal: float


var _pool_buenos: Array = []
var _pool_malos: Array = []


var _marker_izq_extremo: Marker2D
var _marker_der_extremo: Marker2D



var _lanzando := false

var activo := true


# NUEVO
var solo_buenos := false



@onready var _audio_lanzamiento: AudioStreamPlayer2D = $AudioStreamPlayer
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D



enum Estado
{
	PATRULLANDO,
	ATACANDO
}


var _estado: Estado = Estado.PATRULLANDO



func _ready():

	_velocidad_normal = velocidad


	for child in get_children():

		if child is Marker2D:

			_spawn_points.append(child)



	# INGREDIENTES BUENOS

	_pool_buenos = [

		{ "escena": pan_scene,          "prob": 0.25 },
		{ "escena": cebolla_scene,      "prob": 0.20 },
		{ "escena": camote_scene,       "prob": 0.20 },
		{ "escena": limon_scene,        "prob": 0.15 },
		{ "escena": sal_especial_scene, "prob": 0.10 },
		{ "escena": chicharron_scene,   "prob": 0.10 },

	]



	# OBJETOS MALOS

	_pool_malos = [

		{ "escena": basura_scene,   "prob": 0.5 },
		{ "escena": ladrillo_scene, "prob": 0.5 }

	]


	for m in _spawn_points:


		if _marker_izq_extremo == null or m.global_position.x < _marker_izq_extremo.global_position.x:

			_marker_izq_extremo = m


		if _marker_der_extremo == null or m.global_position.x > _marker_der_extremo.global_position.x:

			_marker_der_extremo = m





func set_activo(valor: bool):

	activo = valor


	if not activo:

		velocidad = 0.0
		_lanzando = false


		if _sprite:

			_sprite.play("idle")


	else:

		velocidad = _velocidad_normal
		_spawn_timer = 0.0





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





func _ajustar_velocidad_por_borde():


	var distancia_izq = position.x - limite_izquierdo

	var distancia_der = limite_derecho - position.x


	var distancia = min(
		distancia_izq,
		distancia_der
	)



	if distancia < margen_frenado:


		var t = distancia / margen_frenado


		velocidad = lerp(
			_velocidad_normal * velocidad_minima_factor,
			_velocidad_normal,
			t
		)


	else:

		velocidad = _velocidad_normal





func _elegir_item_random(pool:Array) -> PackedScene:


	var total := 0.0


	for entrada in pool:

		total += entrada["prob"]



	var r = randf() * total


	var acumulado := 0.0


	for entrada in pool:


		acumulado += entrada["prob"]


		if r <= acumulado:

			return entrada["escena"]



	return pool[-1]["escena"]

func spawnear_tanda(nombre_animacion:String = "lanzar"):

	if not activo:
		return


	var markers = _spawn_points.duplicate()
	markers.shuffle()


	# ==========================================
	# CANTIDAD DE ITEMS
	# ==========================================

	var cantidad_a_lanzar = cantidad_items_por_tanda

	if solo_buenos:
		cantidad_a_lanzar = cantidad_items_solo_buenos


	# ==========================================
	# LANZAMIENTO
	# ==========================================

	for i in range(cantidad_a_lanzar):

		var pool_actual: Array


		# ======================================
		# MODO SOLO BUENOS
		# ======================================

		if solo_buenos:

			pool_actual = _pool_buenos


		# ======================================
		# MODO NORMAL
		# ======================================

		else:

			var prob_malo = 0.40


			if randf() < prob_malo:

				pool_actual = _pool_malos

			else:

				pool_actual = _pool_buenos


		# ======================================
		# ELEGIR MARKER
		# ======================================

		var punto = markers[i % markers.size()]


		spawnear_item(
			punto,
			pool_actual
		)


		await get_tree().create_timer(
			intervalo_entre_disparos
		).timeout
func spawnear_item(
	punto:Marker2D,
	pool:Array
):


	var escena = _elegir_item_random(pool)


	if escena == null:

		return



	var item = escena.instantiate()


	item.global_position = punto.global_position


	get_tree().current_scene.add_child(item)



	if item is RigidBody2D:


		var centro = (
			limite_izquierdo +
			limite_derecho
		) / 2.0



		var lado = 1.0 if punto.global_position.x < centro else -1.0



		var fuerza = randf_range(
			0.0,
			fuerza_parabola
		)



		item.linear_velocity = Vector2(
			lado * fuerza,
			0
		)





func _llegar_a_extremo():


	if not activo:

		return


	_estado = Estado.ATACANDO


	_spawn_timer = 0.0


	_secuencia_de_ataque()





func _secuencia_de_ataque():


	velocidad = 0.0



	if _sprite:

		_sprite.play("idle")



	await get_tree().create_timer(
		tiempo_preparacion
	).timeout



	if activo:

		spawnear_tanda("lanzar")



	velocidad = _velocidad_normal


	_estado = Estado.PATRULLANDO

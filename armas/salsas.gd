extends Node2D

enum TipoDireccion {
	HORIZONTAL,
	VERTICAL
}

@export_category("Movimiento aleatorio")
@export var movimiento_aleatorio: bool = true
@export var rango_horizontal: float = 200.0

@export_category("Arma")
@export var sprite_arma: Texture2D
@export var proyectil: PackedScene
@export var spriteframes_proyectil: SpriteFrames

@export_category("Orientación")
@export var tipo_direccion: TipoDireccion = TipoDireccion.HORIZONTAL
@export var sentido: int = 1
# 1 = derecha/abajo, -1 = izquierda/arriba

@export_category("Movimiento del arma")
@export var distancia_salida: float = 100.0
@export var tiempo_salida: float = 0.5
@export var tiempo_regreso: float = 0.8
@export var tiempo_antes_de_disparar: float = 0.15

@export_category("Disparo")
@export var direccion_disparo: Vector2 = Vector2.RIGHT

@onready var sprite: Sprite2D = $Sprite2D
@onready var marker: Marker2D = $Marker2D

var posicion_inicial: Vector2
var moviendo := false

func _ready():
	if sprite_arma:
		sprite.texture = sprite_arma
	posicion_inicial = position

func obtener_direccion_movimiento() -> Vector2:
	match tipo_direccion:
		TipoDireccion.HORIZONTAL:
			return Vector2.RIGHT * sentido
		TipoDireccion.VERTICAL:
			return Vector2.DOWN * sentido
	return Vector2.RIGHT

func disparar():
	if moviendo:
		return

	moviendo = true
	var direccion = obtener_direccion_movimiento()
	var posicion_salida = posicion_inicial + direccion * distancia_salida
	var posicion_oculta = posicion_inicial

	if movimiento_aleatorio:
		var offset_horizontal = randf_range(-rango_horizontal / 2, rango_horizontal / 2)
		if tipo_direccion == TipoDireccion.VERTICAL:
			posicion_salida.x += offset_horizontal
			posicion_oculta.x += offset_horizontal
		else:
			posicion_salida.y += offset_horizontal
			posicion_oculta.y += offset_horizontal

	position = posicion_oculta

	var salir = create_tween()
	salir.set_trans(Tween.TRANS_QUAD)
	salir.set_ease(Tween.EASE_OUT)
	salir.tween_property(self, "position", posicion_salida, tiempo_salida)

	await salir.finished
	await get_tree().create_timer(tiempo_antes_de_disparar).timeout

	crear_proyectil()

	var volver = create_tween()
	volver.set_trans(Tween.TRANS_QUAD)
	volver.set_ease(Tween.EASE_IN)
	volver.tween_property(self, "position", posicion_oculta, tiempo_regreso)

	await volver.finished
	moviendo = false

func crear_proyectil():
	if proyectil == null:
		return

	var bala = proyectil.instantiate()
	get_tree().current_scene.add_child(bala)
	bala.global_position = marker.global_position

	if spriteframes_proyectil:
		bala.sprite_frames = spriteframes_proyectil

	var direccion_bala := Vector2.ZERO
	match tipo_direccion:
		TipoDireccion.HORIZONTAL:
			direccion_bala = Vector2.RIGHT * sentido
		TipoDireccion.VERTICAL:
			direccion_bala = Vector2.DOWN * sentido

	if bala.has_method("iniciar"):
		bala.iniciar(direccion_bala)
		
	# aqui se configura el daño

extends Node2D


enum TipoDireccion {
	HORIZONTAL,
	VERTICAL
}


@export_category("Dirección")

@export var tipo_direccion: TipoDireccion = TipoDireccion.HORIZONTAL

# Horizontal:
# 1 = derecha
# -1 = izquierda
#
# Vertical:
# 1 = abajo
# -1 = arriba
@export var sentido := 1



@export_category("Movimiento")

@export var distancia_salida := 250.0

@export var velocidad_inicial := 50.0
@export var velocidad_maxima := 800.0
@export var aceleracion := 600.0

@export var tiempo_antes_salir := 0.5



@export_category("Daño")

@export var daño := 20



@onready var hitbox: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D



var posicion_inicial: Vector2

var moviendo := false
var activa := false



func _ready():

	posicion_inicial = global_position

	ocultar()

	hitbox.monitoring = false



func activar():

	print("CEBOLLA ACTIVADA: ", name)

	if moviendo:
		return


	activa = true

	salir()



func desactivar():

	activa = false

	ocultar()

	hitbox.monitoring = false



func obtener_direccion() -> Vector2:


	match tipo_direccion:


		TipoDireccion.HORIZONTAL:

			return Vector2(
				sentido,
				0
			)



		TipoDireccion.VERTICAL:

			return Vector2(
				0,
				sentido
			)



	return Vector2.RIGHT




func salir():

	print("CEBOLLA SALE: ", name)


	moviendo = true


	mostrar()

	hitbox.monitoring = true



	var direccion := obtener_direccion()


	var recorrido := 0.0

	var velocidad := velocidad_inicial



	while recorrido < distancia_salida:


		var delta := get_process_delta_time()


		velocidad += aceleracion * delta


		velocidad = min(
			velocidad,
			velocidad_maxima
		)



		var movimiento := velocidad * delta



		# Movimiento SOLO horizontal o vertical

		if tipo_direccion == TipoDireccion.HORIZONTAL:

			global_position.x += direccion.x * movimiento


		else:

			global_position.y += direccion.y * movimiento



		recorrido += movimiento



		await get_tree().process_frame




	print("CEBOLLA REGRESA: ", name)


	await get_tree().create_timer(
		0.2
	).timeout


	regresar()




func regresar():


	hitbox.monitoring = false



	var tween := create_tween()


	tween.set_trans(
		Tween.TRANS_QUAD
	)

	tween.set_ease(
		Tween.EASE_IN
	)



	tween.tween_property(
		self,
		"global_position",
		posicion_inicial,
		0.5
	)



	await tween.finished



	# asegurar posición exacta

	global_position = posicion_inicial



	print("CEBOLLA TERMINO: ", name)



	moviendo = false


	desactivar()





func mostrar():

	sprite.show()



func ocultar():

	sprite.hide()





func _on_area_2d_body_entered(body):

	if body.is_in_group("jugador"):


		if body.has_method("recibir_daño"):

			body.recibir_daño(daño)

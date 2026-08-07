extends Node2D
@export var monstruo: Node
@export var cantidad_balas := 3
@onready var CUERPO: AnimatedSprite2D = $CUERPO
@onready var ESPUMA: AnimatedSprite2D = $ESPUMA

@onready var punto_inicio: Marker2D = $"../PuntoInicio"
@onready var punto_final: Marker2D = $"../PuntoFinal"
@onready var salida: Marker2D = $Salida


@export var velocidad := 80.0
@export var tiempo_disparo := 1.0

@export var escena_bala_cafe: PackedScene


var atacando := false



func _ready():

	print("CAFE READY")


	print("Inicio:", punto_inicio.global_position)
	print("Final:", punto_final.global_position)


	CUERPO.play("idle")
	ESPUMA.play("idle")
	ESPUMA.visible = true
func _ataque():

	print("RECIBI ATAQUE")


	if atacando:
		print("YA ESTABA ATACANDO")
		return


	atacando = true


	# Activar solo ingredientes buenos
	if monstruo:
		monstruo.solo_buenos = true


	print("INICIO ATAQUE CAFE")


	for i in range(3):

		print("VIAJE CAFE:", i + 1)


		print("VOY AL PUNTO FINAL")
		await mover(punto_final.global_position)


		print("LLEGUE AL FINAL")

		await get_tree().create_timer(0.5).timeout


		print("REGRESO")
		await mover(punto_inicio.global_position)


		await get_tree().create_timer(0.3).timeout



	# Desactivar solo buenos
	if monstruo:
		monstruo.solo_buenos = false


	CUERPO.play("idle")
	ESPUMA.play("idle")
	ESPUMA.visible = true


	atacando = false


	print("ATAQUE CAFE TERMINADO")

func mover(destino: Vector2):

	print("----------------")
	print("MOVIENDO")
	print("Actual:", global_position)
	print("Destino:", destino)


	var distancia = global_position.distance_to(destino)

	var tiempo = distancia / velocidad


	var tween = create_tween()


	tween.tween_property(
		self,
		"global_position",
		destino,
		tiempo
	)


	print("TWEEN CREADO")


	while tween.is_running():

		disparar.call_deferred()


		await get_tree().create_timer(
			tiempo_disparo
		).timeout



	print("TWEEN TERMINO")


	print("LLEGO A:", global_position)
func disparar():

	print("DISPARANDO 3 CAFES")


	# iniciar ataque
	CUERPO.play("ataque")
	ESPUMA.visible = false


	# esperar un poco la animación antes de lanzar
	await get_tree().create_timer(0.15).timeout



	if escena_bala_cafe == null:

		print("ERROR: NO HAY BALA CAFE")

		CUERPO.play("idle")
		ESPUMA.visible = true
		return


	var cantidad = [3, 4].pick_random()

	print("CANTIDAD DE BALAS:", cantidad)


	var direcciones = []


	var apertura = 1.2


	for i in range(cantidad):

		var porcentaje = 0.0

		if cantidad > 1:
			porcentaje = float(i) / float(cantidad - 1)


		var angulo = lerp(
			- apertura,
			apertura,
			porcentaje
		)


		var direccion = Vector2(
			angulo,
			-1
		).normalized()


		direcciones.append(direccion)


	for direccion in direcciones:


		var bala = escena_bala_cafe.instantiate()


		get_tree().current_scene.add_child(bala)


		bala.global_position = salida.global_position


		print("BALA DIRECCION:", direccion)


		if bala.has_method("disparar"):

			bala.disparar(direccion)



	# terminar animación ataque
	await get_tree().create_timer(0.25).timeout



	CUERPO.play("idle")


	ESPUMA.visible = true
	ESPUMA.play("idle")

	print("CAFE VOLVIO A IDLE")

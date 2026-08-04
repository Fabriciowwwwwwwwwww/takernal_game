extends Node2D


@onready var CUERPO: AnimatedSprite2D = $CUERPO
@onready var ESPUMA: AnimatedSprite2D = $ESPUMA


@export_category("Ataque")

@export var velocidad_misil := 300.0

@export var tiempo_entre_misiles := 0.2



var rutas: Array[PathFollow2D] = []

var atacando := false


func _ready() -> void:

	ESPUMA.play("idle")
	CUERPO.play("idle")


	for hijo in get_children():

		if hijo is Path2D:


			var follow: PathFollow2D = hijo.get_node("PathFollow2D")


			# limpiar transformaciones heredadas
			follow.position = Vector2.ZERO
			follow.rotation = 0
			follow.progress = 0


			var area = follow.get_node("Area2D")

			area.position = Vector2.ZERO
			area.rotation = 0


			rutas.append(follow)


			hijo.hide()

func _ataque():

	if atacando:
		return


	atacando = true


	ESPUMA.play("ataque")
	CUERPO.play("ataque")


	disparar_rutas()



func disparar_rutas():


	# Mezcla las rutas

	rutas.shuffle()



	for ruta in rutas:


		lanzar_misil(ruta)


		await get_tree().create_timer(
			tiempo_entre_misiles
		).timeout



	await get_tree().create_timer(1.0).timeout


	ESPUMA.play("idle")
	CUERPO.play("idle")


	atacando = false


func lanzar_misil(follow: PathFollow2D):

	var path: Path2D = follow.get_parent()


	path.show()


	follow.progress = 0


	var distancia = path.curve.get_baked_length()


	var tween = create_tween()


	tween.set_trans(
		Tween.TRANS_LINEAR
	)


	tween.tween_property(
		follow,
		"progress",
		distancia,
		distancia / velocidad_misil
	)


	await tween.finished


	# desaparece inmediatamente al terminar

	path.hide()


	follow.progress = 0

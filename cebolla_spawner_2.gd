extends Node2D

@export var duracion_evento := 15.0
@export var intervalo_activacion := 1.0

var cebollas: Array[Node2D] = []
var evento_activo := false


func _ready():

	for hijo in get_children():

		if hijo.has_method("activar"):

			cebollas.append(hijo)
			hijo.desactivar()

	print("CEBOLLAS ENCONTRADAS:", cebollas.size())


func iniciar_evento_cebollas():

	if evento_activo:
		return

	evento_activo = true

	print("EVENTO CEBOLLAS INICIADO")

	var tiempo := 0.0

	while tiempo < duracion_evento:

		activar_random()

		await get_tree().create_timer(intervalo_activacion).timeout

		tiempo += intervalo_activacion

	evento_activo = false

	print("EVENTO CEBOLLAS TERMINADO")


func activar_random():

	var disponibles: Array[Node2D] = []

	# Solo cebollas que NO están moviéndose
	for cebolla in cebollas:

		if !cebolla.moviendo:
			disponibles.append(cebolla)

	if disponibles.is_empty():

		print("NO HAY CEBOLLAS DISPONIBLES")
		return


	var maximo: int = max(1, int(disponibles.size() / 2))

	var cantidad := randi_range(1, maximo)

	print("ACTIVANDO CEBOLLAS:", cantidad)


	for i in range(cantidad):

		if disponibles.is_empty():
			break

		var indice := randi() % disponibles.size()

		var cebolla = disponibles[indice]

		disponibles.remove_at(indice)

		print("CEBOLLA ACTIVADA:", cebolla.name)

		cebolla.activar()

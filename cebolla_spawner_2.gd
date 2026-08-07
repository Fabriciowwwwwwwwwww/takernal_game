extends Node2D
@export var monstruo: Node
@export var duracion_evento := 15.0
@export var intervalo_tandas := 2.5 # Tiempo entre cada grupo de cebollas

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
	monstruo.solo_buenos = true

	print("EVENTO CEBOLLAS INICIADO")

	var tiempo := 0.0

	while tiempo < duracion_evento:

		activar_random()

		await get_tree().create_timer(intervalo_tandas).timeout

		tiempo += intervalo_tandas

	evento_activo = false
	monstruo.solo_buenos = false

	print("EVENTO CEBOLLAS TERMINADO")
func activar_random():

	var disponibles: Array[Node2D] = []

	for cebolla in cebollas:
		if !cebolla.moviendo:
			disponibles.append(cebolla)

	if disponibles.is_empty():
		print("NO HAY CEBOLLAS DISPONIBLES")
		return

	# Siempre entre 2 y 3 cebollas (o menos si no hay suficientes)
	var cantidad: int = min(randi_range(2, 3), disponibles.size())

	print("ACTIVANDO CEBOLLAS:", cantidad)

	for i in range(cantidad):

		var indice := randi() % disponibles.size()
		var cebolla = disponibles[indice]
		disponibles.remove_at(indice)

		print("CEBOLLA ACTIVADA:", cebolla.name)
		cebolla.activar()

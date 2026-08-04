extends Node2D


@export var tiempo_spawn := 2.0


var cebollas: Array[Node2D] = []



func _ready():


	for hijo in get_children():


		if hijo.has_method("activar"):


			cebollas.append(hijo)


			hijo.desactivar()



	print(
		"CEBOLLAS ENCONTRADAS: ",
		cebollas.size()
	)



	iniciar_spawn()




func iniciar_spawn():


	while true:


		await get_tree().create_timer(
			tiempo_spawn
		).timeout



		activar_cebolla()




func activar_cebolla():


	if cebollas.is_empty():

		print("NO HAY CEBOLLAS")

		return



	var cebolla = cebollas.pick_random()



	print(
		"SPAWNER ACTIVA: ",
		cebolla.name
	)



	cebolla.activar()

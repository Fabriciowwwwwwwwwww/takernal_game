extends Node2D


@export var cafe: Node2D

@export var tiempo_ataque := 3.0



func _ready():


	while true:


		await get_tree().create_timer(
			tiempo_ataque
		).timeout



		print("Cafe ataca")


		cafe._ataque()

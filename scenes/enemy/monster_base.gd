extends Node2D

@export var velocidad:= 100
@export var direccion:= 1

func mover(delta):
	position.x += velocidad*direccion*delta

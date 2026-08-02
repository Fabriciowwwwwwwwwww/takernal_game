extends Node2D


@export var velocidad:= 100
@export var direccion:= 1

func moverY(delta):
	position.y += velocidad*direccion*delta

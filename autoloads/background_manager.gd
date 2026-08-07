extends Node


var sprite_fondo: Sprite2D


@export var fondos: Dictionary[String, Texture2D]


func registrar_fondo(sprite: Sprite2D):

	sprite_fondo = sprite



func cambiar_fondo(nombre:String):

	if not fondos.has(nombre):
		push_warning("No existe el fondo: " + nombre)
		return


	if sprite_fondo:

		sprite_fondo.texture = fondos[nombre]

	else:

		push_warning("No existe Sprite del fondo")

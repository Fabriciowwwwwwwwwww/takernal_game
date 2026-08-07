extends AnimatableBody2D


@export var mover: bool = false
@export var rango: float = 500.0
@export var velocidad: float = 20


var inicio_x: float
var direccion := 1


func _ready():

	inicio_x = global_position.x

	print("PLATAFORMA ACTIVA")
	print("Posicion:", global_position)
	print("Mover:", mover)



func _physics_process(delta):

	if mover == false:
		return


	global_position.x += velocidad * direccion * delta


	if global_position.x >= inicio_x + rango:
		direccion = -1


	if global_position.x <= inicio_x:
		direccion = 1

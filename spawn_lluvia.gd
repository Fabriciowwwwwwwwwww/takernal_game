extends Node2D


@export var tiempo_lluvia: float = 6.0


@onready var timer: Timer = $Timer
@onready var rain_attack = $"../RainAttack"



func _ready():

	timer.wait_time = tiempo_lluvia
	timer.one_shot = false

	timer.timeout.connect(
		activar_lluvia
	)

	timer.start()



func activar_lluvia():

	rain_attack.iniciar_ataque()

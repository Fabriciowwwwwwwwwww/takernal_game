extends Node2D

@export var tiempo_charge: float = 2.0 

@onready var rain_attack = $RainAttack 
@onready var gaseosa: AnimatedSprite2D = $gaseosa/AnimatedSprite2D
@onready var gaseosa2: AnimatedSprite2D = $gaseosa2/AnimatedSprite2D

func _ready():
	# Apenas el Controlador Principal crea esta escena, ejecutamos el ataque
	gaseosa.play("idle")
	gaseosa2.play("idle")
	activar_lluvia()

func activar_lluvia() -> void:
	# 1. Animación de preparación (Los 2 segundos antes del ataque)
	gaseosa.play("charge")
	gaseosa2.play("charge")

	await get_tree().create_timer(tiempo_charge).timeout

	# 2. Empieza a disparar
	gaseosa.play("shoot")
	gaseosa2.play("shoot")

	# Llama al otro script que dejó el programador para hacer la lluvia de balas
	if rain_attack:
		rain_attack.iniciar_ataque()

	# 3. Vuelve a idle al terminar la animación
	await gaseosa.animation_finished
	gaseosa.play("idle")
	gaseosa2.play("idle")

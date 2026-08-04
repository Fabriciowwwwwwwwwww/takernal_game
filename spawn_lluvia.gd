extends Node2D

@export var tiempo_lluvia: float = 6.0
@export var tiempo_charge: float = 3.0

@onready var timer: Timer = $Timer
@onready var rain_attack = $"../RainAttack"
@onready var gaseosa: AnimatedSprite2D = $gaseosa/AnimatedSprite2D
@onready var gaseosa2: AnimatedSprite2D = $gaseosa2/AnimatedSprite2D


func _ready():
	gaseosa.play("idle")
	gaseosa2.play("idle")

	timer.wait_time = tiempo_lluvia
	timer.one_shot = false
	timer.timeout.connect(activar_lluvia)
	timer.start()


func activar_lluvia() -> void:
	# 3 segundos antes del ataque
	gaseosa.play("charge")
	gaseosa2.play("charge")

	await get_tree().create_timer(tiempo_charge).timeout

	# Disparo
	gaseosa.play("shoot")
	gaseosa2.play("shoot")

	rain_attack.iniciar_ataque()

	# Esperar a que termine la animación
	await gaseosa.animation_finished

	gaseosa.play("idle")
	gaseosa2.play("idle")

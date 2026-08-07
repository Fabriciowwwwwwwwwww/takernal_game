extends Node2D

@export var tiempo_charge: float = 2.0
@export var tiempo_descanso: float = 1.0 # Pausa entre cada lluvia de gotas

@onready var rain_attack = $RainAttack
@onready var gaseosa: AnimatedSprite2D = $gaseosa/AnimatedSprite2D
@onready var gaseosa2: AnimatedSprite2D = $gaseosa2/AnimatedSprite2D

func _ready():
	gaseosa.play("idle")
	gaseosa2.play("idle")
	bucle_de_ataques()

func bucle_de_ataques():
	while true:
	
		gaseosa.play("charge")
		gaseosa2.play("charge")
		
		await get_tree().create_timer(tiempo_charge).timeout
		
	
		gaseosa.play("shoot")
		gaseosa2.play("shoot")
		

		await gaseosa.animation_finished
		

		gaseosa.play("idle")
		gaseosa2.play("idle")
		

		if rain_attack:
			await rain_attack.iniciar_ataque()
		

		await get_tree().create_timer(tiempo_descanso).timeout

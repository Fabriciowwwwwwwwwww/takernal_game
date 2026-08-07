extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer 

func _ready() -> void:
	iniciar_patron_platos()

func iniciar_patron_platos() -> void:
	anim.play("quieto")
	await get_tree().create_timer(10.0).timeout 
	
	anim.play("escalera")
	await get_tree().create_timer(25.0).timeout 
	
	anim.play("trancision")
	await anim.animation_finished 
	
	anim.play("movimiento_platos")

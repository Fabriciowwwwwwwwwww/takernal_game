extends Node2D

@export var vida: int = 100

@onready var anim: AnimationPlayer = $AnimationPlayer 

func _ready() -> void:
	iniciar_patron_ataque()

func iniciar_patron_ataque() -> void:
	anim.play("idle")
	await get_tree().create_timer(7.0).timeout 
	
	anim.play("posicion_ataque")
	await anim.animation_finished 
	
	anim.play("ataque_escalera")
	await get_tree().create_timer(20.0).timeout 
	
	anim.play("subida")

func recibir_danio(cantidad: int) -> void:
	vida -= cantidad
	
	if vida <= 0:
		queue_free()

func _on_patas_body_entered(body: Node2D) -> void:
	if body.is_in_group("balas_jugador"):
		recibir_danio(10)
		body.queue_free()
	elif body.is_in_group("player"):
		print("Hizo daño al jugador")

func _on_piernas_body_entered(body: Node2D) -> void:
	if body.is_in_group("balas_jugador"):
		recibir_danio(10)
		body.queue_free()
	elif body.is_in_group("player"):
		print("Hizo daño al jugador")

func _on_cuello_body_entered(body: Node2D) -> void:
	if body.is_in_group("balas_jugador"):
		recibir_danio(10)
		body.queue_free()
	elif body.is_in_group("player"):
		print("Hizo daño al jugador")

func _on_boca_body_entered(body: Node2D) -> void:
	if body.is_in_group("balas_jugador"):
		recibir_danio(10)
		body.queue_free()
	elif body.is_in_group("player"):
		print("Hizo daño al jugador")

func _on_cabeza_body_entered(body: Node2D) -> void:
	if body.is_in_group("balas_jugador"):
		recibir_danio(10)
		body.queue_free()
	elif body.is_in_group("player"):
		print("Hizo daño al jugador")

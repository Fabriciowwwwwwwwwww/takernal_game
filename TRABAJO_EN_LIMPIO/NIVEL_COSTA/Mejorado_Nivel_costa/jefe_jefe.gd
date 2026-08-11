extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
var jugadores: Array[Node2D] = []

func _ready() -> void:
	iniciar_patron_ataque()

func asignar_jugadores(lista: Array[Node2D]) -> void:
	jugadores = lista

func iniciar_patron_ataque() -> void:
	while is_inside_tree():
		anim.play("idle")
		await get_tree().create_timer(7.0).timeout 
		
		anim.play("posicion_ataque")
		await anim.animation_finished 
		
		anim.play("ataque_escalera")
		await get_tree().create_timer(20.0).timeout 
		
		anim.play("subida")
		await anim.animation_finished

func _on_patas_body_entered(body: Node2D) -> void:
	if body.is_in_group("balas_jugador"):
		body.queue_free()
	elif body.has_method("perder_vida"):
		body.perder_vida()

func _on_piernas_body_entered(body: Node2D) -> void:
	if body.is_in_group("balas_jugador"):
		body.queue_free()
	elif body.has_method("perder_vida"):
		body.perder_vida()

func _on_cuello_body_entered(body: Node2D) -> void:
	if body.is_in_group("balas_jugador"):
		body.queue_free()
	elif body.has_method("perder_vida"):
		body.perder_vida()

func _on_boca_body_entered(body: Node2D) -> void:
	if body.is_in_group("balas_jugador"):
		body.queue_free()
	elif body.has_method("perder_vida"):
		body.perder_vida()

func _on_cabeza_body_entered(body: Node2D) -> void:
	if body.is_in_group("balas_jugador"):
		body.queue_free()
	elif body.has_method("perder_vida"):
		body.perder_vida()

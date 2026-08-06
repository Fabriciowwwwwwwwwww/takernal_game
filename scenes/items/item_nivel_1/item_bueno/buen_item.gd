extends RigidBody2D
var sobre_plataforma := false
@export var nombre := "pan"

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):

		var hud = get_tree().get_first_node_in_group("hud")

		if hud:
			hud.agregar_ingrediente(nombre)



		queue_free()

	if body.is_in_group("plataforma") and !sobre_plataforma:
		sobre_plataforma = true
		await get_tree().create_timer(2.0).timeout
		queue_free()

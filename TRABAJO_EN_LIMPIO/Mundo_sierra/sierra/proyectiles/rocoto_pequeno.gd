extends Area2D

@export var velocidad: float = 350.0
@onready var animacion_rocoto: AnimatedSprite2D = $animacion_rocoto
var direccion: Vector2 = Vector2.LEFT


func _ready() -> void:
	animacion_rocoto.play("idle")
	body_entered.connect(_on_body_entered)


func configurar_direccion(nueva_direccion: Vector2) -> void:
	direccion = nueva_direccion.normalized()


func _physics_process(delta: float) -> void:
	global_position += direccion * velocidad * delta


func _on_body_entered(cuerpo: Node2D) -> void:

	# Comprobar si tocamos al jugador
	if cuerpo.has_method("recibir_daño"):

		cuerpo.recibir_daño()

		# El proyectil desaparece al golpear
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

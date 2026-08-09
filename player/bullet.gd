extends Area2D

@export var speed := 900.0
@export var damage := 1

var direction := Vector2.RIGHT

func _ready() -> void:
	add_to_group("balas_jugador")

	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
		
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func iniciar(nueva_direccion: Vector2):
	direction = nueva_direccion.normalized()
	rotation = direction.angle()

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemigo") or area.name.contains("Sierra") or area.has_method("recibir_daño"):
		impactar_enemigo(area)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigo") or body.name.contains("Sierra") or body.has_method("recibir_daño"):
		impactar_enemigo(body)

func impactar_enemigo(entidad) -> void:
	# Disminuir el progreso en el HUD (ej. resta 1.0 como pediste antes)
	var hud = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("disminuir_progreso"):
		hud.disminuir_progreso(1.0)

	# Llamar a recibir_daño en el enemigo para activar el conteo de los 6 impactos
	if entidad.has_method("recibir_daño"):
		entidad.recibir_daño()

	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

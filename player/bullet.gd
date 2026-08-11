extends Area2D

@export var speed := 900.0
@export var damage := 1

var direction := Vector2.RIGHT

func _ready() -> void:
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
	if area.has_method("perder_vida"):
		area.perder_vida()
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("perder_vida"):
		body.perder_vida()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

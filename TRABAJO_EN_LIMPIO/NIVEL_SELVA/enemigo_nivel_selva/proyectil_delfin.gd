extends Area2D

@export var velocidad: float = 600.0
@export var tiempo_de_vida: float = 2.0

var direccion: int = 1

func _ready() -> void:
	if direccion == -1:
		scale.x = -1
		
	await get_tree().create_timer(tiempo_de_vida).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position.x += velocidad * direccion * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("jefe_selva") or area.is_in_group("enemigo"):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is TileMap:
		queue_free()

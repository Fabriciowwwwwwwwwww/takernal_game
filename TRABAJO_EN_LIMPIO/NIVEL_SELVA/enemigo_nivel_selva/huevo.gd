extends Area2D

@export var gravedad: float = 600.0
@export var tiempo_vuelo: float = 1.8

var objetivo := Vector2.ZERO
var velocidad_actual := Vector2.ZERO
var roto := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if objetivo != Vector2.ZERO:
		var desplazamiento = objetivo - global_position
		velocidad_actual.x = desplazamiento.x / tiempo_vuelo
		velocidad_actual.y = (desplazamiento.y - 0.5 * gravedad * tiempo_vuelo * tiempo_vuelo) / tiempo_vuelo
	
	await get_tree().create_timer(10.0).timeout
	if not roto:
		queue_free()

func _physics_process(delta: float) -> void:
	if roto:
		return
		
	velocidad_actual.y += gravedad * delta
	position += velocidad_actual * delta
	
	if velocidad_actual.y > 0:
		rotation += 3.0 * delta

func romper() -> void:
	if roto:
		return
		
	roto = true
	set_deferred("monitoring", false)
	rotation = 0
	
	if anim:
		anim.play("explosion")
		await anim.animation_finished
		
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if roto:
		return
		
	if body.is_in_group("player"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(1)
		romper()
	elif body.is_in_group("plataforma") or body is TileMap:
		romper()

func _on_area_entered(area: Area2D) -> void:
	if roto:
		return
		
	if area.is_in_group("plataforma"):
		romper()

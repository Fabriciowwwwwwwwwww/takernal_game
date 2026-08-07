extends CanvasLayer

signal pantalla_cerrada
signal terminado

@onready var intermedio: AnimationPlayer = $transitionAnimation
@onready var fondo_parallax: ParallaxBackground = $Fondo_movimiento2

@export var velocidad_cielo: Vector2 = Vector2(-150, 0) 

func _ready() -> void:

	fondo_parallax.visible = false
	

	intermedio.play("transition_out") 
	await intermedio.animation_finished
	

	emit_signal("pantalla_cerrada")

	fondo_parallax.visible = true
	intermedio.play("transition_in") 
	await intermedio.animation_finished
	

	await get_tree().create_timer(5.0).timeout 
	
	intermedio.play("transition_out") 
	await intermedio.animation_finished
	

	fondo_parallax.visible = false
	intermedio.play("transition_in") 
	await intermedio.animation_finished
	

	emit_signal("terminado")


func _process(delta: float) -> void:
	if fondo_parallax and fondo_parallax.visible:
		fondo_parallax.scroll_offset += velocidad_cielo * delta

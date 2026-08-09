extends CanvasLayer

signal pantalla_cerrada
signal terminado

@onready var intermedio: AnimationPlayer = $transitionAnimation

@onready var fondo1: ParallaxBackground = $ParallaxBackground8
@onready var fondo2: ParallaxBackground = $ParallaxBackground5
@onready var fondo3: ParallaxBackground = $ParallaxBackground
@onready var fondo4: ParallaxBackground = $ParallaxBackground7
@onready var fondo5: ParallaxBackground = $ParallaxBackground2
@onready var fondo6: ParallaxBackground = $ParallaxBackground3
@onready var fondo7: ParallaxBackground = $ParallaxBackground4


var lista_fondos: Array = []

func _ready() -> void:
	lista_fondos = [fondo1, fondo2, fondo3, fondo4, fondo5, fondo6, fondo7]
	
	cambiar_visibilidad_fondos(false)
	
	intermedio.play("transition_out")
	await intermedio.animation_finished
	
	emit_signal("pantalla_cerrada")
	
	cambiar_visibilidad_fondos(true)
	
	intermedio.play("transition_in")
	await intermedio.animation_finished
	
	await get_tree().create_timer(5.0).timeout
	
	intermedio.play("transition_out")
	await intermedio.animation_finished
	
	cambiar_visibilidad_fondos(false)
	
	intermedio.play("transition_in")
	await intermedio.animation_finished
	
	emit_signal("terminado")


func cambiar_visibilidad_fondos(estado: bool) -> void:
	for fondo in lista_fondos:
		if fondo:
			fondo.visible = estado

extends Node

# Arrastra tu nodo Puzle desde el inspector aquí
@export var nodo_puzle : Node2D 

# Arrastra aquí tu Sprite, Panel o Partículas
@export var imagen_victoria : Sprite2D 


@onready var musica: AudioStreamPlayer2D = $sonido_mundo

func _ready():
	musica.play()


#
#func _ready():
	## Escondemos la imagen al empezar
	#imagen_victoria.visible = false
	#
	## Le decimos al puzle: "Cuando emitas 'nivel_superado', ejecuta mi función 'mostrar_animacion'"
	#if nodo_puzle != null:
		#nodo_puzle.nivel_superado.connect(mostrar_animacion)
#
#func mostrar_animacion():
	#print("¡El otro script detectó la victoria!")
	#imagen_victoria.visible = true
	#
	## Ejemplo rápido usando un Tween para que la imagen haga un rebote al aparecer
	#imagen_victoria.scale = Vector2(0.1, 0.1)
	#var tween = create_tween()
	#tween.tween_property(imagen_victoria, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BOUNCE)
#

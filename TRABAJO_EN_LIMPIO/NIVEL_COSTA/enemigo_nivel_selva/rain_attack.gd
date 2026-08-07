extends Node2D


@export_category("Proyectil")

@export var proyectil: PackedScene


@export_category("Ataque")

@export var cantidad_balas_por_lado: int = 10
@export var intervalo: float = 0.15


enum TipoAtaque {
	IZQUIERDA_DERECHA,
	AMBOS_LADOS,
	SOLO_DERECHA,
	SOLO_IZQUIERDA
}


@export_category("Configuración ataque")

@export_category("Configuración ataque")

@export var ataque_aleatorio: bool = true
@export var modo_ataque: TipoAtaque = TipoAtaque.IZQUIERDA_DERECHA


@export_category("Marcadores")

@export var distancia_vertical: float = 600.0


@onready var izquierda: Marker2D = $Izquierda
@onready var derecha: Marker2D = $Derecha
@onready var centro: Marker2D = $Centro



func iniciar_ataque():

	var modo_actual = modo_ataque


	# Si está activado, elige uno de los 4
	if ataque_aleatorio:

		modo_actual = randi_range(
			0,
			TipoAtaque.size() - 1
		)


	match modo_actual:


		# 1 - izquierda y luego derecha
		TipoAtaque.IZQUIERDA_DERECHA:

			await lluvia_desde_lado(izquierda)

			await lluvia_desde_lado(derecha)



		# 2 - ambos lados juntos
		TipoAtaque.AMBOS_LADOS:

			await lluvia_doble()



		# 3 - solo derecha
		TipoAtaque.SOLO_DERECHA:

			await lluvia_desde_lado(derecha)



		# 4 - solo izquierda
		TipoAtaque.SOLO_IZQUIERDA:

			await lluvia_desde_lado(izquierda)


func lluvia_doble():

	for i in cantidad_balas_por_lado:

		crear_bala(izquierda, i)

		crear_bala(derecha, i)


		await get_tree().create_timer(intervalo).timeout



func lluvia_desde_lado(origen: Marker2D):

	for i in cantidad_balas_por_lado:

		crear_bala(origen, i)

		await get_tree().create_timer(intervalo).timeout





func crear_bala(origen: Marker2D, numero:int):

	if proyectil == null:
		return


	var bala = proyectil.instantiate()


	get_tree().current_scene.add_child(bala)


	# posición inicial
	var posicion = origen.global_position


	# hace que avance hacia el centro
	var progreso = float(numero) / cantidad_balas_por_lado


	posicion.x = lerp(
		origen.global_position.x,
		centro.global_position.x,
		progreso
	)


	bala.global_position = posicion



	# siempre cae vertical
	var direccion = Vector2.DOWN


	if bala.has_method("iniciar"):

		bala.iniciar(direccion)

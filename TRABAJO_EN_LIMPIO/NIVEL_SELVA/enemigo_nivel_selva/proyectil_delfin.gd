extends Area2D

@export var velocidad: float = 600.0
@export var tiempo_de_vida: float = 2.0
@export var daño: int = 1

var direccion: int = 1


func _ready() -> void:

	# =====================================================
	# GRUPO DE BALAS DEL JUGADOR
	# =====================================================

	if not is_in_group("balas_jugador"):

		add_to_group("balas_jugador")


	# =====================================================
	# VOLTEAR SPRITE
	# =====================================================

	if direccion == -1:

		scale.x = -1


	# =====================================================
	# TIEMPO DE VIDA
	# =====================================================

	await get_tree().create_timer(
		tiempo_de_vida
	).timeout

	if is_inside_tree():

		queue_free()


# =========================================================
# MOVIMIENTO
# =========================================================

func _physics_process(delta: float) -> void:

	position.x += (
		velocidad
		*
		direccion
		*
		delta
	)


# =========================================================
# IMPACTO CONTRA AREA
# =========================================================

func _on_area_entered(
	area: Area2D
) -> void:

	if area == null:
		return


	# =====================================================
	# JEFE SELVA
	# =====================================================

	if area.is_in_group("jefe_selva"):

		print(
			"[BALA] ¡IMPACTO CONTRA JEFE!"
		)


		# -------------------------------------------------
		# BUSCAR HUD
		# -------------------------------------------------

		var hud = get_tree().get_first_node_in_group(
			"hud_selva"
		)


		# -------------------------------------------------
		# SI NO ESTÁ EN GRUPO, BUSCAR POR NOMBRE
		# -------------------------------------------------

		if hud == null:

			hud = get_tree().current_scene.get_node_or_null(
				"CanvasLayer"
			)


		# -------------------------------------------------
		# APLICAR DAÑO AL HUD
		# -------------------------------------------------

		if hud != null:

			if hud.has_method(
				"recibir_daño_enemigo"
			):

				print(
					"[BALA] Quitando ",
					daño,
					" de vida al enemigo"
				)

				hud.recibir_daño_enemigo(
					daño
				)

			else:

				print(
					"[BALA] ERROR: El HUD no tiene recibir_daño_enemigo()"
				)

		else:

			print(
				"[BALA] ERROR: No se encontró el HUD"
			)


		queue_free()

		return


	# =====================================================
	# OTROS ENEMIGOS
	# =====================================================

	if area.is_in_group("enemigo"):

		if area.has_method("recibir_daño"):

			area.recibir_daño(
				daño
			)

		queue_free()


# =========================================================
# IMPACTO CONTRA CUERPO
# =========================================================

func _on_body_entered(
	body: Node2D
) -> void:

	if body is TileMap:

		queue_free()

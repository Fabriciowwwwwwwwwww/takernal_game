extends Node2D

# =========================================================
# NAVE
# =========================================================

@export_category("Nave")

@export var nave_scene: PackedScene

# =========================================================
# FORMACIÓN
# =========================================================

@export_category("Formación")

@export var cantidad_naves: int = 6
@export var separacion_vertical: float = 45.0

# =========================================================
# MOVIMIENTO
# =========================================================

@export_category("Movimiento")

@export var velocidad: float = 250.0
@export var amplitud: float = 80.0
@export var frecuencia: float = 3.0

# =========================================================
# APARICIÓN
# =========================================================

@export_category("Aparición")

@export var intervalo: float = 0.12

# =========================================================
# POSICIÓN DE APARICIÓN (MULTIPLE SPAWN)
# =========================================================

@export_category("Posición de aparición")

@export var spawns: Array[Marker2D] = []

# =========================================================
# ESTADO
# =========================================================

var atacando: bool = false

# =========================================================
# INICIAR ATAQUE
# =========================================================

func iniciar_ataque() -> void:

	if atacando:
		return

	if nave_scene == null:
		print("ERROR: Spawner no tiene nave_scene")
		return

	atacando = true

	print("=== ATAQUE DE NAVES SERPIENTE ===")

	# =====================================================
	# SELECCIONAR SPAWN ALEATORIO
	# =====================================================

	var posicion_base: Vector2 = Vector2(1800, 350) # Posición por defecto de respaldo

	if not spawns.is_empty():
		var marker_elegido: Marker2D = spawns.pick_random()
		if is_instance_valid(marker_elegido):
			posicion_base = marker_elegido.global_position
			print("Spawn aleatorio seleccionado en: ", posicion_base)


	# =====================================================
	# CREAR FORMACIÓN
	# =====================================================

	for i in range(cantidad_naves):

		var nave: Node2D = nave_scene.instantiate()

		get_tree().current_scene.add_child(nave)


		# =================================================
		# POSICIÓN VERTICAL
		# =================================================

		var desplazamiento_y: float = (
			float(i)
			- float(cantidad_naves - 1) / 2.0
		) * separacion_vertical


		nave.global_position = (
			posicion_base
			+ Vector2(0.0, desplazamiento_y)
		)


		# =================================================
		# DESFASE DE LA ONDA
		# =================================================

		var desfase: float = float(i) * 0.35


		# =================================================
		# CONFIGURAR MOVIMIENTO
		# =================================================

		if nave.has_method("configurar_movimiento"):

			nave.configurar_movimiento(
				velocidad,
				amplitud,
				frecuencia,
				desfase
			)
		else:

			print(
				"ADVERTENCIA: La nave no tiene configurar_movimiento()"
			)


		# =================================================
		# ESPERAR
		# =================================================

		await get_tree().create_timer(
			intervalo
		).timeout


	atacando = false

	print("=== FORMACIÓN COMPLETA ===")

extends Node2D

# =========================================================
# SEÑALES PARA EL HUD
# =========================================================

signal vida_actualizada(vida_actual: int, vida_maxima: int)
signal jefe_derrotado
@onready var marcador_chifle_arriba: Marker2D = $"../chifle"
@onready var marcador_chifle_abajo: Marker2D = $"../chifle2"
# =========================================================
# PROYECTILES
# =========================================================

@export_category("Proyectiles")

@export var chifle_1_escena: PackedScene
@export var chifle_2_escena: PackedScene
@export var huevo_escena: PackedScene

# =========================================================
# VIDA
# =========================================================



# =========================================================
# ESTADOS
# =========================================================

var en_parpadeo_invencible: bool = false
var combate_activo: bool = true
var fase_ataque: bool = false

# IMPORTANTE:
# El jefe YA NO será invulnerable durante las fases.
# Las balas podrán hacer daño siempre.

# =========================================================
# MOVIMIENTO VERTICAL
# =========================================================

@export_category("Movimiento Vertical")

@export var movimiento_vertical: float = 100.0
@export var velocidad_movimiento: float = 1.5

var posicion_base: Vector2
var tiempo_movimiento: float = 0.0

# =========================================================
# NODOS
# =========================================================

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var marcador_chifles: Marker2D = $chifles
@onready var marcador_huevos: Marker2D = $Marker2D


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	randomize()

	# -------------------------------------------------------
	# VIDA
	# -------------------------------------------------------



	# -------------------------------------------------------
	# GRUPO DEL JEFE
	# -------------------------------------------------------

	if not is_in_group("jefe_selva"):
		add_to_group("jefe_selva")

	if not is_in_group("enemigo"):
		add_to_group("enemigo")

	# -------------------------------------------------------
	# POSICIÓN BASE
	# -------------------------------------------------------

	posicion_base = global_position

	# -------------------------------------------------------
	# AVISAR VIDA INICIAL
	# -------------------------------------------------------





	# -------------------------------------------------------
	# INICIAR PATRÓN
	# -------------------------------------------------------

	iniciar_patron()


# =========================================================
# MOVIMIENTO
# =========================================================

func _process(delta: float) -> void:

	if not combate_activo:
		return

	# -------------------------------------------------------
	# MOVIMIENTO VERTICAL DURANTE ATAQUE
	# -------------------------------------------------------

	if fase_ataque:

		tiempo_movimiento += (
			delta * velocidad_movimiento
		)

		global_position.y = (
			posicion_base.y
			+
			sin(tiempo_movimiento)
			*
			movimiento_vertical
		)


# =========================================================
# PATRÓN DEL JEFE
# =========================================================
# =========================================================
# PATRÓN DEL JEFE
# =========================================================

func iniciar_patron() -> void:

	await get_tree().process_frame

	while is_inside_tree() and combate_activo:

		# =====================================================
		# NUEVA RONDA
		# =====================================================

		print("======================================")
		print("[JEFE] NUEVA RONDA")
		print("======================================")

		fase_ataque = false

		await volver_a_posicion_base()

		if not combate_activo:
			return

		anim.play("idle")

		await get_tree().create_timer(0.8).timeout

		if not combate_activo:
			return


		# =====================================================
		# CHIFLES PEQUEÑOS
		# SÍ UTILIZAN PATRÓN
		# =====================================================

		var patron := randi() % 6

		var patrones = [
			[0, 1, 0], # ARRIBA - ABAJO - ARRIBA
			[1, 0, 1], # ABAJO - ARRIBA - ABAJO
			[0, 1, 1], # ARRIBA - ABAJO - ABAJO
			[1, 1, 0], # ABAJO - ABAJO - ARRIBA
			[0, 0, 1], # ARRIBA - ARRIBA - ABAJO
			[1, 0, 0]  # ABAJO - ARRIBA - ARRIBA
		]

		var secuencia = patrones[patron]

		print("[JEFE] Patrón pequeño: ", secuencia)

		fase_ataque = true
		anim.play("aleteo")


		# =====================================================
		# DISPARAR 3 CHIFLES PEQUEÑOS
		# =====================================================

		for posicion in secuencia:

			if not combate_activo:
				return

			if posicion == 0:

				print("[JEFE] CHIFLE PEQUEÑO → ARRIBA")

				lanzar_objeto(
					chifle_1_escena,
					marcador_chifle_arriba
				)

			else:

				print("[JEFE] CHIFLE PEQUEÑO → ABAJO")

				lanzar_objeto(
					chifle_1_escena,
					marcador_chifle_abajo
				)

			await get_tree().create_timer(0.85).timeout


		if not combate_activo:
			return


		# =====================================================
		# PAUSA
		# =====================================================

		fase_ataque = false

		await volver_a_posicion_base()

		if not combate_activo:
			return

		anim.play("idle")

		await get_tree().create_timer(0.5).timeout

		if not combate_activo:
			return


		# =====================================================
		# ATAQUE DE HUEVOS
		# LOS HUEVOS YA NO PERSIGUEN
		# =====================================================

		print("======================================")
		print("[JEFE] ATAQUE DE HUEVOS")
		print("======================================")

		anim.play("open")


		# -----------------------------------------------------
		# PRIMERA RÁFAGA
		# -----------------------------------------------------

		for i in range(6):

			if not combate_activo:
				return

			print("[JEFE] HUEVO ", i + 1, "/ 6")

			# El huevo toma la posición del jugador
			# SOLO en este instante.
			lanzar_huevo()

			await get_tree().create_timer(0.32).timeout


		if not combate_activo:
			return


		# -----------------------------------------------------
		# PAUSA
		# -----------------------------------------------------

		await get_tree().create_timer(0.35).timeout

		if not combate_activo:
			return


		# -----------------------------------------------------
		# SEGUNDA RÁFAGA
		# -----------------------------------------------------

		print("[JEFE] SEGUNDA RÁFAGA DE HUEVOS")

		for i in range(5):

			if not combate_activo:
				return

			print("[JEFE] HUEVO EXTRA ", i + 1, "/ 5")

			lanzar_huevo()

			await get_tree().create_timer(0.27).timeout


		if not combate_activo:
			return


		# =====================================================
		# PAUSA ANTES DE CHIFLES GRANDES
		# =====================================================

		anim.play("idle")

		await get_tree().create_timer(1.0).timeout

		if not combate_activo:
			return


		# =====================================================
		# CHIFLES GRANDES
		#
		# SOLO 2 POR RONDA
		#
		# NO UTILIZAN EL PATRÓN DE LOS PEQUEÑOS.
		# CADA UNO ELIGE ARRIBA O ABAJO ALEATORIAMENTE.
		# =====================================================

		print("======================================")
		print("[JEFE] ATAQUE DE 2 CHIFLES GRANDES")
		print("======================================")

		fase_ataque = true
		anim.play("aleteo")


		# =====================================================
		# PRIMER CHIFLE GRANDE
		# =====================================================

		if not combate_activo:
			return

		var grande_1: int = randi() % 2

		if grande_1 == 0:

			print("[JEFE] CHIFLE GRANDE 1 → ARRIBA")

			lanzar_objeto(
				chifle_2_escena,
				marcador_chifle_arriba
			)

		else:

			print("[JEFE] CHIFLE GRANDE 1 → ABAJO")

			lanzar_objeto(
				chifle_2_escena,
				marcador_chifle_abajo
			)


		# =====================================================
		# ESPERA ENTRE CHIFLES GRANDES
		# =====================================================

		await get_tree().create_timer(1.3).timeout

		if not combate_activo:
			return


		# =====================================================
		# SEGUNDO CHIFLE GRANDE
		# =====================================================

		var grande_2: int = randi() % 2

		if grande_2 == 0:

			print("[JEFE] CHIFLE GRANDE 2 → ARRIBA")

			lanzar_objeto(
				chifle_2_escena,
				marcador_chifle_arriba
			)

		else:

			print("[JEFE] CHIFLE GRANDE 2 → ABAJO")

			lanzar_objeto(
				chifle_2_escena,
				marcador_chifle_abajo
			)


		# =====================================================
		# ESPERA DESPUÉS DEL SEGUNDO GRANDE
		# =====================================================

		await get_tree().create_timer(1.4).timeout

		if not combate_activo:
			return


		# =====================================================
		# FIN DE RONDA
		# =====================================================

		print("======================================")
		print("[JEFE] FIN DE RONDA")
		print("======================================")

		fase_ataque = false

		await volver_a_posicion_base()

		if not combate_activo:
			return

		anim.play("idle")

		await get_tree().create_timer(1.5).timeout
func volver_a_posicion_base() -> void:

	if not is_inside_tree():
		return

	var tween := create_tween()

	tween.set_trans(
		Tween.TRANS_SINE
	)

	tween.set_ease(
		Tween.EASE_IN_OUT
	)

	tween.tween_property(
		self,
		"global_position",
		posicion_base,
		0.5
	)

	await tween.finished


# =========================================================
# LANZAR CHIFLE
# =========================================================
func lanzar_objeto(
	escena: PackedScene,
	marcador: Marker2D
) -> void:

	if escena == null:
		return

	if not combate_activo:
		return

	if marcador == null:
		return

	var obj = escena.instantiate()

	obj.global_position = marcador.global_position

	get_tree().current_scene.add_child(obj)
# =========================================================
# LANZAR HUEVO
# =========================================================
# =========================================================
# LANZAR HUEVO
# =========================================================

# =========================================================
# LANZAR HUEVO
# =========================================================

func lanzar_huevo() -> void:

	if huevo_escena == null:
		return

	if not combate_activo:
		return

	# =====================================================
	# BUSCAR JUGADOR
	# =====================================================

	var jugador = get_tree().get_first_node_in_group("player")

	if jugador == null:
		jugador = get_tree().get_first_node_in_group("jugador")

	if jugador == null:
		return


	# =====================================================
	# GUARDAR LA POSICIÓN DEL JUGADOR
	#
	# IMPORTANTE:
	# Esta posición se captura UNA SOLA VEZ.
	# El huevo no vuelve a consultar al jugador.
	# =====================================================

	var objetivo_final: Vector2 = jugador.global_position


	# =====================================================
	# CREAR HUEVO
	# =====================================================

	var huevo = huevo_escena.instantiate()

	if huevo == null:
		return


	# =====================================================
	# POSICIÓN INICIAL
	# =====================================================

	huevo.global_position = marcador_huevos.global_position


	# =====================================================
	# ASIGNAR OBJETIVO
	#
	# El objetivo queda fijo en la posición que tenía
	# el jugador cuando el jefe disparó.
	# =====================================================

	if "objetivo" in huevo:

		huevo.objetivo = objetivo_final


	# =====================================================
	# VELOCIDAD
	# =====================================================

	if "velocidad" in huevo:

		huevo.velocidad *= 1.35

	elif "speed" in huevo:

		huevo.speed *= 1.35

	elif "velocidad_caida" in huevo:

		huevo.velocidad_caida *= 1.35


	# =====================================================
	# AGREGAR
	# =====================================================

	get_tree().current_scene.add_child(huevo)

# =========================================================
# PARPADEO ROJO
# =========================================================

func activar_parpadeo_rojo() -> void:

	if en_parpadeo_invencible:
		return

	en_parpadeo_invencible = true


	# -------------------------------------------------------
	# ANIMACIÓN DE DAÑO
	# -------------------------------------------------------

	if anim != null:

		if anim.sprite_frames.has_animation(
			"recibe_daño"
		):

			anim.play("recibe_daño")


	# -------------------------------------------------------
	# PARPADEO
	# -------------------------------------------------------

	var tween := create_tween()

	for i in range(3):

		tween.tween_property(
			self,
			"modulate",
			Color(1.0, 0.15, 0.15),
			0.08
		)

		tween.tween_property(
			self,
			"modulate",
			Color.WHITE,
			0.08
		)

	await tween.finished


	if not is_inside_tree():
		return


	modulate = Color.WHITE

	en_parpadeo_invencible = false


	# -------------------------------------------------------
	# VOLVER A ANIMACIÓN
	# -------------------------------------------------------

	if combate_activo:

		if fase_ataque:

			anim.play("aleteo")

		else:

			anim.play("open")


# =========================================================
# DERROTAR JEFE
# =========================================================

func derrotar_jefe() -> void:

	if not combate_activo:
		return

	print("======================================")
	print("========= JEFE SELVA DERROTADO =======")
	print("======================================")


	combate_activo = false
	fase_ataque = false


	# -------------------------------------------------------
	# AVISAR AL HUD
	# -------------------------------------------------------

	jefe_derrotado.emit()


	# -------------------------------------------------------
	# ANIMACIÓN
	# -------------------------------------------------------

	if anim != null:

		anim.play("idle")


	# -------------------------------------------------------
	# ESPERAR
	# -------------------------------------------------------

	await get_tree().create_timer(
		0.2
	).timeout


	if is_instance_valid(self):

		queue_free()


# =========================================================
# DETENER COMBATE
# =========================================================

func detener_combate() -> void:

	print(
		"[JEFE SELVA] Combate detenido"
	)

	combate_activo = false
	fase_ataque = false

	if is_inside_tree():

		global_position = posicion_base


# =========================================================
# DETECTAR BALA
# =========================================================

func _on_area_2d_area_entered(
	area: Area2D
) -> void:

	if area == null:
		return

	if area.is_in_group("balas_jugador"):

		print(
			"[JEFE] Area2D detectó bala del jugador"
		)

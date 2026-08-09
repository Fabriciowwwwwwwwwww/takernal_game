
extends CharacterBody2D

# =========================================================
# SEÑALES
# =========================================================

signal golpe_recibido
signal jugador_muerto

# =========================================================
# DISPARO
# =========================================================

@export_category("Disparo")

@export var bala_escena: PackedScene

# Tiempo entre disparos
@export var tiempo_cooldown_disparo: float = 0.30

# =========================================================
# MOVIMIENTO
# =========================================================

@export_category("Movimiento")

@export var speed := 260.0

# Salto REAL solamente con Jump
@export var jump_force := -680.0

@export var gravity := 1250.0

# =========================================================
# MOVIMIENTO VERTICAL CON W
# =========================================================

@export_category("Esquiva Vertical")

# Velocidad al mantener W
@export var velocidad_w: float = 320.0

# Límites verticales
@export var limite_w_arriba: float = 120.0
@export var limite_w_abajo: float = 600.0

# =========================================================
# DASH
# =========================================================

@export_category("Dash")

# Muy rápido para esquivar
@export var dash_speed := 850.0

# Duración del dash
@export var dash_time := 0.20

# Tiempo para volver a usarlo
@export var dash_cooldown := 0.20

# =========================================================
# MODO DE JUGADOR
# =========================================================

@export_category("Jugador")

@export_enum("Jugador 1", "Jugador 2") var jugador := "Jugador 1"

# =========================================================
# ZONA DE NADO
# =========================================================

@export_category("Zona de Nado")

@export var modo_nado: bool = false

@export var limite_nado_arriba: float = 150.0

@export var limite_nado_abajo: float = 550.0

@export var velocidad_nado: float = 220.0

@export var puede_saltar_fuera_de_zona: bool = true

# =========================================================
# ACCIONES
# =========================================================

var left_action := ""
var right_action := ""
var jump_action := ""
var dash_action := ""
var shoot_action := ""


# =========================================================
# ESTADOS
# =========================================================

var is_dashing := false
var dash_timer := 0.0
var cooldown_timer := 0.0

var invencible := false

var is_charging := false

var puede_disparar := true

var direccion_mirada := 1

# =========================================================
# REFERENCIAS
# =========================================================

@onready var animacion: AnimatedSprite2D = $cuysin

@onready var punto_disparo: Marker2D = $Marker2D

@onready var colision: CollisionShape2D = $CollisionShape2D

@onready var salto_audio = $salto_audio

# =========================================================
# POSICIÓN DEL DISPARO
# =========================================================

var pos_inicial_marcador: float = 0.0


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	print(
		"[JUGADOR] Iniciado: ",
		jugador
	)

	# -------------------------------------------------------
	# MARCADOR DE DISPARO
	# -------------------------------------------------------

	if punto_disparo:

		pos_inicial_marcador = abs(
			punto_disparo.position.x
		)

	# -------------------------------------------------------
	# CONTROLES
	# -------------------------------------------------------

	if jugador == "Jugador 1":

		left_action = "p1_left"
		right_action = "p1_right"
		jump_action = "p1_jump"
		dash_action = "p1_dash"
		shoot_action = "p1_shoot"

		# W

	else:

		left_action = "p2_left"
		right_action = "p2_right"
		jump_action = "p2_jump"
		dash_action = "p2_dash"
		shoot_action = "p2_shoot"

		# W del jugador 2

	# -------------------------------------------------------
	# GRUPO DEL JUGADOR
	# -------------------------------------------------------

	if not is_in_group("jugador"):

		add_to_group("jugador")

	if not is_in_group("player"):

		add_to_group("player")


# =========================================================
# PHYSICS PROCESS
# =========================================================

func _physics_process(delta: float) -> void:

	if not is_inside_tree():

		return


	# =====================================================
	# DASH
	# =====================================================

	if is_dashing:

		procesar_dash(delta)

		move_and_slide()

		actualizar_animacion()

		return


	# =====================================================
	# GRAVEDAD
	# =====================================================

	if not is_on_floor():

		velocity.y += gravity * delta


	# =====================================================
	# CARGANDO DISPARO
	# =====================================================

	if is_charging:

		velocity.x = 0

	else:

		# =================================================
		# MOVIMIENTO HORIZONTAL
		# =================================================

		var dir := Input.get_axis(
			left_action,
			right_action
		)

		velocity.x = dir * speed


		# -------------------------------------------------
		# DIRECCIÓN
		# -------------------------------------------------

		if dir != 0:

			direccion_mirada = sign(dir)

			if direccion_mirada == 1:

				animacion.flip_h = false

				if punto_disparo:

					punto_disparo.position.x = (
						pos_inicial_marcador
					)

			else:

				animacion.flip_h = true

				if punto_disparo:

					punto_disparo.position.x = (
						-pos_inicial_marcador
					)


		# =================================================
		# W = SUBIR
		# =================================================




		# =================================================
		# SALTO REAL
		# =================================================

		if (
			Input.is_action_just_pressed(jump_action)
			and is_on_floor()
		):

			velocity.y = jump_force

			if salto_audio:

				salto_audio.play()


		# =================================================
		# DASH
		# =================================================

		cooldown_timer -= delta

		if (
			Input.is_action_just_pressed(dash_action)
			and cooldown_timer <= 0.0
		):

			comenzar_dash()


		# =================================================
		# DISPARO
		# =================================================

		if (
			Input.is_action_pressed(shoot_action)
			and puede_disparar
		):

			iniciar_ataque()


	# =====================================================
	# MOVER
	# =====================================================

	move_and_slide()


	# =====================================================
	# LIMITAR MOVIMIENTO VERTICAL
	# =====================================================

	limitar_movimiento_vertical()


	# =====================================================
	# ANIMACIÓN
	# =====================================================

	actualizar_animacion()


# =========================================================
# DASH
# =========================================================

func comenzar_dash() -> void:

	if is_dashing:

		return

	is_dashing = true

	dash_timer = dash_time

	cooldown_timer = dash_cooldown

	# -------------------------------------------------------
	# INVULNERABILIDAD DURANTE DASH
	# -------------------------------------------------------

	invencible = true

	print("[JUGADOR] DASH")


# =========================================================
# PROCESAR DASH
# =========================================================

func procesar_dash(delta: float) -> void:

	dash_timer -= delta

	# -------------------------------------------------------
	# MOVIMIENTO HORIZONTAL
	# -------------------------------------------------------

	velocity.x = (
		dash_speed
		* direccion_mirada
	)

	# -------------------------------------------------------
	# NO CAER DURANTE DASH
	# -------------------------------------------------------

	velocity.y = 0

	# -------------------------------------------------------
	# TERMINAR DASH
	# -------------------------------------------------------

	if dash_timer <= 0.0:

		is_dashing = false

		invencible = false

		print("[JUGADOR] DASH TERMINADO")


# =========================================================
# LIMITAR MOVIMIENTO VERTICAL
# =========================================================

func limitar_movimiento_vertical() -> void:

	var limite_arriba := limite_w_arriba
	var limite_abajo := limite_w_abajo

	# Si está configurado como zona de nado,
	# utilizamos esos límites.

	if modo_nado:

		limite_arriba = limite_nado_arriba
		limite_abajo = limite_nado_abajo


	# -------------------------------------------------------
	# LÍMITE SUPERIOR
	# -------------------------------------------------------

	if global_position.y < limite_arriba:

		global_position.y = limite_arriba

		if velocity.y < 0:

			velocity.y = 0


	# -------------------------------------------------------
	# LÍMITE INFERIOR
	# -------------------------------------------------------

	if global_position.y > limite_abajo:

		global_position.y = limite_abajo

		if velocity.y > 0:

			velocity.y = 0


# =========================================================
# NADO
# =========================================================

func procesar_nado(delta: float) -> void:

	# Ya no usamos movimiento automático.
	# El jugador controla la altura con W.

	pass


# =========================================================
# ANIMACIÓN
# =========================================================

func actualizar_animacion() -> void:

	if is_charging:

		return


	if is_dashing:

		animacion.play("dash")

		return


	if not is_on_floor():

		animacion.play("jump")

		return


	if velocity.x != 0:

		animacion.play("move")

		return


	animacion.play("idle")


# =========================================================
# INICIAR ATAQUE
# =========================================================

func iniciar_ataque() -> void:

	if not puede_disparar:

		return


	puede_disparar = false

	is_charging = true


	# -------------------------------------------------------
	# ANIMACIÓN DE CARGA
	# -------------------------------------------------------

	animacion.play("carga")


	# -------------------------------------------------------
	# PEQUEÑA CARGA
	# -------------------------------------------------------

	# Si quieres disparos todavía más rápidos,
	# esta espera se puede reducir.

	if animacion.is_playing():

		await animacion.animation_finished


	# -------------------------------------------------------
	# COMPROBAR
	# -------------------------------------------------------

	if not is_inside_tree():

		return


	# -------------------------------------------------------
	# DISPARAR
	# -------------------------------------------------------

	disparar()


	is_charging = false


	# -------------------------------------------------------
	# COOLDOWN
	# -------------------------------------------------------

	await get_tree().create_timer(
		tiempo_cooldown_disparo
	).timeout


	if is_inside_tree():

		puede_disparar = true


# =========================================================
# DISPARAR
# =========================================================

func disparar() -> void:

	if bala_escena == null:

		return


	var nueva_bala = (
		bala_escena.instantiate()
	)


	# -------------------------------------------------------
	# DIRECCIÓN
	# -------------------------------------------------------

	if "direccion" in nueva_bala:

		nueva_bala.direccion = (
			direccion_mirada
		)


	# -------------------------------------------------------
	# POSICIÓN
	# -------------------------------------------------------

	if punto_disparo:

		nueva_bala.global_position = (
			punto_disparo.global_position
		)

	else:

		nueva_bala.global_position = (
			global_position
		)


	# -------------------------------------------------------
	# AGREGAR
	# -------------------------------------------------------

	get_tree().current_scene.add_child(
		nueva_bala
	)


# =========================================================
# RECIBIR DAÑO
# =========================================================

func recibir_daño(
	cantidad: int = 1
) -> void:

	# -------------------------------------------------------
	# DASH = INVULNERABLE
	# -------------------------------------------------------

	if invencible:

		print(
			"[JUGADOR] DAÑO ESQUIVADO"
		)

		return


	print(
		"[JUGADOR] Golpe recibido: ",
		cantidad
	)


	# -------------------------------------------------------
	# AVISAR A LA UI
	# -------------------------------------------------------

	golpe_recibido.emit()


	# -------------------------------------------------------
	# PARPADEO
	# -------------------------------------------------------

	activar_parpadeo_rojo()


# =========================================================
# PARPADEO
# =========================================================

func activar_parpadeo_rojo() -> void:

	invencible = true


	var tween := create_tween()

	tween.set_loops(5)


	tween.tween_property(
		animacion,
		"modulate",
		Color(1, 0.2, 0.2),
		0.15
	)


	tween.tween_property(
		animacion,
		"modulate",
		Color(1, 1, 1),
		0.15
	)


	await tween.finished


	if not is_inside_tree():

		return


	animacion.modulate = Color(
		1,
		1,
		1
	)


	invencible = false


# =========================================================
# HACER INVULNERABLE
# =========================================================

func hacer_invulnerable(
	valor: bool
) -> void:

	invencible = valor


# =========================================================
# MORIR
# =========================================================

func morir() -> void:

	print(
		"[JUGADOR] Desactivado"
	)


	set_physics_process(false)

	velocity = Vector2.ZERO

	jugador_muerto.emit()


# =========================================================
# SOLTAR CUY Y CAER
# =========================================================

func soltar_cuy_y_caer() -> void:

	print(
		"[JUGADOR] Soltando cuy..."
	)


	set_physics_process(false)

	velocity = Vector2.ZERO


	if animacion:

		animacion.play("jump")


	# -------------------------------------------------------
	# CAÍDA
	# -------------------------------------------------------

	var tween := create_tween()


	tween.tween_property(
		self,
		"position:y",
		position.y + 120.0,
		1.0
	)


	await tween.finished

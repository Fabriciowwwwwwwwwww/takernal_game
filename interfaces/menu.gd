
extends Control


# =========================================================
# VARIABLES
# =========================================================

var tipo_boton: String = ""

var indice_boton: int = 0

var botones: Array[TextureButton] = []

var mouse_bloqueado: bool = false


# =========================================================
# REFERENCIAS
# =========================================================

@onready var musica: AudioStreamPlayer2D = $sonido_mundo
@onready var camion: AnimatedSprite2D = $carro
@onready var cuy_1: AnimatedSprite2D = $cuy1
@onready var cuy_2: AnimatedSprite2D = $cuy2

@onready var boton_single: TextureButton = $Control/Single_Player
@onready var boton_multi: TextureButton = $Control/Multi_Player
@onready var boton_quit: TextureButton = $Control/Quit
@onready var boton_creditos: TextureButton = $Control/creditos


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# =====================================================
	# DESBLOQUEAR TODO EL INPUT
	# =====================================================

	get_tree().paused = false
	get_tree().root.gui_disable_input = false

	process_mode = Node.PROCESS_MODE_ALWAYS

	PauseOverlay.puede_pausar = false


	# =====================================================
	# LISTA DE BOTONES
	# =====================================================

	botones = [
		boton_single,
		boton_multi,
		boton_quit,
		boton_creditos
	]


	# =====================================================
	# CONFIGURAR BOTONES
	# =====================================================

	configurar_botones()


	# =====================================================
	# MÚSICA
	# =====================================================

	if musica != null:
		musica.play()


	# =====================================================
	# ANIMACIONES
	# =====================================================

	if camion != null:
		camion.play("idle")

	if cuy_1 != null:
		cuy_1.play("idle")

	if cuy_2 != null:
		cuy_2.play("idle")


	# =====================================================
	# TRANSICIÓN
	# =====================================================

	configurar_transicion()

	$"Sombras_transición".show()

	$"Sombras_transición/AnimationPlayer".play("Sombra_off")


	# =====================================================
	# BOTÓN INICIAL
	# =====================================================

	indice_boton = 0

	seleccionar_boton(indice_boton)


	print("====================================")
	print("[MENU] Menú iniciado")
	print("[MENU] GUI INPUT: ", get_tree().root.gui_disable_input)
	print("[MENU] SINGLE FILTER: ", boton_single.mouse_filter)
	print("[MENU] MULTI FILTER: ", boton_multi.mouse_filter)
	print("[MENU] QUIT FILTER: ", boton_quit.mouse_filter)
	print("[MENU] CREDITOS FILTER: ", boton_creditos.mouse_filter)
	print("[MENU] Mouse habilitado")
	print("====================================")


# =========================================================
# CONFIGURAR BOTONES
# =========================================================

func configurar_botones() -> void:

	for boton in botones:

		if boton == null:
			continue

		# =================================================
		# MOUSE
		# =================================================

		boton.mouse_filter = Control.MOUSE_FILTER_STOP

		boton.disabled = false

		# =================================================
		# FOCO
		# =================================================

		boton.focus_mode = Control.FOCUS_ALL


	# =====================================================
	# LABELS
	# =====================================================

	var labels: Array[Control] = [
		$Control/Single_Player/Label,
		$Control/Multi_Player/Label,
		$Control/Quit/Label,
		$Control/creditos/Label
	]

	for label in labels:

		if label != null:
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE


# =========================================================
# SELECCIONAR BOTÓN
# =========================================================

func seleccionar_boton(indice: int) -> void:

	if botones.is_empty():
		return

	indice_boton = clampi(
		indice,
		0,
		botones.size() - 1
	)

	var boton: TextureButton = botones[indice_boton]

	if boton == null:
		return

	boton.grab_focus()

	print(
		"[MENU] Seleccionado: ",
		boton.name
	)


# =========================================================
# INPUT GLOBAL
#
# Aquí controlamos:
#
# ↑ / W = subir
# ↓ / S = bajar
# ENTER / ESPACIO = aceptar
#
# =========================================================

func _input(event: InputEvent) -> void:

	# =====================================================
	# EVITAR INPUT MIENTRAS CAMBIA DE ESCENA
	# =====================================================

	if mouse_bloqueado:
		return


	# =====================================================
	# ARRIBA
	#
	# FLECHA ARRIBA
	# W
	# =====================================================

	if event is InputEventKey:

		var tecla := event as InputEventKey

		if tecla.pressed and not tecla.echo:

			if tecla.keycode == KEY_UP \
			or tecla.keycode == KEY_W:

				indice_boton -= 1

				if indice_boton < 0:
					indice_boton = botones.size() - 1

				seleccionar_boton(indice_boton)

				get_viewport().set_input_as_handled()

				return


			# =================================================
			# ABAJO
			#
			# FLECHA ABAJO
			# S
			# =================================================

			if tecla.keycode == KEY_DOWN \
			or tecla.keycode == KEY_S:

				indice_boton += 1

				if indice_boton >= botones.size():
					indice_boton = 0

				seleccionar_boton(indice_boton)

				get_viewport().set_input_as_handled()

				return


			# =================================================
			# ACEPTAR
			#
			# ENTER
			# ESPACIO
			# =================================================

			if tecla.keycode == KEY_ENTER \
			or tecla.keycode == KEY_KP_ENTER \
			or tecla.keycode == KEY_SPACE:

				activar_boton_actual()

				get_viewport().set_input_as_handled()

				return


	# =====================================================
	# MOUSE
	# =====================================================

	if event is InputEventMouseButton:

		var mouse_event := event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT:

			if mouse_event.pressed:

				print(
					"[MOUSE] CLICK EN: ",
					mouse_event.position
				)

				var control := get_viewport().gui_get_hovered_control()

				if control != null:

					print(
						"[MOUSE] HOVER: ",
						control.get_path()
					)

					var boton := buscar_boton(control)

					if boton != null:

						print(
							"[MOUSE] BOTÓN ENCONTRADO: ",
							boton.name
						)

						boton.emit_signal("pressed")

						get_viewport().set_input_as_handled()

						return


				print("[MOUSE] NO ENCONTRÓ BOTÓN")


	# =====================================================
	# MOUSE MOVIÉNDOSE
	# =====================================================

	if event is InputEventMouseMotion:

		var control := get_viewport().gui_get_hovered_control()

		if control != null:

			var boton := buscar_boton(control)

			if boton != null:

				var nuevo_indice := botones.find(boton)

				if nuevo_indice != -1:

					if nuevo_indice != indice_boton:

						indice_boton = nuevo_indice

						boton.grab_focus()

						print(
							"[MOUSE] Hover: ",
							boton.name
						)


# =========================================================
# BUSCAR BOTÓN PADRE
# =========================================================

func buscar_boton(control: Control) -> TextureButton:

	var nodo: Node = control

	while nodo != null:

		if nodo is TextureButton:

			var boton := nodo as TextureButton

			if botones.has(boton):

				return boton

		nodo = nodo.get_parent()

	return null


# =========================================================
# ACTIVAR BOTÓN ACTUAL
# =========================================================

func activar_boton_actual() -> void:

	if indice_boton < 0:
		return

	if indice_boton >= botones.size():
		return

	var boton: TextureButton = botones[indice_boton]

	if boton == null:
		return

	if boton.disabled:
		return

	print(
		"[MENU] ACTIVANDO: ",
		boton.name
	)

	boton.emit_signal("pressed")


# =========================================================
# TRANSICIÓN
# =========================================================

func configurar_transicion() -> void:

	desactivar_mouse_recursivo(
		$"Sombras_transición"
	)


# =========================================================
# DESACTIVAR MOUSE DE TRANSICIÓN
# =========================================================

func desactivar_mouse_recursivo(nodo: Node) -> void:

	if nodo is Control:

		var control: Control = nodo

		control.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for hijo: Node in nodo.get_children():

		desactivar_mouse_recursivo(hijo)


# =========================================================
# INICIAR TRANSICIÓN
# =========================================================

func iniciar_transicion() -> void:

	mouse_bloqueado = true

	$"Sombras_transición".show()

	$"Sombras_transición/Sombra_time".start()

	$"Sombras_transición/AnimationPlayer".play("Sombra_on")


# =========================================================
# SINGLE PLAYER
# =========================================================

func _on_single_player_pressed() -> void:

	if mouse_bloqueado:
		return

	print("[MENU] CLICK SINGLE PLAYER")

	GameManager.modo_juego = GameManager.ModoJuego.SINGLE

	tipo_boton = "start"

	iniciar_transicion()


# =========================================================
# MULTIPLAYER
# =========================================================

func _on_multi_player_pressed() -> void:

	if mouse_bloqueado:
		return

	print("[MENU] CLICK MULTIPLAYER")

	GameManager.modo_juego = GameManager.ModoJuego.COOP

	tipo_boton = "start"

	iniciar_transicion()


# =========================================================
# QUIT
# =========================================================

func _on_quit_pressed() -> void:

	if mouse_bloqueado:
		return

	print("[MENU] CLICK QUIT")

	mouse_bloqueado = true

	get_tree().quit()


# =========================================================
# CREDITOS
# =========================================================

func _on_creditos_pressed() -> void:

	if mouse_bloqueado:
		return

	print("[MENU] CLICK CREDITOS")

	tipo_boton = "creditos"

	iniciar_transicion()


# =========================================================
# FIN DE TRANSICIÓN
# =========================================================

func _on_sombra_time_timeout() -> void:

	print("[MENU] FIN DE TRANSICIÓN")

	if tipo_boton == "start":

		get_tree().change_scene_to_file(
			"res://visual/visual.tscn"
		)

	elif tipo_boton == "creditos":

		get_tree().change_scene_to_file(
			"res://scenes/creditos.tscn"
		)


# =========================================================
# DEBUG
# =========================================================

func _process(_delta: float) -> void:

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):

		var posicion := get_viewport().get_mouse_position()

		print(
			"[MOUSE] Posición: ",
			posicion
		)

		var control := get_viewport().gui_get_hovered_control()

		if control != null:

			print(
				"[MOUSE] Control detectado: ",
				control.get_path()
			)

		else:

			print(
				"[MOUSE] NO HAY CONTROL DETECTADO"
			)

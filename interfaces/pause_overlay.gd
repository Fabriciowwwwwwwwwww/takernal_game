extends CanvasLayer

# =========================================================

# PAUSE MENU - AUTOLOAD

# =========================================================

@onready var pause_menu: Control = $PauseContainer/RightPanel
@onready var resume_button: Button = $PauseContainer/RightPanel/VBoxContainer/ResumeButton

@export_file("*.tscn") var menu_scene: String

# Nodo donde están los adornos animados

@onready var adorno: Node2D = $Adorno

# =========================================================

# ESTADO

# =========================================================

var puede_pausar: bool = true
var cambiando_escena: bool = false

# =========================================================

# READY

# =========================================================

func _ready() -> void:

	# El menú debe funcionar incluso cuando el juego está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

	visible = false

	if pause_menu:
		pause_menu.hide()

	print("[PAUSA] Autoload iniciado")


# =========================================================

# INPUT DE PAUSA

# =========================================================

func _unhandled_input(event: InputEvent) -> void:


# Si estamos cambiando de escena no hacemos nada
	if cambiando_escena:
		return

	# Si no se permite pausar
	if not puede_pausar:
		return

	# Detectar botón de pausa
	if event.is_action_pressed("pause"):

		toggle_pause()

		get_viewport().set_input_as_handled()

# =========================================================

# PAUSAR / REANUDAR

# =========================================================

func toggle_pause() -> void:

# No permitir pausa mientras cambia de escena
	if cambiando_escena:
		return

	var nuevo_estado: bool = not get_tree().paused

	# =====================================================
	# PAUSAR
	# =====================================================

	if nuevo_estado:

		print("[PAUSA] JUEGO PAUSADO")

		get_tree().paused = true

		visible = true

		if pause_menu:
			pause_menu.show()

		activar_adornos()

		if resume_button:
			resume_button.grab_focus()

	# =====================================================
	# REANUDAR
	# =====================================================

	else:

		print("[PAUSA] JUEGO REANUDADO")

		get_tree().paused = false

		visible = false

		if pause_menu:
			pause_menu.hide()


# =========================================================

# ACTIVAR ANIMACIONES DEL ADORNO

# =========================================================

func activar_adornos() -> void:


	if adorno == null:
		return

	var sprites = adorno.find_children(
		"*",
		"AnimatedSprite2D",
		true
	)

	for sprite in sprites:

		if is_instance_valid(sprite):

			sprite.play("idle")


# =========================================================

# PERMITIR / BLOQUEAR PAUSA

# =========================================================

func activar_pausa(valor: bool) -> void:


	puede_pausar = valor

	print(
		"[PAUSA] Puede pausar: ",
		puede_pausar
	)


# =========================================================

# BOTÓN RESUME

# =========================================================

func _on_resume_button_pressed() -> void:


	print("[PAUSA] RESUME")

	if cambiando_escena:
		return

	# Quitar pausa directamente
	get_tree().paused = false

	# Ocultar menú
	visible = false

	if pause_menu:
		pause_menu.hide()


# =========================================================

# BOTÓN RETRY

# =========================================================

func _on_retry_button_pressed() -> void:


	print("[PAUSA] REINICIAR NIVEL")

	if cambiando_escena:
		return

	cambiando_escena = true

	# IMPORTANTE:
	# Primero quitar pausa
	get_tree().paused = false

	# Ocultar menú
	visible = false

	if pause_menu:
		pause_menu.hide()

	# Esperar al siguiente frame
	await get_tree().process_frame

	# Recargar escena
	get_tree().reload_current_scene()

# =========================================================

# BOTÓN EXIT / VOLVER AL MENÚ

# =========================================================

func _on_title_screen_button_pressed() -> void:


	print("======================================")
	print("[PAUSA] EXIT PRESIONADO")
	print("======================================")

	# ---------------------------------------------------------
	# EVITAR DOBLE EJECUCIÓN
	# ---------------------------------------------------------

	if cambiando_escena:
		print("[PAUSA] Ya se está cambiando de escena")

		return

	cambiando_escena = true

	# ---------------------------------------------------------
	# COMPROBAR ESCENA DEL MENÚ
	# ---------------------------------------------------------

	if menu_scene.is_empty():

		print(
			"[PAUSA] ERROR: menu_scene NO está asignada"
		)

		cambiando_escena = false

		return

	print(
		"[PAUSA] Escena destino: ",
		menu_scene
	)

	# ---------------------------------------------------------
	# QUITAR PAUSA
	# ---------------------------------------------------------

	get_tree().paused = false

	print("[PAUSA] Pausa desactivada")

	# ---------------------------------------------------------
	# OCULTAR PAUSE MENU
	# ---------------------------------------------------------

	visible = false

	if pause_menu:
		pause_menu.hide()

	# ---------------------------------------------------------
	# QUITAR EL FOCO DEL BOTÓN
	# ---------------------------------------------------------

	var foco_actual := get_viewport().gui_get_focus_owner()

	if foco_actual != null:

		foco_actual.release_focus()

	# ---------------------------------------------------------
	# ESPERAR UN FRAME
	# ---------------------------------------------------------

	await get_tree().process_frame

	# ---------------------------------------------------------
	# CAMBIAR DE ESCENA
	# ---------------------------------------------------------

	print(
		"[PAUSA] Cambiando al menú..."
	)

	SceneManager.change_scene(
		self,
		menu_scene
	)



# =========================================================

# FORZAR CIERRE DEL PAUSE MENU

# =========================================================

func cerrar_pausa() -> void:


	get_tree().paused = false

	visible = false

	if pause_menu:
		pause_menu.hide()

# =========================================================

# FORZAR PAUSA

# =========================================================

func pausar() -> void:


	if cambiando_escena:
		return

	get_tree().paused = true

	visible = true

	if pause_menu:
		pause_menu.show()

	activar_adornos()


# =========================================================

# FORZAR REANUDACIÓN

# =========================================================

func reanudar() -> void:


	get_tree().paused = false

	visible = false

	if pause_menu:
		pause_menu.hide()



# =========================================================

# BLOQUEAR PAUSA

# =========================================================

func bloquear_pausa() -> void:


	puede_pausar = false

	print("[PAUSA] PAUSA BLOQUEADA")

# =========================================================

# PERMITIR PAUSA

# =========================================================

func permitir_pausa() -> void:


	puede_pausar = true

	print("[PAUSA] PAUSA PERMITIDA")

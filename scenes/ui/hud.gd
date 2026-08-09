extends CanvasLayer
var cebolla_llamada := false
var cafe_llamado := false
@onready var corazones = [
	$Hearts/heart1,
	$Hearts/heart2,
	$Hearts/heart3,
	$Hearts/heart4,
	$Hearts/heart5
]
var puzzle_llamado := false

@export_file("*.tscn") var puzzle_scene: String
@export_file("*.tscn") var escena_game_over
var vidas := 5

@onready var barra = $ProgressBar
var probabilidad_pedido: Dictionary[String, float] = {
	"camote": 0.80,
	"cebolla": 0.75,
	"sal": 0.55,
	"limon": 0.60,
	"pan": 0.35,
	"chicharron": 0.55
}

# Cantidades necesarias (Panel2)
var objetivo_ingredientes = {
	"camote": 0,
	"cebolla": 0,
	"sal": 0,
	"limon": 0,
	"pan": 0,
	"chicharron": 0
}


# Cantidades conseguidas (Panel3)
var ingredientes_conseguidos = {
	"camote": 0,
	"cebolla": 0,
	"sal": 0,
	"limon": 0,
	"pan": 0,
	"chicharron": 0
}


var progreso := 0


func _ready():

	generar_objetivos()
	actualizar_panel3()

	for corazon in corazones:
		corazon.visible = true
		corazon.play("idle")
func perder_vida():

	if vidas <= 0:
		return

	# Corazón que se rompe (empieza por el de la derecha)
	var indice := vidas - 1

	vidas -= 1

	if indice >= 0 and indice < corazones.size():

		var corazon: AnimatedSprite2D = corazones[indice]

		corazon.play("romper")

		await corazon.animation_finished

		corazon.visible = false

	if vidas <= 0:
		mostrar_game_over()
func mostrar_game_over():

	get_tree().paused = false

	if escena_game_over != "":

		var escena_actual := get_tree().current_scene.scene_file_path

		print("Escena actual:", escena_actual)

		var game_over = load(escena_game_over).instantiate()

		game_over.configurar_escena_anterior(escena_actual)

		get_tree().current_scene.add_child(game_over)

	else:

		print("NO HAY ESCENA GAME OVER ASIGNADA")

func actualizar_progreso():

	var total_necesario := 0
	var total_conseguido := 0


	for ingrediente in objetivo_ingredientes:

		total_necesario += objetivo_ingredientes[ingrediente]
		total_conseguido += ingredientes_conseguidos[ingrediente]


	if total_necesario > 0:

		progreso = (
			float(total_conseguido) /
			float(total_necesario)
		) * 100.0

	else:

		progreso = 0


	barra.value = progreso


	# ==========================================
	# EVENTO CEBOLLAS - 65%
	# ==========================================

	if progreso >= 65.0 and not cebolla_llamada:

		cebolla_llamada = true

		var spawner = get_tree().current_scene.get_node_or_null(
			"cebollaSpawner2"
		)


		if spawner:

			print("LLAMANDO EVENTO CEBOLLAS")
			spawner.iniciar_evento_cebollas()

		else:

			print("NO EXISTE CEBOLLA SPAWNER")


	# ==========================================
	# ATAQUE CAFÉ - 25%
	# ==========================================

	if progreso >= 25.0 and not cafe_llamado:

		cafe_llamado = true

		var cafe = $"../cafe_estado/Cafe"


		if cafe:

			cafe._ataque()


	# ==========================================
	# PUZZLE - 100%
	# ==========================================

	if progreso >= 100.0 and not puzzle_llamado:

		puzzle_llamado = true

		print("PROGRESO AL 100%")
		print("CAMBIANDO A PUZZLE...")

		if puzzle_scene:

			SceneManager.change_scene(
				self,
				puzzle_scene
			)

		else:

			print("ERROR: No se asignó puzzle_scene")


func generar_objetivos():

	for ingrediente in objetivo_ingredientes:
		
		var cantidad := 0
		
		# Ingredientes más comunes tendrán más cantidad
		var prob := probabilidad_pedido[ingrediente]

		for i in range(30):
			
			if randf() <= prob:
				cantidad += 1

		# mínimo 1, máximo 12
		objetivo_ingredientes[ingrediente] = clamp(cantidad, 1, 30)



	$Panel2/HBoxContainer/ingre1/camote_label.text = str(objetivo_ingredientes["camote"])
	$Panel2/HBoxContainer/ingre2/cebolla_label.text = str(objetivo_ingredientes["cebolla"])
	$Panel2/HBoxContainer/ingre3/sal_label.text = str(objetivo_ingredientes["sal"])
	$Panel2/HBoxContainer/ingre4/Limon_label.text = str(objetivo_ingredientes["limon"])
	$Panel2/HBoxContainer/ingre5/pan_label.text = str(objetivo_ingredientes["pan"])
	$Panel2/HBoxContainer/ingre6/chicharron_label.text = str(objetivo_ingredientes["chicharron"])





# ============================
# SUMAR INGREDIENTE CONSEGUIDO
# ============================

func agregar_ingrediente(nombre:String):

	if nombre in ingredientes_conseguidos:
		ingredientes_conseguidos[nombre] += 1

	print("INGREDIENTE:", nombre)

	actualizar_panel3()
	actualizar_progreso()


func actualizar_panel3():

	$Panel3/HBoxContainer/ingre1/camote_label.text = str(ingredientes_conseguidos["camote"])
	$Panel3/HBoxContainer/ingre2/cebolla_label.text = str(ingredientes_conseguidos["cebolla"])
	$Panel3/HBoxContainer/ingre3/sal_label.text = str(ingredientes_conseguidos["sal"])
	$Panel3/HBoxContainer/ingre4/Limon_label.text = str(ingredientes_conseguidos["limon"])
	$Panel3/HBoxContainer/ingre5/pan_label.text = str(ingredientes_conseguidos["pan"])
	$Panel3/HBoxContainer/ingre6/chicharron_label.text = str(ingredientes_conseguidos["chicharron"])




func actualizar_corazones():

	for i in corazones.size():

		if i < vidas:

			if corazones[i].animation != "idle":
				corazones[i].play("idle")

		else:

			if corazones[i].animation != "romper":
				corazones[i].play("romper")
func elegir_ingrediente_pedido() -> String:

	var total := 0.0

	for ingrediente in probabilidad_pedido:
		total += probabilidad_pedido[ingrediente]


	var random := randf() * total

	var acumulado := 0.0


	for ingrediente in probabilidad_pedido:

		acumulado += probabilidad_pedido[ingrediente]

		if random <= acumulado:
			return ingrediente


	return "camote"

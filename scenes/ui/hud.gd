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

var vidas := 5

@onready var barra = $ProgressBar


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


func perder_vida():
	vidas -= 1
	actualizar_corazones()



func actualizar_progreso():

	var total_necesario := 0
	var total_conseguido := 0


	for ingrediente in objetivo_ingredientes:
		total_necesario += objetivo_ingredientes[ingrediente]
		total_conseguido += ingredientes_conseguidos[ingrediente]


	if total_necesario > 0:
		progreso = (float(total_conseguido) / float(total_necesario)) * 100.0
	else:
		progreso = 0



	barra.value = progreso

	if progreso >= 50 and not cebolla_llamada:

		cebolla_llamada = true

		var spawner = get_tree().current_scene.get_node("cebollaSpawner2")


		if spawner:

			print("LLAMANDO EVENTO CEBOLLAS")
			spawner.iniciar_evento_cebollas()

		else:

			print("NO EXISTE CEBOLLA SPAWNER")

	if progreso >= 75 and not cafe_llamado:

		cafe_llamado = true

		var cafe = $"../cafe_estado/Cafe"

		if cafe:
			cafe._ataque()

# ============================
# GENERAR PEDIDO ALEATORIO
# ============================

func generar_objetivos():

	for ingrediente in objetivo_ingredientes:
		objetivo_ingredientes[ingrediente] = randi_range(10,15)


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
		corazones[i].visible = i < vidas

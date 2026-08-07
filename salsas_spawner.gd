extends Node2D

@export_category("Salsas")
@export var armas: Array[NodePath]

@export_category("Tiempos de los Patrones")
@export var tiempo_entre_patrones: float = 2.0 # Tiempo de respiro ANTES de que empiece otro patrón
@export var tiempo_cascada: float = 0.6 # Tiempo entre el disparo de una salsa y la siguiente
@export var tiempo_pares_impares: float = 1.0 # Tiempo entre el grupo 1 y el grupo 2
@export var tiempo_extremos: float = 0.8 # Tiempo entre los disparos que vienen de las esquinas

var salsas_nodos: Array[Node] = []

func _ready():
	# Guardamos las referencias a los nodos de las salsas
	for path in armas:
		var nodo = get_node(path)
		if nodo:
			salsas_nodos.append(nodo)
			
	# Iniciamos la coreografía de ataques
	if salsas_nodos.size() > 0:
		iniciar_patrones()

func iniciar_patrones():
	while true:
		var patron_elegido = randi() % 3
		
		match patron_elegido:
			0:
				await patron_cascada()
			1:
				await patron_pares_impares()
			2:
				await patron_extremos_al_centro()
				
		# Descanso general antes de que el controlador elija el siguiente ataque
		await get_tree().create_timer(tiempo_entre_patrones).timeout

# --- PATRÓN 1: Una por una en orden ---
func patron_cascada():
	for salsa in salsas_nodos:
		salsa.disparar()
		await get_tree().create_timer(tiempo_cascada).timeout

# --- PATRÓN 2: Primero unas, luego las intercaladas ---
func patron_pares_impares():
	# Disparan las posiciones 0, 2, 4...
	for i in range(0, salsas_nodos.size(), 2):
		salsas_nodos[i].disparar()
		
	await get_tree().create_timer(tiempo_pares_impares).timeout
	
	# Disparan las posiciones 1, 3, 5...
	for i in range(1, salsas_nodos.size(), 2):
		salsas_nodos[i].disparar()

# --- PATRÓN 3: Desde las esquinas hacia adentro ---
func patron_extremos_al_centro():
	var total = salsas_nodos.size()
	var mitad = int(total / 2.0)
	
	for i in range(mitad):
		salsas_nodos[i].disparar() # Dispara la de la izquierda
		salsas_nodos[total - 1 - i].disparar() # Dispara su espejo a la derecha
		await get_tree().create_timer(tiempo_extremos).timeout

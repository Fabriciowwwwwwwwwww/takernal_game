extends Node2D

@export var chifle_1_escena: PackedScene
@export var chifle_2_escena: PackedScene
@export var huevo_escena: PackedScene

@export var vida_maxima: int = 50
var vida_actual: int

var invulnerable_por_fase := true
var en_parpadeo_invencible := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var marcador_chifles: Marker2D = $chifles
@onready var marcador_huevos: Marker2D = $Marker2D

func _ready() -> void:
	randomize()
	vida_actual = vida_maxima
	iniciar_patron()

func iniciar_patron() -> void:
	await get_tree().process_frame
	
	while is_inside_tree():
		invulnerable_por_fase = true
		
		anim.play("idle")
		await get_tree().create_timer(2.0).timeout
		
		anim.play("aleteo")
		var tiempo_pasado := 0.0
		
		while tiempo_pasado < 30.0:
			var tipo_disparo = randi() % 2
			var tiempo_espera := 0.0
			
			if tipo_disparo == 0:
				lanzar_objeto(chifle_1_escena)
				tiempo_espera = 3.5
			else:
				lanzar_objeto(chifle_2_escena)
				tiempo_espera = 5.5
				
			await get_tree().create_timer(tiempo_espera).timeout
			tiempo_pasado += tiempo_espera
			
		anim.play("idle")
		await get_tree().create_timer(2.0).timeout
		
		invulnerable_por_fase = false
		anim.play("open")
		
		for i in range(3):
			await get_tree().create_timer(0.5).timeout
			lanzar_huevo()
			await get_tree().create_timer(1.0).timeout
			
		await get_tree().create_timer(5.0).timeout

func lanzar_objeto(escena: PackedScene) -> void:
	if escena == null:
		return
		
	var obj = escena.instantiate()
	obj.global_position = marcador_chifles.global_position
	get_tree().current_scene.add_child(obj)

func lanzar_huevo() -> void:
	if huevo_escena == null:
		return
		
	var jugador = get_tree().get_first_node_in_group("player")
	
	if jugador:
		var huevo = huevo_escena.instantiate()
		huevo.global_position = marcador_huevos.global_position
		
		if "objetivo" in huevo:
			huevo.objetivo = jugador.global_position
			
		get_tree().current_scene.add_child(huevo)

func recibir_daño(cantidad: int) -> void:
	if invulnerable_por_fase or en_parpadeo_invencible:
		return
		
	vida_actual -= cantidad
	
	if vida_actual <= 0:
		queue_free()
	else:
		activar_parpadeo_rojo()

func activar_parpadeo_rojo() -> void:
	en_parpadeo_invencible = true
	anim.play("recibe_daño")
	
	var tween = create_tween()
	tween.set_loops(5)
	tween.tween_property(self, "modulate", Color(1, 0.2, 0.2), 0.15)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.15)
	
	await tween.finished
	modulate = Color(1, 1, 1)
	en_parpadeo_invencible = false
	
	if not invulnerable_por_fase:
		anim.play("open")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("balas_jugador"):
		recibir_daño(1)

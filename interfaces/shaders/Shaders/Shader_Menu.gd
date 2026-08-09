extends Control

const TRANSITION_DURATION: float = 0.38

var transition_progress: float = 1.0


func _ready() -> void:

	var mat: ShaderMaterial = get_material()

	if mat:

		mat.set_shader_parameter(
			"screen_size",
			get_viewport().get_visible_rect().size
		)

	_simple_menu_transition()


func _simple_menu_transition() -> void:

	var next_progress: float

	if transition_progress == 0.0:
		next_progress = 1.0
	else:
		next_progress = 0.0


	var tween := create_tween()

	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_method(
		_change_transition_progress,
		transition_progress,
		next_progress,
		TRANSITION_DURATION
	)

	transition_progress = next_progress


func _change_transition_progress(progress: float) -> void:

	var mat: ShaderMaterial = get_material()

	if mat:

		mat.set_shader_parameter(
			"transition_progress",
			progress
		)

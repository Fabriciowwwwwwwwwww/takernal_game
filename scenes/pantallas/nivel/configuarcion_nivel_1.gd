extends Node2D


@onready var musica: AudioStreamPlayer2D = $sonido_mundo

func _ready():
	musica.play()

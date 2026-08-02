extends Control

@onready var speaker_label: Label = $speakerName/Label
@onready var dialogue_label: RichTextLabel = $dialog_line/RichTextLabel


var speakerName:String:
	set(value):
		speaker_label.text = value


var dialog_line:String:
	set(value):
		dialogue_label.text = value

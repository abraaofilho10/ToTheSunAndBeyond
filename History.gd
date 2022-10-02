extends Control

export var history: String setget set_history

onready var history_node = $RichTextLabel

func set_history(value):
	history = value
	if is_instance_valid(history_node):
		history_node.bbcode_text = history

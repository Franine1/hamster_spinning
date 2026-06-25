class_name  TooltipBox
extends PanelContainer


@onready var textbox: RichTextLabel = %RichTextLabel
var my_label: String = ""
var do_relabel: bool = false


func _ready() -> void:
	if do_relabel:
		label_change()


func relabel(input: String) -> void:
	my_label = input
	do_relabel = true
	if is_node_ready():
		label_change()


func label_change() -> void:
	textbox.text = my_label
	do_relabel = false

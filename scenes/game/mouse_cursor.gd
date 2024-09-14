extends Node2D

@onready var label_1: Label = %MouseLabel1
@onready var label_2: Label = %MouseLabel2

func _ready():
	label_1.text = ""
	label_2.text = ""

func _process(_delta):
	position = get_global_mouse_position()

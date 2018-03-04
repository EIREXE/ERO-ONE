extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var parameter
var parameter_name
var item_path

onready var editor_main = get_node("../../../../../../../../../")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func load_parameter(item_path, parameter_name):
	
	self.item_path = item_path
	self.parameter_name = parameter_name
	var item_data = editor_main.character.get_item_data(item_path)
	self.parameter = item_data["parameters"][parameter_name]

	$Label.text = parameter["name"]
	$ColorPickerButton.color = str2var(parameter["default"])

func color_changed(color):
	editor_main.set_item_parameter(item_path, parameter_name, color)

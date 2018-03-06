extends HSplitContainer

var parameter
var parameter_name
var character
var item_path
onready var editor_main = get_node("../../../../../../../../../")
onready var label = get_node("HBoxContainer/Label")
onready var color_picker = get_node("HBoxContainer2/ColorPickerButton")

func load_parameter(character, parameter_name):
	
	self.character = character
	self.parameter_name = parameter_name
	self.item_path = character.get_item_path_from_scene(character.body)
	var item_data = editor_main.character.get_item_data(item_path)
	self.parameter = item_data["parameters"][parameter_name]
	label.text = parameter["name"]
	color_picker.color = parameter["value"]

func color_changed(color):
	editor_main.set_item_parameter(item_path, parameter_name, color)

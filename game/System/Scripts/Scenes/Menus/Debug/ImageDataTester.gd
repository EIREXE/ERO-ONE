extends CanvasLayer

onready var text_editor = get_node("Panel/HSplitContainer/TextEdit")
onready var texture_rect = get_node("Panel/HSplitContainer/VBoxContainer/TextureRect")

onready var save_button = get_node("Panel/HSplitContainer/VBoxContainer/SaveButton")

var current_file_path

func _ready():
	pass
	
	
func open_file(path):
	var image_data = EROContent.load_image_data(path)
	text_editor.text = image_data
	var image_texture = load(path)
	texture_rect.texture = image_texture
	current_file_path = path
	save_button.disabled = false

func save_image():
	EROContent.save_image_data(current_file_path, text_editor.text)
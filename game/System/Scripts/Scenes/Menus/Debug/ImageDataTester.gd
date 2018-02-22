extends CanvasLayer

onready var text_editor = get_node("Panel/HSplitContainer/TextEdit")
onready var texture_rect = get_node("Panel/HSplitContainer/VBoxContainer/TextureRect")

onready var save_button = get_node("Panel/HSplitContainer/VBoxContainer/SaveButton")

onready var characters_container = get_node("Panel/HSplitContainer/VBoxContainer/CharactersContainer")

var current_file_path

func _ready():
	var image_texture = load("res://Content/ModTest/modtest.png")
	texture_rect.texture = image_texture
	var characters = EROContent.get_characters()
	for character in characters:
		print(character["image_path"])
		var button = Button.new()
		button.text = character["name"]
		button.connect("pressed", self, "open_file", [character["image_path"]])
		characters_container.add_child(button)
	
func open_file(path):
	#var image_data = EROContent.load_image_data(path)
	#text_editor.text = image_data
	var image_texture = load(path)
	texture_rect.texture = image_texture
	current_file_path = path
	save_button.disabled = false

func save_image():
	EROContent.save_image_data(current_file_path, text_editor.text)
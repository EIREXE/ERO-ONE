extends CanvasLayer

onready var text_editor = get_node("Panel/HSplitContainer/HSplitContainer/TextEdit")
onready var texture_rect = get_node("Panel/HSplitContainer/HSplitContainer/TextureRect")

onready var save_button = get_node("Panel/HSplitContainer/VBoxContainer/SaveButton")

onready var characters_container = get_node("Panel/HSplitContainer/VBoxContainer/CharactersContainer")

const JSONBeautifier = preload("res://System/Scenes/Utils/JSONBeautifier.gd")

var current_file_path

var image


func _ready():
	var image_texture = load("res://Content/ModTest/modtest.png")
	texture_rect.texture = image_texture
	reload_characters()
	
func reload_characters():
	var characters = EROContent.get_characters()
	for child in characters_container.get_children():
		child.queue_free()
	
	
	for character in characters:
		print(character["image_path"])
		var button = Button.new()
		button.text = character["name"]
		button.connect("pressed", self, "open_file", [character["image_path"]])
		characters_container.add_child(button)
	
func open_file(path):

	image = Image.new()
	image.load(path)

	current_file_path = path

	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	texture_rect.texture = image_texture
	save_button.disabled = false
	text_editor.text = JSONBeautifier.beautify_json(EROSteganography.get_steganographic_data_from_image(image))

func save_image():
	image = EROContent.save_image_data(image, text_editor.text)
	image.save_png(current_file_path)
	reload_characters()
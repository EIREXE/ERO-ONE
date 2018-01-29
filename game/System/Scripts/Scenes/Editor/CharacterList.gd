extends GridContainer

onready var editor_main = get_node("../../../..")

const THUMBNAIL_SIZE = Vector2(128,128)

func _ready():
	init_character_list()

func init_character_list():
	var characters = EROContent.get_characters()
	for character in characters:
		add_character(character, character["image_path"])
		
func add_character(character_data, image_path):
	var v_container = VBoxContainer.new()
	var label = Label.new()
	var button = Button.new()
	
	button.connect("pressed", editor_main, "load_character_from_data", [character_data])
	button.flat = true
	var button_texture = ImageTexture.new()
	button_texture.load(image_path)


	button_texture.set_size_override(THUMBNAIL_SIZE)
	
	button.icon = button_texture
	
	v_container.alignment = v_container.ALIGN_CENTER
	label.align = label.ALIGN_CENTER
	
	label.text = character_data["name"]
	button.hint_tooltip = character_data["name"]
	v_container.add_child(button)
	v_container.add_child(label)
	add_child(v_container)
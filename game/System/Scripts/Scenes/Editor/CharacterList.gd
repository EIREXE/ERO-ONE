extends Panel

onready var editor_main = get_node("../../../")

onready var ITEM_LIST = get_node("VBoxContainer/ItemList")
onready var CARD_PREVIEW = get_node("../CardPreview")
const THUMBNAIL_SIZE = Vector2(128,128)

func _ready():
	init_character_list()
	hide_character_preview()

func init_character_list():
	ITEM_LIST.clear()
	var characters = EROContent.get_characters()
	for character in characters:
		add_character(character, character["image_path"])
		
func add_character(character_data, image_path):

	var preview_image = ImageTexture.new()
	preview_image.load(image_path)
	preview_image.set_size_override(THUMBNAIL_SIZE)
	
	ITEM_LIST.add_item(character_data["name"])
	
	var metadata = {
		"character_data": character_data,
		"preview_image": preview_image
	}
	
	var item = ITEM_LIST.get_item_count()-1
	
	ITEM_LIST.set_item_metadata(item, metadata)
	ITEM_LIST.set_item_tooltip_enabled(item, false)
	
func delete_character():
	if ITEM_LIST.get_selected_items():
		var item = ITEM_LIST.get_selected_items()[0]
		EROContent.delete_character(ITEM_LIST.get_item_metadata(item)["character_data"])
		init_character_list()
	
func show_character_preview(ev):
	if ev is InputEventMouseMotion:
		var item = ITEM_LIST.get_item_at_position(ITEM_LIST.get_local_mouse_position(), true)
		# -1 means no item was found
		if item != -1:
			var metadata = ITEM_LIST.get_item_metadata(item)
			CARD_PREVIEW.texture = metadata["preview_image"]
			CARD_PREVIEW.show()
		else:
			hide_character_preview()

func hide_character_preview():
	CARD_PREVIEW.hide()

func select_character():
	if ITEM_LIST.get_selected_items():
		var item = ITEM_LIST.get_selected_items()[0]
		editor_main.load_character_from_data(ITEM_LIST.get_item_metadata(item)["character_data"])

func save_button_pressed():
	editor_main.save_current_character()
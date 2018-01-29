extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var TABS_NODE = get_node("EditorUI/Panel/VBoxContainer/TabContainer")
onready var character = get_node("EROCharacter")
onready var TAB_TEMPLATE = get_node("TabTemplate")
onready var CLOTHING_VIEWER_CONTAINER = get_node("EditorUI/ClothingViewer/ClothingViewerButtonContainer")
onready var CLOTHING_VIEWER = get_node("EditorUI/ClothingViewer")
onready var characters_container_panel = get_node("EditorUI/Panel2")
onready var characters_container = get_node("EditorUI/Panel2/ScrollContainer/CharacterListContainer")
onready var overwrite_confirmation_dialog = get_node("EditorUI/OverwriteConfirmationDialog")
onready var character_name_field = get_node("EditorUI/Panel/VBoxContainer/TabContainer/Info/TemplateContainer/HBoxContainer/CharacterNameField")

const ITEM_LIST_SCENE = preload("res://System/Scenes/Menus/Blocks/EROItemList.tscn")
const ALLOWED_CLOTHING_SLOTS = ["Top", "Skirt", "Bottom", "Underwear", "Socks", "Shoes"]

var clothing_tab
var clothing_slot_button_container

var loading_character_thumbnails = []

func _ready():
	init_editor()
	
func init_editor():
	character.load_body("TestContent.Bodies.BodyTest")
	character.add_item("TestContent.Clothing.ElfSocks")
	character.add_item("TestContent.Clothing.ElfShoes")
	character.add_item("TestContent.Clothing.ElfPantsu")
	character.add_item("TestContent.Clothing.ElfBloomers")
	character.add_item("TestContent.Clothing.ElfTop")
	character.add_item("TestContent.Clothing.ElfSkirt")
	for item_type in EROContent.ALLOWED_ITEM_TYPES:
		if item_type != "Clothing":
			var new_tab = TAB_TEMPLATE.duplicate()
			new_tab.name = EROContent.get_item_type_friendly_name(item_type)
			remove_child(new_tab)
			TABS_NODE.add_child(new_tab)
	
			
			for content_pack_name in EROContent.content_packs:
				var content_pack = EROContent.content_packs[content_pack_name]
				var item_list = ITEM_LIST_SCENE.instance()
				var label = Label.new()
				label.align = Label.ALIGN_CENTER
				label.text = content_pack["name"]
	
				if content_pack["items"][item_type]:
					new_tab.get_node("TemplateContainer").add_child(label)
					new_tab.get_node("TemplateContainer").add_child(item_list)
					for item_name in content_pack["items"][item_type]:
						var item_path = "%s.%s.%s" % [content_pack_name, item_type, item_name]
						item_list.add_item(item_path)
						
	# Clothing tab specific code
	clothing_tab = TAB_TEMPLATE.duplicate()
	clothing_tab.name = EROContent.get_item_type_friendly_name("Clothing")
	remove_child(clothing_tab)
	TABS_NODE.add_child(clothing_tab)
	for clothing_slot in ALLOWED_CLOTHING_SLOTS:
		var button = Button.new()
		button.text = clothing_slot
		clothing_tab.get_node("TemplateContainer").add_child(button)
		button.connect("pressed", self, "select_slot", [clothing_slot])
		
		clothing_slot_button_container = clothing_tab.get_node("TemplateContainer")
		
func update_ui():
	character_name_field.text = character.character_name
	
# sets the character info from the ui to the character object
func sync_character_info(new_text):
	character.character_name = character_name_field.text
		
func load_character_from_data(data):
	character.load_character_from_data(data)
	characters_container_panel.hide()
	update_ui()
	
func set_item(slot, item):
	var current_item_path = character.get_item_path_by_slot(slot)

	if item:
		character.add_item_async(item)
	elif current_item_path:
		character.remove_item(current_item_path)
		
# This removes the slot selection and replaces it with a clothing item selection or vice versa
func select_slot(selected_clothing_slot):
	#  If selected_clothing_slot is empty it means we should return to slot selection
	if not selected_clothing_slot:
		var old_tab = clothing_tab.get_children()[0]
		clothing_tab.remove_child(old_tab)
		old_tab.queue_free()
		clothing_tab.add_child(clothing_slot_button_container)
		return
	
	# Take the clothing tab button container and temporarily remove it
	clothing_tab.remove_child(clothing_slot_button_container)
	
	# Create the new button set for the selected slot from the template and add
	# it as a child to the tab
	var new_button_container = $TabTemplate/TemplateContainer.duplicate()
	var back_button = Button.new()
	back_button.text = "Back..."
	back_button.connect("pressed", self, "select_slot", [null])
	new_button_container.add_child(back_button)
	
	var none_button = Button.new()
	none_button.text = "None"
	none_button.connect("pressed", self, "set_item", [selected_clothing_slot, null])
	new_button_container.add_child(none_button)
	
	clothing_tab.add_child(new_button_container)
	
	for content_pack_name in EROContent.content_packs:
		var content_pack = EROContent.content_packs[content_pack_name]
		if content_pack.has("items"):
			for item_name in content_pack["items"]["Clothing"]:
				
				var item_path = "%s.%s.%s" % [content_pack_name, "Clothing", item_name]
				var item = EROContent.get_item(item_path)
				if item["slot"] == selected_clothing_slot:
					var button = Button.new()
					button.text = item["name"]
					button.connect("pressed", self, "set_item", [selected_clothing_slot, item_path])
					new_button_container.add_child(button)

func serialize_button():
	save("user://screen.png")

func save_character(add_to_list=false):
	$EditorUI/Panel.hide()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	img.lock()
	var original_width = img.get_size().x
	var original_height = img.get_size().y
	var final_image = Image.new()

	final_image.create(original_height,original_height, false, img.get_format())
	final_image.lock()
	var source_rect = Rect2(original_width/2-original_height/2,0,original_height,original_height)
	final_image.blit_rect(img, source_rect, Vector2(0,0))
	final_image.resize(720,720)
	
	character.save_character_to_card(final_image)
	if add_to_list:
		characters_container.add_character(character.to_dict(), character.get_image_path())
	
	$EditorUI/Panel.show()

func save_character_button_pressed():
	if character.exists_on_disk():
		overwrite_confirmation_dialog.popup()
	else:
		# We are not overwriting anything, save it without asking the user
		save_character(true)



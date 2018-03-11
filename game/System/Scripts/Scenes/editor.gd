extends Spatial

onready var TABS_NODE = get_node("EditorUI/EROGameUI/Panel/VBoxContainer/TabContainer")
onready var character = get_node("EROCharacter")
onready var TAB_TEMPLATE = get_node("TabTemplate")
onready var characters_container = get_node("EditorUI/EROGameUI/CharacterSelector")
onready var overwrite_confirmation_dialog = get_node("EditorUI/EROGameUI/OverwriteConfirmationDialog")
onready var character_name_field = get_node("EditorUI/EROGameUI/Panel/VBoxContainer/TabContainer/Info/TemplateContainer/HBoxContainer/CharacterNameField")

const ITEM_LIST_SCENE = preload("res://System/Scenes/Menus/Blocks/EROItemList.tscn")
const EDITOR_PICKER_SCENE = preload("res://System/Scenes/Editor/EditorColorPicker.tscn")
const ALLOWED_CLOTHING_SLOTS = ["Top", "Skirt", "Bottom", "Underwear", "Socks", "Shoes"]

var clothing_tab
var clothing_slot_button_container
var clothing_tab_scroll

var current_clothing_tab

var body_tab
var body_tab_container

var loading_character_thumbnails = []

var body_pickers = []

const DEFAULT_BODY = "BaseContent.Bodies.Female"

func _ready():
	# If _scene_path is empty then it means this scene has been loaded from the editor and should load defaults
	if not EROSceneLoader._scene_path:
		load_body(DEFAULT_BODY)
	
func init_editor():
	# RECODE
	# Clean this up
	
	# Remove existing tabs:
	for tab in TABS_NODE.get_children().duplicate():
		if tab.name != "Info":
			tab.queue_free()
			
	# Add tabs
	for item_type in EROContent.ALLOWED_ITEM_TYPES:
		if item_type != "Clothing":
			var new_tab = TAB_TEMPLATE.duplicate()
			new_tab.name = EROContent.get_item_type_friendly_name(item_type)
			remove_child(new_tab)
			TABS_NODE.add_child(new_tab)
			
			# Body tab specific stuff
			if item_type == "Bodies":
				
				body_tab = new_tab
				body_tab_container = new_tab.get_node("ScrollContainer/TemplateContainer")
			
			for content_pack_name in EROContent.content_packs:
				var content_pack = EROContent.content_packs[content_pack_name]
				var item_list = ITEM_LIST_SCENE.instance()
				var label = Label.new()
				label.align = Label.ALIGN_CENTER
				label.text = content_pack["name"]
	
				if content_pack["items"][item_type]:
					new_tab.get_node("ScrollContainer/TemplateContainer").add_child(label)
					new_tab.get_node("ScrollContainer/TemplateContainer").add_child(item_list)
					for item_name in content_pack["items"][item_type]:
						var item_path = "%s.%s.%s" % [content_pack_name, item_type, item_name]
						item_list.add_item(item_path)
			new_tab.get_node("ScrollContainer/TemplateContainer").add_child(HSeparator.new())
						
						
						
	# Create buttons for all clothing slots
	clothing_tab = TAB_TEMPLATE.duplicate()
	clothing_tab.name = EROContent.get_item_type_friendly_name("Clothing")
	remove_child(clothing_tab)
	TABS_NODE.add_child(clothing_tab)
	for clothing_slot in ALLOWED_CLOTHING_SLOTS:
		var button = Button.new()
		button.text = clothing_slot
		clothing_tab.get_node("ScrollContainer/TemplateContainer").add_child(button)
		button.connect("pressed", self, "select_slot", [clothing_slot])
		
	clothing_slot_button_container = clothing_tab.get_node("ScrollContainer/TemplateContainer")
	clothing_tab_scroll = clothing_tab.get_node("ScrollContainer")
		
	init_body_parameters()
		
func load_body(body_path):
	character.load_body(body_path)
	init_editor()
		
func update_ui():
	character_name_field.text = character.character_name
	
# sets the character info from the ui to the character object
func sync_character_info(new_text):
	character.character_name = character_name_field.text
		
func load_character_from_data(data):
	character.load_character_from_data(data)
	update_ui()
	init_body_parameters()
	
func set_item(slot, item):
	var current_item_path = character.get_item_path_by_slot(slot)

	if item:
		character.add_item_async(item)
	elif current_item_path:
		character.remove_item(current_item_path)
		
func init_body_parameters():
	# Duplicate to avoid modifying the original array while looping
	var pickers_to_remove = body_pickers.duplicate()
	for picker_to_remove in pickers_to_remove:
		body_pickers.erase(picker_to_remove)
		picker_to_remove.queue_free()
	var body_path = character.body.get_meta("path")
	var body_data = character.body.get_meta("data")
	for parameter_name in body_data.parameters:
		var picker = EDITOR_PICKER_SCENE.instance()
		body_tab_container.add_child(picker)
		picker.load_parameter(character, parameter_name)
		body_pickers.append(picker)
# This removes the slot selection and replaces it with a clothing item selection or vice versa
# HACK? maybe?
func select_slot(selected_clothing_slot):
	#  If selected_clothing_slot is empty it means we should return to slot selection
	if not selected_clothing_slot:
		current_clothing_tab.queue_free()
		clothing_tab_scroll.add_child(clothing_slot_button_container)
		return
	
	# Take the clothing tab button container and temporarily remove it
	clothing_tab_scroll.remove_child(clothing_slot_button_container)
	
	# Create the new button set for the selected slot from the template and add
	# it as a child to the tab
	current_clothing_tab = $TabTemplate/ScrollContainer/TemplateContainer.duplicate()
	current_clothing_tab.visible = true
	var back_button = Button.new()
	back_button.text = "Back..."
	back_button.connect("pressed", self, "select_slot", [null])
	current_clothing_tab.add_child(back_button)
	
	var none_button = Button.new()
	none_button.text = "None"
	none_button.connect("pressed", self, "set_item", [selected_clothing_slot, null])
	current_clothing_tab.add_child(none_button)
	
	clothing_tab_scroll.add_child(current_clothing_tab)
	
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
					current_clothing_tab.add_child(button)

func set_item_parameter(item_path, parameter, value):
	character.set_item_parameter(item_path, parameter, value)

func save_character(add_to_list=false):
	var viewport_image = $Viewport.get_texture().get_data()
	viewport_image.flip_y()
	
	character.save_character_to_card(viewport_image)
	if add_to_list:
		characters_container.add_character(character.to_dict(), character.get_image_path())

func save_current_character():
	if character.exists_on_disk():
		overwrite_confirmation_dialog.popup()
	else:
		# We are not overwriting anything, save it without asking the user
		save_character(true)
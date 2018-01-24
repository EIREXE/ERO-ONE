extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var TABS_NODE = get_node("EditorUI/Panel/VBoxContainer/TabContainer")
onready var character = get_node("EROCharacter")
onready var TAB_TEMPLATE = get_node("TabTemplate")
onready var CLOTHING_VIEWER_CONTAINER = get_node("EditorUI/ClothingViewer/ClothingViewerButtonContainer")
onready var CLOTHING_VIEWER = get_node("EditorUI/ClothingViewer")
const ITEM_LIST_SCENE = preload("res://System/Scenes/Menus/Blocks/EROItemList.tscn")
const ALLOWED_CLOTHING_SLOTS = ["Top", "Skirt", "Bottom", "Underwear", "Socks", "Shoes"]

func _ready():
	init_ui()
	init_editor()
func init_ui():
	pass

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
	var new_tab = TAB_TEMPLATE.duplicate()
	new_tab.name = EROContent.get_item_type_friendly_name("Clothing")
	remove_child(new_tab)
	TABS_NODE.add_child(new_tab)
	for clothing_slot in ALLOWED_CLOTHING_SLOTS:
		var button = Button.new()
		button.text = clothing_slot
		new_tab.get_node("TemplateContainer").add_child(button)
		button.connect("pressed", CLOTHING_VIEWER, "select_slot", [clothing_slot])
		
func set_item(slot, item):
	var current_item_path = character.get_item_path_by_slot(slot)
	if item:
		character.add_item(item)
	elif current_item_path:
		character.remove_item(current_item_path)
extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var button_container = get_node("ClothingViewerButtonContainer")
onready var editor_main = get_node("../..")
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func select_slot(slot_name):
	for button in button_container.get_children():
		button_container.remove_child(button)
	
	var none_button = Button.new()
	none_button.text = "None"
	button_container.add_child(none_button)
	none_button.connect("pressed", editor_main, "set_item", [slot_name, null])
	
	for content_pack_name in EROContent.content_packs:
		var content_pack = EROContent.content_packs[content_pack_name]
		if content_pack.has("items"):
			for item_name in content_pack["items"]["Clothing"]:
				
				var item_path = "%s.%s.%s" % [content_pack_name, "Clothing", item_name]
				var item = EROContent.get_item(item_path)
				if item["slot"] == slot_name:
					var button = Button.new()
					button.text = item["name"]
					button.connect("pressed", editor_main, "set_item", [slot_name, item_path])
					button_container.add_child(button)
extends CenterContainer

onready var grid_container = get_node("GridContainer")

func _ready():
	pass
func add_item(item_path):
	var item = EROContent.get_item(item_path)
	if item:
		var item_folder = EROContent.get_item_folder(item_path)
		var button = Button.new()
		button.set_meta("item_path", item_path)
		if File.new().file_exists(item_folder + "/icon.png"):
			button.icon = load(item_folder + "/icon.png")
			button.hint_tooltip = item["name"]
		else:
			button.text = item["name"]
		
		grid_container.add_child(button)
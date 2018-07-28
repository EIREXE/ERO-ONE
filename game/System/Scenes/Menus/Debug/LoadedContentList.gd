extends Node

onready var tree = get_node("Panel/Tabs/Tree")
onready var tabs = get_node("Panel/Tabs")
onready var template = get_node("Panel/Tabs/Template")
const PACKAGE_INFO_EDITOR_SCENE = preload("res://System/Scenes/Menus/Debug/PackageInfoEditor.tscn")

func _ready():
	print(var2str(Vector3(0.5,0.5,0.5)))

	for content_pack_name in EROContent.content_packs:
		var content_pack = EROContent.content_packs[content_pack_name]
		var new_tab = template.duplicate()
		tabs.add_child(new_tab)

		var content_pack_tree = new_tab.get_node("HSplitContainer/Tree")
		
		new_tab.name = content_pack_name
		
		

		content_pack_tree.columns = 3
		content_pack_tree.set_column_titles_visible(true)

		content_pack_tree.set_column_title(0, "Internal Name")
		content_pack_tree.set_column_title(1, "User Friendly Name")

		var root_item = content_pack_tree.create_item()
		root_item.set_text(0, "root")

		
		# Add items to the tree
		for item_type in content_pack["items"]:
			var item_type_item = content_pack_tree.create_item(root_item)
			item_type_item.set_text(0, item_type)
			for item_name in content_pack["items"][item_type]:
				var item = content_pack["items"][item_type][item_name]
				var item_tree_item = content_pack_tree.create_item(item_type_item)
				
				item_tree_item.set_text(0, "%s.%s.%s" % [content_pack_name, item_type, item_name])
				item_tree_item.set_text(1, item["name"])
	template.queue_free()

func _on_Tabs_tab_changed():
	pass # Replace with function body.

extends Node

onready var tree = get_node("Tree")

func _ready():
	print(var2str(Vector3(0.5,0.5,0.5)))
	tree.set_column_title(0, "Internal Name")
	tree.set_column_title(1, "Name")
	tree.set_column_titles_visible(true)
	for content_pack_name in EROContent.content_packs:
		
		var content_pack = EROContent.content_packs[content_pack_name]
		
		var content_pack_item = tree.create_item()
		content_pack_item.set_text(0, content_pack_name)
		for item_type in content_pack["items"]:
			var item_type_item = tree.create_item(content_pack_item)
			item_type_item.set_text(0, item_type)
			for item_name in content_pack["items"][item_type]:
				var item = content_pack["items"][item_type][item_name]
				var item_tree_item = tree.create_item(item_type_item)
				
				item_tree_item.set_text(0, "%s.%s.%s" % [content_pack_name, item_type, item_name])
				item_tree_item.set_text(1, item["name"])
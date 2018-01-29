"""
ERO-ONE: The Next-Generation Erotic game
"""
extends Node

var content_packs = {}
const CONTENT_PACKS_DIR = "res://Content"
const CHARACTERS_DIR = "user://Characters"
const IEND_SIGNATURE = PoolByteArray([0x49,0x45,0x4E,0x44])

const ALLOWED_ITEM_TYPES = ["Bodies", "HairStyles","Clothing"]
const ITEM_TYPE_FRIENDLY_NAMES = { 
		"Bodies": "Body",
		"HairStyles": "Hair",
		"Clothing": "Clothes"
}

var characters = {}

func _ready():
	load_content_packs()
	Console.register_command('list_content_packs', {
		description = 'Lists all the currently loaded content packs',
		args = [],
		target = self
	})
	
func load_content_packs():
	var dir = Directory.new()
	if dir.open(CONTENT_PACKS_DIR) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				var file = File.new()
				var pack_config_path = CONTENT_PACKS_DIR + "/%s/package.json" % [file_name]
				
				if file.file_exists(pack_config_path):
					var pack_name = file_name
					load_content_pack(pack_name)
					load_content_pack_items(pack_name)
				file_name = dir.get_next()

func load_content_pack(pack_name):
	Console.info("Loading content pack %s..." % [pack_name],"EROContent")
	var pack_file = File.new()
	var pack_config_path = CONTENT_PACKS_DIR + "/%s/package.json" % [pack_name]
	
	pack_file.open(pack_config_path, pack_file.READ)
	var pack_data = parse_json(pack_file.get_as_text())
	content_packs[pack_name] = pack_data
	Console.info("Loading %s succesful" % [pack_name],"EROContent")
	
func load_content_pack_items(pack_name):
	var dir = Directory.new()
	for item_type in ALLOWED_ITEM_TYPES:
		var item_type_folder = CONTENT_PACKS_DIR + "/%s/%s" % [pack_name, item_type]
		
		if not content_packs[pack_name].has("items"):
			content_packs[pack_name]["items"] = {}
		if not content_packs[pack_name]["items"].has(item_type):
			content_packs[pack_name]["items"][item_type] = {}
		
		if dir.open(item_type_folder) == OK:
			dir.list_dir_begin(true)
			var item_folder_name = dir.get_next()

			
			while (item_folder_name != ""):
				if dir.current_is_dir():
					var file = File.new()
					var item_config_path = CONTENT_PACKS_DIR + "/%s/%s/%s/item.json" % [pack_name, item_type, item_folder_name]
					if file.file_exists(item_config_path):
						var item_name = item_folder_name
						load_item(pack_name,item_type, item_folder_name)
						
					item_folder_name = dir.get_next()
			if len(content_packs[pack_name]["items"][item_type]) > 0:
				Console.info("Loading %d %s succesful (%s)" % [len(content_packs[pack_name]["items"][item_type]), item_type, pack_name],"EROContent")

func load_item(pack_name, item_type, item_name):
	var item_file = File.new()
	var item_config_path = CONTENT_PACKS_DIR + "/%s/%s/%s/item.json" % [pack_name, item_type, item_name]
	
	item_file.open(item_config_path, item_file.READ)
	var item_data = parse_json(item_file.get_as_text())
	
	if not item_data:
		Console.err("Error parsing file %s..." % [item_config_path],"EROContent")
		return
	
	if not content_packs[pack_name].has("items"):
		content_packs[pack_name]["items"] = {}
	if not content_packs[pack_name]["items"].has(item_type):
		content_packs[pack_name]["items"][item_type] = {}
	content_packs[pack_name]["items"][item_type][item_name] = item_data
					
func list_content_packs():
	for pack in content_packs:
		Console.info("%s: %s" % [pack, content_packs[pack]["name"]])
		
func load_image_data(image_path):
	var file = File.new()
	file.open(image_path, file.READ)
	for i in range(file.get_len()):
		file.seek(i)
		if file.get_buffer(4) == IEND_SIGNATURE:
			print("FOUND IEND at %X" % (file.get_position()-4))
			var extra_data = file.get_buffer(file.get_len()-file.get_position())
			return extra_data.get_string_from_utf8()

func save_image_data(image_path, data):
	var file = File.new()
	var extra_data_position
	file.open(image_path, file.READ)
	for i in range(file.get_len()):
		file.seek(i)
		if file.get_buffer(4) == IEND_SIGNATURE:
			extra_data_position = file.get_position()
			file.seek(0)
			var image_data = file.get_buffer(file.get_len()-(file.get_len()-extra_data_position))
			var extra_data = data.to_utf8()
			image_data.append_array(extra_data)
			file.open(image_path, file.WRITE)
			file.store_buffer(image_data)
			file.close()
			return
			
func get_item(item_path):
	# Internally, item paths are divided in three parts, the content pack, the type
	# and the name, an example would be BaseContent.HairStyles.TestHair
	var pack_name = item_path.split(".")[0] # BaseContent.HairStyles.TestHair
	var item_type = item_path.split(".")[1]
	var item_name = item_path.split(".")[2]
	
	
	if content_packs.has(pack_name) \
			and content_packs[pack_name].has("items") \
			and content_packs[pack_name]["items"].has(item_type) \
			and content_packs[pack_name]["items"][item_type].has(item_name):
		return content_packs[pack_name]["items"][item_type][item_name]
	else:
		return null
		
func get_item_folder(item_path):
	var pack_name = item_path.split(".")[0] # BaseContent.HairStyles.TestHair
	var item_type = item_path.split(".")[1]
	var item_name = item_path.split(".")[2]
	return CONTENT_PACKS_DIR + "/%s/%s/%s" % [pack_name, item_type, item_name]
	
func get_item_type_friendly_name(item_type):
	if ITEM_TYPE_FRIENDLY_NAMES.has(item_type):
		return ITEM_TYPE_FRIENDLY_NAMES[item_type]
	else:
		return item_type
		
func get_characters():
	var characters = []
	var dir = Directory.new()
	if dir.open(CHARACTERS_DIR) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while (file_name != ""):
			
			if not dir.current_is_dir():
				if file_name.ends_with(".png"):
					var image_path = CHARACTERS_DIR + "/%s" % [file_name]
					var image_data = JSON.parse(EROContent.load_image_data(image_path)).result
					image_data["image_path"] = image_path
					characters.append(image_data)
			file_name = dir.get_next()
	return characters
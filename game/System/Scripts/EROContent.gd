"""
ERO-ONE: The Next-Generation Erotic game
"""
extends Node

var content_packs = {} setget ,get_allowed_content_packs
var allowed_content_packs = []
const CONTENT_PACKS_DIR = "res://Content"
const CHARACTERS_DIR = "user://Characters"
const MODS_DIR = "user://Mods"

const CONTENT_CONFIG_FILE = "user://content.json"

const IEND_SIGNATURE = PoolByteArray([0x49,0x45,0x4E,0x44])

const ENABLE_MODDING = false

const ALLOWED_ITEM_TYPES = ["Bodies", "HairStyles","Clothing"]
const ITEM_TYPE_FRIENDLY_NAMES = { 
		"Bodies": "Body",
		"HairStyles": "Hair",
		"Clothing": "Clothes"
}

var characters = {}

const PERSONALITIES_FILE = "res://System/Data/Editor/personalities.json"
var personalities = {}
func _ready():
	load_mod_pcks()
	load_content_packs()
	load_content_config()
	save_content_config()
	load_personalities()
	Console.register_command('list_content_packs', {
		description = 'Lists all the currently loaded content packs',
		args = [],
		target = self
	})

# Loads mods from the Mods folder in user://
func load_mod_pcks():
	if ENABLE_MODDING:
		var dir = Directory.new()
		if dir.open(MODS_DIR) == OK:
			dir.list_dir_begin(true)
			var file_name = dir.get_next()
			while (file_name != ""):
				if not dir.current_is_dir():
					var file_path = MODS_DIR + "/%s" % [file_name]
					ProjectSettings.load_resource_pack(file_path)
					file_name = dir.get_next()

###########
# Content config manipulation
###########
func save_content_config():
	var content_config = {}
	content_config["allowed_content_packs"] = allowed_content_packs
	var file = File.new()
	file.open(CONTENT_CONFIG_FILE, File.WRITE)
	file.store_string(to_json(content_config))
	file.close()
	
func load_content_config():
	var file = File.new()
	# Add content packs from the file
	if file.file_exists(CONTENT_CONFIG_FILE):
		file.open(CONTENT_CONFIG_FILE, File.READ)
		var content_config = parse_json(file.get_as_text())
		allowed_content_packs = []
		for pack in content_config["allowed_content_packs"]:
			allowed_content_packs.append(pack)

	for pack_name in content_packs:
		var content_pack = content_packs[pack_name]
		if content_pack["official"]:
			if not pack_name in allowed_content_packs:
				allowed_content_packs.append(pack_name)

func create_content_folders():
	if not Directory.new().dir_exists(CHARACTERS_DIR):
		Directory.new().make_dir_recursive(CHARACTERS_DIR)
	if not Directory.new().dir_exists(MODS_DIR):
		Directory.new().make_dir_recursive(MODS_DIR)
###########
# Content pack manipulation
###########	

func get_allowed_content_packs():
	var packs = {}
	for pack_name in allowed_content_packs:
		if content_packs.has(pack_name): 
			packs[pack_name] = content_packs[pack_name]
	return packs
func get_all_content_packs():
	return content_packs

func load_content_packs():
	var dir = Directory.new()
	if dir.open(CONTENT_PACKS_DIR) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				var file = File.new()
				var pack_config_path = CONTENT_PACKS_DIR + "/%s/package.json" % [file_name]
				print(file_name)
				if file.file_exists(pack_config_path):
					var pack_name = file_name
					load_content_pack(pack_name)
					load_content_pack_items(pack_name)
				file_name = dir.get_next()

func load_content_pack(pack_name):
	#Console.info("Loading content pack %s..." % [pack_name],"EROContent")
	var pack_file = File.new()
	var pack_config_path = CONTENT_PACKS_DIR + "/%s/package.json" % [pack_name]
	
	pack_file.open(pack_config_path, pack_file.READ)
	var pack_data = parse_json(pack_file.get_as_text())
	content_packs[pack_name] = pack_data
	#Console.info("Loading %s succesful" % [pack_name],"EROContent")
	
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
		
###########
# Card Loading and writing
###########
func load_image_data_from_disk(image_path):
	return EROSteganography.get_steganographic_data_from_file(image_path)

func load_image_data(image):
	return EROSteganography.get_steganographic_data_from_image(image)

func save_image_data(image, data):
	return EROSteganography.store_string_in_image(image,data)

func save_image_data_to_disk(image_path, image, data):
	
	EROSteganography.store_string_in_image(image, data).save_png(image_path)
			
###########
# Item manipulation
###########
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
		
func delete_character(character_data):
	if character_data.has("uuid"):
		var file = File.new()
		var image_path = "user://Characters/%s.png" % [character_data["uuid"]]
		if file.file_exists(image_path):
			var dir = Directory.new()
			dir.remove(image_path)
			characters.erase(character_data)
			
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
					var file_content = EROContent.load_image_data_from_disk(image_path)
					var image_data = JSON.parse(file_content).result
					image_data["image_path"] = image_path
					characters.append(image_data)
			file_name = dir.get_next()
	return characters
	
# Personality loading
func load_personalities():
	var file = File.new()
	# Add content packs from the file
	if file.file_exists(PERSONALITIES_FILE):
		file.open(PERSONALITIES_FILE, File.READ)
		personalities = parse_json(file.get_as_text())
extends Spatial

var model

var item_scenes = {}
var body
const ERO_ITEM_SCENE = "res://Scenes/EROItem.tscn"

var items_loading = {}

var character_uuid

var character_name = ""

func _ready():
	set_process(true)
	
func _process(delta):
	for item in items_loading:
		var item_data = EROContent.get_item(item)
		if EROResourceQueue.is_ready(item_data["model"]):
			var items_loading_data = items_loading[item]
			print(items_loading_data)
			if items_loading_data.has("user_data"):
				print("HAS USER DATA")
				add_item(item, items_loading_data["user_data"])
			else:
				add_item(item)
			items_loading.erase(item)
		# Loading failed, we'll get em next time.
		if EROResourceQueue.get_progress(item_data["model"]) == -1:
			items_loading.erase(item)
func load_character():
	#init_character()
	pass
func load_body(body_path, user_item_data=null):
	if body:
		body.queue_free()
		# Using keys because godot interrupts for loops
		# when the contents are modified
		for item_name in item_scenes.keys():
			remove_item(item_name)
	var body_scene = load_item(body_path, user_item_data)
	
	if body_scene:
		add_child(body_scene)
		body = body_scene
		var body_data = get_body_data()
		if body_data.has("scale"):
			var model_scale = body_data["scale"]
			body.scale = Vector3(model_scale,model_scale,model_scale)
	else:
		Console.err("Aborted body loading of %s" % [body_path], "EROCharacter")
		return
		

# Loads an item but doesn't add it to the scene
func load_item(item_path, user_item_data=null):
	var item_data = EROContent.get_item(item_path)
	if item_data:
		var item_model = item_data["model"]
		var item_scene = EROResourceQueue.get_resource(item_model).instance()
		if item_scene:
			item_scene.set_meta("data", item_data)
			item_scene.set_meta("path", item_path)
			item_scenes[item_path] = item_scene
			if user_item_data:
				apply_parameters_from_user_data(item_path, user_item_data)
			else:
				apply_item_parameter_defaults(item_path)
			return item_scene
		else:
			Console.err("Item %s scene does not exist" % [item_path])
	else:
		Console.err("Item %s, not found or is corrupted." % [item_path], "EROCharacter")
		return null
		
# Loads an item and adds it to the body
func add_item(item_path, user_item_data=null):
	if not item_scenes.has(item_path):
		var item = load_item(item_path)
		body.get_node(get_body_data()["armature"]).add_child(item)

		
# Same but async
func add_item_async(item_path, user_item_data=null):
	if not item_scenes.has(item_path):
		var item_data = EROContent.get_item(item_path)
		if item_data:
			EROResourceQueue.queue_resource(item_data["model"])
			var loading_item_data = {}
			loading_item_data["user_data"] = user_item_data
			items_loading[item_path] = loading_item_data
			
func apply_parameters_from_user_data(item_path, item_user_data):
	if item_user_data.has("parameters"):
		for parameter_name in item_user_data["parameters"]:
			var value = item_user_data["parameters"][parameter_name]["value"]
			set_item_parameter(item_path, parameter_name, str2var(value))
			
# Applies item parameter defaults from the EROContent store
func apply_item_parameter_defaults(item_path):
	var item_data = EROContent.get_item(item_path)
	var item = get_item_data(item_path)
	if item.has("parameters"):
		for parameter_name in item["parameters"]:
			var parameter = item["parameters"][parameter_name]
			apply_parameter_defaults(item_path, parameter_name)
	
# Same as above but for a single parameter
func apply_parameter_defaults(item_path, parameter_name):
	var item_data = EROContent.get_item(item_path)
	if item_data.has("parameters"):
		if item_data["parameters"].has(parameter_name):
			var parameter = item_data["parameters"][parameter_name]
			set_item_parameter(item_path, parameter_name, str2var(parameter["default"]))
			
func remove_item(item_path):
	var item = get_item(item_path)
	item.free()
	item_scenes.erase(item_path)
func get_body_data():
	return body.get_meta("data")

func get_item(item_path):
	return item_scenes[item_path]

func get_item_data(item_path):
	return item_scenes[item_path].get_meta("data")
	
func get_item_path_from_scene(scene):
	return scene.get_meta("path")
	
func get_item_path_by_slot(slot_name):
	for item_path in item_scenes:
		var item_data = get_item_data(item_path)
		if item_data["slot"] == slot_name:
			return item_path
			
func set_item_parameter(item_path, parameter, value):
	var item = get_item(item_path)
	var item_data = get_item_data(item_path)
	var parameter_data = item_data["parameters"][parameter]
	
	if parameter_data["type"] == "color_map":
		var node = item.get_node(parameter_data["node"])
		var material_number = parameter_data["material"]
		var material = node.mesh.surface_get_material(material_number).next_pass
		material.set_shader_param("item_color", value)
		item_data["parameters"][parameter]["value"] = value
		item_scenes[item_path].set_meta("data", item_data)
	
func serialize():
	return to_json(to_dict())
	
func to_dict():
	var items = {}
	for item_path in item_scenes:
		var item = {}
		item["parameters"] = {}
		var item_data = get_item_data(item_path)
		for parameter_name in item_data["parameters"]:
			var parameter = item_data["parameters"][parameter_name]
			if parameter.has("value"):
				item["parameters"][parameter_name] = {}
				item["parameters"][parameter_name]["value"] = var2str(parameter["value"])
		items[item_path] = item
	
	var serialized_data = {
		name=character_name,
		items=items,
		body=body.get_meta("path"),
		uuid=character_uuid
	}
	return serialized_data
	
func save_character_to_card(image):
	var CARD_FRAME = Image.new()
	CARD_FRAME.load("res://System/Textures/cards/frame_0.png")
	
	image.convert(CARD_FRAME.get_format())
	
	var card_rect = Rect2(0,0, CARD_FRAME.get_width(), CARD_FRAME.get_height())
	image.blit_rect_mask(CARD_FRAME, CARD_FRAME, card_rect, Vector2(0,0))
	EROContent.save_image_data_to_disk(get_image_path(), image ,serialize())
	
func load_character_from_card(card_path):
	var file = File.new()
	if file.file_exists(card_path):
		var data = EROContent.load_image_data_from_disk(card_path)
		load_character_from_data(data)
func load_character_from_data(data):
	var body_path = data["body"]
	load_body(body_path, data["items"][body_path])
	character_name = data["name"]
	character_uuid = data["uuid"]
	for item_path in data["items"]:
		# Body is loaded asynchronously...
		if item_path != data["body"]:
			add_item_async(item_path, data["items"][item_path])
	
func exists_on_disk():
	var file = File.new()
	return file.file_exists(get_image_path())
	
func get_image_path():
	var image_path
	if not character_uuid:
		var unique = false
		while(not unique):
			character_uuid = v4()
			var file = File.new()
			image_path = "user://Characters/%s.png" % [character_uuid]
			if not file.file_exists(image_path):
				unique=true
	image_path = "user://Characters/%s.png" % [character_uuid]
	return image_path
# uuid functionality
static func getRandomInt(max_value):
  randomize()

  return randi() % max_value

static func randomBytes(n):
  var r = []

  for index in range(0, n):
    r.append(getRandomInt(256))

  return r

static func uuidbin():
  var b = randomBytes(16)

  b[6] = (b[6] & 0x0f) | 0x40
  b[8] = (b[8] & 0x3f) | 0x80
  return b

static func v4():
  var b = uuidbin()

  var low = '%02x%02x%02x%02x' % [b[0], b[1], b[2], b[3]]
  var mid = '%02x%02x' % [b[4], b[5]]
  var hi = '%02x%02x' % [b[6], b[7]]
  var clock = '%02x%02x' % [b[8], b[9]]
  var node = '%02x%02x%02x%02x%02x%02x' % [b[10], b[11], b[12], b[13], b[14], b[15]]

  return '%s-%s-%s-%s-%s' % [low, mid, hi, clock, node]
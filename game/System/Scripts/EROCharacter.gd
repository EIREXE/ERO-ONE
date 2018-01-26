extends Spatial

var model

var items = {}
var body
const ERO_ITEM_SCENE = "res://Scenes/EROItem.tscn"

var items_loading = []

func _ready():
	set_process(true)
	
func _process(delta):
	for item in items_loading:
		var item_data = EROContent.get_item(item)
		if EROResourceQueue.is_ready(item_data["model"]):
			add_item(item)
			items_loading.remove(item)
		# Loading failed, we'll get em next time.
		if EROResourceQueue.get_progress(item_data["model"]) == -1:
			items_loading.remove(item)
func load_character():
	#init_character()
	pass
func load_body(body_path):
	var body_scene = load_item(body_path)
	add_child(body_scene)
	body = body_scene
	body.get_node("AnimationPlayer").play("PoseLib")
	var body_data = get_body_data()
	if body_data.has("scale"):
		var model_scale = body_data["scale"]
		body.scale = Vector3(model_scale,model_scale,model_scale)
# Loads an item but doesn't add it to the scene
func load_item(item_path):
	var item_data = EROContent.get_item(item_path)
	var item_model = item_data["model"]
	if item_data:
		var item_scene = EROResourceQueue.get_resource(item_model).instance()
		item_scene.set_meta("data", item_data)
		return item_scene
# Loads an item and adds it to the body
func add_item(item_path):
	if not items.has(item_path):
		var item = load_item(item_path)
		body.get_node(get_body_data()["armature"]).add_child(item)
		items[item_path] = item

func add_item_async(item_path):
	if not items.has(item_path):
		var item_data = EROContent.get_item(item_path)
		if item_data:
			EROResourceQueue.queue_resource(item_data["model"])
			items_loading.append(item_path)
func get_body_data():
	return body.get_meta("data")

func get_item(item_path):
	return items[item_path]

func get_item_data(item_path):
	return items[item_path].get_meta("data")
	
func get_item_path_by_slot(slot_name):
	for item_path in items:
		var item_data = get_item_data(item_path)
		print(item_data)
		if item_data["slot"] == slot_name:
			return item_path
			
func remove_item(item_path):
	var item = get_item(item_path)
	item.queue_free()
	items.erase(item_path)
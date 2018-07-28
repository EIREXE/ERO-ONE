extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var item_data
var model

func _ready():
	pass
	
func load_item(item_path):
	item_data = EROContent.get_item(item_path)
	# Load item model
	model = load(item_data["model"]).instance()

	add_child(model)
	
	set_parameter_defaults()
	
func set_parameter_defaults():
	for parameter in item_data["parameters"]:
		set_parameter(parameter, str2var(item_data["parameters"][parameter]["default"]))
		
func set_parameter(parameter_name, value):
	var parameter = item_data["parameters"][parameter_name]
	if parameter["type"] == "albedo":
		# Ensure that the color is always of the correct type...
		if typeof(value) == TYPE_STRING:
			value = str2var(value)
		var model_instance = model.get_node(parameter["node"])
		var material = model_instance.get_surface_material(parameter["material"])
		if not material:
			material = model_instance.mesh.surface_get_material(parameter["material"])
		material.albedo_color = value
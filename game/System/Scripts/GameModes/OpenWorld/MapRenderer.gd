extends Control

class_name road_renderer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var scale = 3.0 setget set_scale

const ROAD_COLOR = Color("#999999")

var width_varies_with_scale = true

var origin = Vector3()

func get_transformed_origin():
	return -Vector2(origin.x, origin.z) * scale

# Called when the node enters the scene tree for the first time.
func _ready():
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	var road_roots = get_tree().get_nodes_in_group("minimap_roads")
	for root_node in road_roots:
		draw_roads(root_node)
	
func set_origin(origin):
	#rect_position = -Vector2(origin.x, origin.z) * scale
	self.origin = origin
	update()
func global2minimap(position):
	position *= scale
	position += get_parent().size / 2
	return position
	
func global3d2minimap(position):
	return global2minimap(Vector2(position.x, position.z))
	
func set_scale(value):
	scale = value
	set_origin(origin)
	update()
	
func draw_roads(node):
	var origin = get_transformed_origin()
	var from = global3d2minimap(node.global_transform.origin) + origin
	for child in node.get_children():
		var to = global3d2minimap(child.global_transform.origin) + origin
		
		var width = 20
		if width_varies_with_scale:
			width = 6.5 * scale
		
		draw_line(from, to, ROAD_COLOR, width)
		if child.get_child_count() > 1:
			draw_circle(to, width/2, ROAD_COLOR)
		draw_roads(child)
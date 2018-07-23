extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var markers = {}
var marker_categories = {}

onready var legend = get_node("Control/Legend")

export(NodePath) var road_renderer

const DEFAULT_MAP_SCALE = 10.0

var map_scale_target = DEFAULT_MAP_SCALE
onready var item_label = get_node("ItemLabel")

var hovering_marker

func _process(delta): 
	if visible:
		if map_scale_target != get_renderer().scale:
			get_renderer().scale = lerp(get_renderer().scale, map_scale_target, 10*delta)
			update_all_marker_transforms()
			if item_label.visible and hovering_marker:
				show_label(hovering_marker)
	
	
	
func global2map(origin):
	return get_renderer().global3d2minimap(origin - get_renderer().origin)

func set_map_origin(origin):
	get_renderer().set_origin(origin)
	update_all_marker_transforms()

func update_all_marker_transforms():
	for marker_list in marker_categories.values():
		for marker_data in marker_list:
			update_marker_transform(marker_data)

func update_viewport_size():
	get_renderer_viewport().size = rect_size

func update_marker_transform(marker_data):
	var map_icon = marker_data["map_icon"]
	var marker = marker_data["world_marker"]
	
	var position = global2map(marker.global_transform.origin)
	if marker.important:
		position.x = clamp(position.x, 0.0, rect_size.x)
		position.y = clamp(position.y, 0.0, rect_size.y)
	
	map_icon.set_position_centered(position)
	
	if marker.display_rotation:
		var rotation = marker.global_transform.basis.get_euler()
		map_icon.sprite_rotation = rad2deg(-rotation.y)

func get_renderer():
	return get_node(road_renderer).get_node("RoadRenderer")

func get_renderer_viewport():
	return get_node(road_renderer)

func show_label(marker_data):
	hovering_marker = marker_data
	var marker = marker_data["world_marker"]
	var map_icon = marker_data["map_icon"]
	item_label.text = marker.marker_name
	item_label.rect_global_position = map_icon.rect_global_position + map_icon.rect_size / 2 - item_label.rect_size / 2
	item_label.rect_global_position -= Vector2(0, 32)
	item_label.show()
func hide_label():
	item_label.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

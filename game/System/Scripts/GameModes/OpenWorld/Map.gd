extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var markers = {}
var marker_categories = {}

onready var legend = get_node("Control/Legend")

const MapLegend = preload("res://System/Scripts/GameModes/OpenWorld/MapLegend.tscn")

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

# Called when the node enters the scene tree for the first time.
func _ready():
	var map_manager = EROGameModeManager.game_mode.map_manager
	if map_manager:
		map_manager.connect("new_marker", self, "add_new_marker")
		
	get_renderer().scale = DEFAULT_MAP_SCALE
	
	connect("resized", self, "update_viewport_size")
	
	item_label.hide()

func _input(event):
	var zoom = Input.get_action_strength("zoom_in") - Input.get_action_strength("zoom_out")
	map_scale_target = map_scale_target + zoom*(EROSettings.zoom_speed*15.0*get_process_delta_time())
	if event is InputEventMouseMotion and Input.is_action_pressed("map_drag"):
		var origin = get_renderer().origin
		var origin_diff = event.relative / get_renderer().scale
		origin -= Vector3(origin_diff.x, 0, origin_diff.y)
		set_map_origin(origin)

func on_show():
	var player = EROGameModeManager.game_mode.player
	print(player.global_transform.origin)
	map_scale_target = DEFAULT_MAP_SCALE
	get_renderer().scale = DEFAULT_MAP_SCALE-2.0
	set_map_origin(player.global_transform.origin)
	update_viewport_size()
	
	
	
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

func add_new_marker(marker):
	var legend_entry = MapLegend.instance()
	if not marker_categories.has(marker.type):
		legend_entry.set_marker(marker.get_marker_type_data())
		marker_categories[marker.type] = []
		legend.add_child(legend_entry)
	var map_icon = MinimapIcon.new()
	map_icon.sprite_texture = marker.get_marker_icon()
	
	var marker_data = {
		"map_icon": map_icon,
		"legend": legend_entry,
		"world_marker": marker
	}
	
	marker_categories[marker.type].append(marker_data)
	
	$MapIcons.add_child(map_icon)
	
	
	
	marker.connect("marker_position_changed", self, "update_marker_transform", [marker_data])
	map_icon.sprite.connect("mouse_entered", self, "show_label", [marker_data])
	map_icon.sprite.connect("mouse_exited", self, "hide_label")
	
	update_marker_transform(marker_data)

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

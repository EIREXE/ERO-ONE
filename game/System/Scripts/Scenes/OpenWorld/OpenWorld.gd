extends Spatial

signal open_world_ready

var player setget set_player
onready var map = get_node("CanvasLayer/Map")
onready var map_renderer = get_node("MapRenderer")
onready var map_player_position = get_node("CanvasLayer/Map/Hbox/Map/PlayerIndicator")

const DEFAULT_MAP_SCALE = 10.0
var map_scale_target = DEFAULT_MAP_SCALE
func set_player(value):
	player = value
	init()

func init():
	emit_signal("open_world_ready")
	set_process_input(true)
	set_process(true)

func _ready():
	map.hide()
	set_process_input(false)
	set_process(false)
	
func _process(delta):
	if map.visible:
		map_renderer.renderer.scale = lerp(map_renderer.renderer.scale, map_scale_target, 10*delta)
		map_player_position.set_position_centered(map_renderer.global3d2minimap(player.global_transform.origin))
		
		var rotation = player.character.pivot_point.global_transform.basis.get_euler()
		map_player_position.sprite.rect_rotation = rad2deg(-(rotation.y))
func _input(event):
	if event.is_action("map") and event.is_action_pressed("map") \
		and !event.is_echo():
			if map.visible:
				map.hide()
				EROOverlayedMenus.unpause_game()
				EROOverlayedMenus.show_game_ui()
			else:
				EROOverlayedMenus.pause_game()
				EROOverlayedMenus.hide_game_ui()
				map_renderer.size = $CanvasLayer/Map/Hbox/Map.rect_size
				map.show()
				map_renderer.set_origin(player.global_transform.origin)
				map_scale_target = DEFAULT_MAP_SCALE
				map_renderer.renderer.scale = DEFAULT_MAP_SCALE
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				
	if map.visible:
		handle_map_input(event)
func handle_map_input(event):
	var horizontal = Input.get_action_strength("zoom_in") - Input.get_action_strength("zoom_out")
	map_scale_target = map_scale_target + horizontal*(EROSettings.zoom_speed*15.0*get_process_delta_time())
	if event is InputEventMouseMotion and Input.is_action_pressed("map_drag"):
		var origin = map_renderer.renderer.origin
		var origin_diff = event.relative / map_renderer.renderer.scale
		origin -= Vector3(origin_diff.x, 0, origin_diff.y)
		map_renderer.set_origin(origin)
extends ConfirmationDialog

# TODO: Figure out how FXAA works

onready var msaa_option_button = get_node("TabContainer/Video/VBoxContainer/HBoxContainer/LeftCol/MSAA/MSAAOption")
onready var fxaa_option_checkbox = get_node("TabContainer/Video/VBoxContainer/HBoxContainer/LeftCol/FXAA/FXAAOption")
onready var show_fps_option_checkbox = get_node("TabContainer/Video/VBoxContainer/HBoxContainer/LeftCol/ShowFPS/ShowFPSOption")

onready var input_map_tree =  get_node("TabContainer/Controls/InputMapTree")
const ACTION_NAME_REMAPS_FILE = "res://System/Data/action_name_remaps.json"
const MOUSE_BUTTON_REMAPS_FILE = "res://System/Data/mouse_button_remaps.json"
var action_name_remaps
var mouse_button_remaps

var remapping_input = false

const FORBIDDEN_REMAP_EVENTS = [InputEventJoypadMotion, InputEventMouseMotion, InputEventMouseButton]

func _ready():
	# MSAA settings
	$TabContainer/Video/VBoxContainer/HBoxContainer/LeftCol.add_constant_override("separation", 25)
	$TabContainer/Video/VBoxContainer/HBoxContainer/RightCol.add_constant_override("separation", 25)
	var file = File.new()
	file.open(ACTION_NAME_REMAPS_FILE, File.READ)
	action_name_remaps = parse_json(file.get_as_text())
	
	file.close()
	file.open(MOUSE_BUTTON_REMAPS_FILE, File.READ)
	mouse_button_remaps = parse_json(file.get_as_text())
	
	set_process_input(true)
	
func _input(event):
	if remapping_input:
		for forbidden_event in FORBIDDEN_REMAP_EVENTS:
			if event is forbidden_event:
				return
		if event is InputEventKey:
			if event.scancode == KEY_ESCAPE:
				cancel_input_remap()
				get_tree().set_input_as_handled()
				return
		var item = input_map_tree.get_selected()
		var meta = item.get_metadata(0)
		if meta:
			cancel_input_remap()
			meta["event"] = event
			item.set_text(0, event2str(event))
			item.set_metadata(0, meta)

func init_video_settings():
	# MSAA settings
	msaa_option_button.select(EROSettings.msaa)
	show_fps_option_checkbox.pressed = EROSettings.show_fps
	fxaa_option_checkbox.pressed = EROSettings.fxaa
func init_input_settings():
	var root = input_map_tree.create_item()
	input_map_tree.set_hide_root(true)
	for action in InputMap.get_actions():
		if action_name_remaps.has(action):
			var item = input_map_tree.create_item(root)
			item.set_text(0, action_name_remaps[action])
			item.set_metadata(0, {"action": action})
			for input_event in InputMap.get_action_list(action):
				var action_item = input_map_tree.create_item(item)
				action_item.set_metadata(0, {"event": input_event})
				action_item.set_text(0, event2str(input_event))
	
func confirmed():
	EROSettings.msaa = msaa_option_button.selected
	EROSettings.show_fps = show_fps_option_checkbox.pressed
	EROSettings.save_settings()
	save_input()

func about_to_show():
	cancel_input_remap()
	init_video_settings() 
	init_input_settings()


func input_item_double_clicked():
	input_map_tree.get_selected().set_text(0, "Press a key or press ESC to cancel...")
	remapping_input = true
func cancel_input_remap():
	remapping_input = false
	var item = input_map_tree.get_selected()
	if item:
		if item.get_metadata(0).has("event"):
			var event = item.get_metadata(0)["event"]
			item.set_text(0, event2str(event))
	
func save_input():
	var tree_root = input_map_tree.get_root()
	var action_item = tree_root.get_children()
	while action_item != null:
		var action_name = action_item.get_metadata(0)["action"]
		InputMap.erase_action(action_name)
		InputMap.add_action(action_name)

		var event_item = action_item.get_children()
		while event_item:
			var meta = event_item.get_metadata(0)
			if meta:
				InputMap.action_add_event(action_name ,meta["event"])
			event_item = event_item.get_next()
			
		action_item = action_item.get_next()
	EROInputSettings.save_input()
	
func event2str(event):
	if event is InputEventMouseButton:
		return mouse_button_remaps[str(event.button_index)]
	else:
		return event.as_text()

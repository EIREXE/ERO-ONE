extends ConfirmationDialog

# TODO: Figure out how FXAA works

onready var msaa_option_button = get_node("TabContainer/Video/VBoxContainer/HBoxContainer/LeftCol/MSAA/MSAAOption")
onready var fxaa_option_checkbox = get_node("TabContainer/Video/VBoxContainer/HBoxContainer/LeftCol/FXAA/FXAAOption")
onready var show_fps_option_checkbox = get_node("TabContainer/Video/VBoxContainer/HBoxContainer/LeftCol/ShowFPS/ShowFPSOption")

onready var input_map_tree =  get_node("TabContainer/Controls/VSplitContainer/InputMapTree")

onready var user_alert_dialog = get_node("UserAlertDialog")

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
				return
				
		# Check if input is already in use...
				
		for action in InputMap.get_actions():
			if InputMap.action_has_event(action, event):
				
				get_tree().set_input_as_handled()
				user_alert_dialog.dialog_text = "Key %s is already in use by %s" % [event2str(event), beautify_action(action)]
				user_alert_dialog.popup()
				
				cancel_input_remap()
				
				
				return
				
				
		var item = input_map_tree.get_selected()
		var meta = item.get_metadata(0)
		if meta:
			get_tree().set_input_as_handled()
			meta["event"] = event
			item.set_text(0, event2str(event))
			item.set_metadata(0, meta)
			cancel_input_remap()
func init_video_settings():
	# MSAA settings
	msaa_option_button.select(EROSettings.msaa)
	show_fps_option_checkbox.pressed = EROSettings.show_fps
	fxaa_option_checkbox.pressed = EROSettings.fxaa
func init_input_settings():
	input_map_tree.clear()
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
	save_input()
	EROSettings.save_settings()


func about_to_show():
	cancel_input_remap()
	init_video_settings()
	init_input_settings()
	print("reinit")


func input_item_double_clicked():
	input_map_tree.get_selected().set_text(0, "Press a key or press ESC to cancel...")
	remapping_input = true
func cancel_input_remap():
	remapping_input = false
	var item = input_map_tree.get_selected()
	if item:
		if item.get_metadata(0).has("event"):
			var event = item.get_metadata(0)["event"]
			if event:
				item.set_text(0, event2str(event))
			else:
				item.free()
	
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
		
func add_action():
	var item = input_map_tree.get_selected()
	if item:
		if is_item_action(item):
			item.deselect(0)
			var new_item = input_map_tree.create_item(item)
			new_item.select(0)
			new_item.set_metadata(0, {"event": null})
			input_item_double_clicked()
		
func beautify_action(action):
	if action_name_remaps.has(action):
		return action_name_remaps[action]
	else:
		return action
		
func is_item_action(item):
	if item.get_metadata(0):
		return item.get_metadata(0).has("action")
	else:
		return false
		
func is_item_event(item):
	if item.get_metadata(0):
		return item.get_metadata(0).has("event")
	else:
		return false
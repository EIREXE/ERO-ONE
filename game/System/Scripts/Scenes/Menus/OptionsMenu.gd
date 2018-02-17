extends ConfirmationDialog

onready var msaa_option_button = get_node("TabContainer/Video/VBoxContainer/HBoxContainer/LeftCol/MSAA/MSAAOption")
onready var input_map_tree =  get_node("TabContainer/Controls/InputMapTree")
const ACTION_NAME_REMAPS_FILE = "res://System/Data/action_name_remaps.json"
const MOUSE_BUTTON_REMAPS_FILE = "res://System/Data/mouse_button_remaps.json"
var action_name_remaps
var mouse_button_remaps
func _ready():
	# MSAA settings
	$TabContainer/Video/VBoxContainer/HBoxContainer/LeftCol.add_constant_override("separation", 50)
	var file = File.new()
	file.open(ACTION_NAME_REMAPS_FILE, File.READ)
	action_name_remaps = parse_json(file.get_as_text())
	
	file.close()
	file.open(MOUSE_BUTTON_REMAPS_FILE, File.READ)
	mouse_button_remaps = parse_json(file.get_as_text())

func init_video_settings():
	# MSAA settings
	msaa_option_button.select(EROSettings.msaa)
	
func init_input_settings():
	var root = input_map_tree.create_item()
	input_map_tree.set_hide_root(true)
	for action in InputMap.get_actions():
		if action_name_remaps.has(action):
			var item = input_map_tree.create_item()
			item.set_text(0, action_name_remaps[action])
			
			for input_event in InputMap.get_action_list(action):
				var action_item = input_map_tree.create_item(item)
				if input_event is InputEventMouseButton:
					action_item.set_text(0, mouse_button_remaps[str(input_event.button_index)])
				else:
					action_item.set_text(0, input_event.as_text())
	
func confirmed():
	EROSettings.msaa = msaa_option_button.selected
	EROSettings.save_settings()

func about_to_show():
	init_video_settings() 
	init_input_settings()

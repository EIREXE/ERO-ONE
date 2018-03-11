extends Node

var input_config_path = "user://Config/input.json"

func _ready():
	var file = File.new()
	if file.file_exists(input_config_path):
		load_input()
		save_input()
	else:
		save_input()

func load_input(path=input_config_path):
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var content = JSON.parse(file.get_as_text()).result
		for action in content:
			InputMap.erase_action(action)
			InputMap.add_action(action)
			for event in content[action]:
				InputMap.action_add_event(action, str2var(event))
		return OK
	else:
		return FAILED
		
func save_input(path=input_config_path):
	var input_config = {}
	for action in InputMap.get_actions():
		input_config[action] = []
		for input_event in InputMap.get_action_list(action):
			input_config[action].append(var2str(input_event))
	var file = File.new()
	file.open(path, File.WRITE_READ)
	file.store_string(to_json(input_config))
	file.close()
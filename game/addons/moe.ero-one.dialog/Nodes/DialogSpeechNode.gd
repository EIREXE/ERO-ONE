tool
extends "EROTreeNode.gd"

var input_area

var character_option_button

var is_initialized = false


func to_dict():
	var dict = {
		text=input_area.text,
		selected_character=character_option_button.get_selected_id()
	}
	return dict
	
func from_dict(dict):
	add_ui_elements()
	input_area.text = dict["text"]
	print("SELECTING %d" % dict["selected_character"])
	character_option_button.select(dict["selected_character"])

func _ready():
	set_slot(0, true, TYPE_NIL, Color(1.0,1.0,1.0), true, TYPE_NIL, Color(1.0,1.0,1.0))
	
	if not is_initialized:
		add_ui_elements()

	title = "Speech"

func add_ui_elements():
	
	is_initialized = true
	
	for child in get_children():
		remove_child(child)
		
	var options_container = VBoxContainer.new()
	options_container.margin_bottom = 100
	
	character_option_button = OptionButton.new()

	character_option_button.add_item("Player", 0)
	
	character_option_button.add_item("NPC1", 1)
	
	character_option_button.add_item("NPC2", 2)
	
	options_container.add_child(character_option_button)
		
	input_area = LineEdit.new()
	input_area.size_flags_horizontal = SIZE_EXPAND_FILL
	input_area.size_flags_vertical = SIZE_EXPAND_FILL
	input_area.rect_min_size = Vector2(200,0)
	
	character_option_button.connect("item_selected",self, "on_node_update")
	input_area.connect("text_changed",self, "on_node_update")
	add_child(options_container)
	add_child(input_area)
	
func on_node_update(a=null):
	emit_signal("on_node_update")
	
static func get_dialog_node_type():
	return "SpeechNode"
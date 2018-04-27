tool
extends "EROTreeNode.gd"

func to_dict():
	var dict = {
		offset=offset
	}
	return dict
	
func from_dict(dict):
	offset = dict["offset"]

func _ready():
	set_slot(0, false, TYPE_NIL, Color(1.0,1.0,1.0), true, TYPE_NIL, Color(1.0,1.0,1.0))
	add_child(Control.new()) # HACK: the engine won't show the connections unless we have a child, honestly what are we doing here?
	rect_min_size = Vector2(0, 40)
	title = "Input"

static func get_dialog_node_type():
	return "InputNode"
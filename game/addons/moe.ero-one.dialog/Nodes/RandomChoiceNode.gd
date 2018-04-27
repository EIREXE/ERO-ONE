tool
extends "EROTreeNode.gd"

func _init():
	allows_multinode = true

func to_dict():
	pass
func from_dict(dict):
	pass

func _ready():
	set_slot(0, true, TYPE_NIL, Color(1.0,1.0,1.0), true, TYPE_NIL, Color(1.0,1.0,1.0))
	add_child(Label.new())
	title = "Random"
static func get_dialog_node_type():
	return "Random Choice"
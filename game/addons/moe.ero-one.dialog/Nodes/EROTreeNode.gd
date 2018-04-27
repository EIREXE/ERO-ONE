tool
extends GraphNode

signal on_node_update

var allows_multinode = false


func _ready():
	connect("offset_changed", self, "emit_signal", ["on_node_update"])

func to_dict():
	pass
func from_dict(dict):
	pass
	
static func get_dialog_node_type():
	return "Tree Node"
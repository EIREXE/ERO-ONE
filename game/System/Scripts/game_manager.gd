extends Node

const VERSION = {
	"name": "ERO-ONE",
	"major": 0,
	"minor": 1,
	"status": "alpha"
}

func _ready():
	EROResourceQueue.start()
	
	
func get_version_string():
	return "%s %d.%d %s" % [VERSION["name"], VERSION["major"], VERSION["minor"], VERSION["status"]]
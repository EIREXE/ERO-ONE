extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal marker_position_changed
signal new_marker

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_marker(marker):
	
	emit_signal("new_marker", marker)
	
func delete_marker(marker):
	print("DELETING MARKER")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

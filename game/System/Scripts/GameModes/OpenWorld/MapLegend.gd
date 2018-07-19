extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_marker(marker):
	$VBoxContainer/HBoxContainer/Label.text = marker.get_marker_type_data()["name"]
	$VBoxContainer/HBoxContainer/TextureRect.texture = marker.get_marker_icon()
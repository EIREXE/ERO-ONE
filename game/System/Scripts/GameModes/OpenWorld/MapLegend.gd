extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_marker(marker_data):
	$VBoxContainer/HBoxContainer/Label.text = marker_data["name"]
	$VBoxContainer/HBoxContainer/TextureRect.texture = marker_data["icon"]
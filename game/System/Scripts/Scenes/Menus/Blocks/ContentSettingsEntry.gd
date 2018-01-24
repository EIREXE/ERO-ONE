extends VBoxContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func load_entry(pack_settings):
	$HBoxContainer/VBoxContainer/Title.text = pack_settings["name"]
	$HBoxContainer/VBoxContainer/Description.text = pack_settings["description"]
	$HBoxContainer/IsLoaded.pressed = true
	$HBoxContainer/IsLoaded.disabled = pack_settings["official"]
extends HBoxContainer

func load_entry(pack_settings):
	$VBoxContainer/Title.text = pack_settings["name"]
	$VBoxContainer/Description.text = pack_settings["description"]
	$IsLoaded.pressed = true
	$IsLoaded.disabled = pack_settings["official"]
extends Node

var game_mode

func _ready():
	pass # Replace with function body.

func change_game_mode_from_path(path):

	change_game_mode(load(path).instance())
	
func change_game_mode(new_game_mode):
	if game_mode:
		if game_mode.has_method("on_exit"):
			game_mode.on_exit()
		game_mode.queue_free()
		remove_child(game_mode)
	
	
	game_mode = new_game_mode
	add_child(game_mode)
	
	if game_mode.has_method("on_enter"):
		game_mode.on_enter()
extends Node

signal show_game_ui
signal hide_game_ui

var _exempted_scenes = ["res://Scenes/Menus/"]

onready var options_menu = get_node("CanvasLayer/OptionsMenu")

func _ready():
	hide_overlayed_menus()
	set_process_input(true)
func _input(event):
	var is_paused = get_tree().is_paused()
	if event.is_action_pressed("pause") and not event.is_echo():
		if is_paused:
			if not EROFreeCamera.is_enabled():
				unpause_game()
				show_game_ui()
		else:
			pause_game()
			hide_game_ui()
			
func show_pause_menu():
	$CanvasLayer/PauseMenu.show()

func hide_overlayed_menus():
	$CanvasLayer/PauseMenu.hide()
	
func pause_game():
	for _exempted_scene in _exempted_scenes:
		if _exempted_scene in EROSceneLoader._scene_path:
			return
	get_tree().set_pause(true)
	show_pause_menu()
	
func unpause_game():
	get_tree().set_pause(false)
	hide_overlayed_menus()
	show_game_ui()

func _on_FreeCameraModeButton_pressed():
	EROFreeCamera.enable_free_camera()

func hide_game_ui():
	emit_signal("hide_game_ui")
func show_game_ui():
	emit_signal("show_game_ui")
	
func popup_options():
	options_menu.popup()
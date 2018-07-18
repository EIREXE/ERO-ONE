extends Node

signal show_game_ui
signal hide_game_ui

signal on_unpause
signal on_pause

var _exempted_scenes = ["res://Scenes/Menus/"]

onready var options_menu = get_node("CanvasLayer/OptionsMenu")
onready var dialog_renderer = get_node("ERODialogRenderer")
func _ready():
	hide_overlayed_menus()
	set_process_input(true)
	set_process(true)
	
func _process(delta):
	if EROSettings.show_fps:
		$CanvasLayer/FPSLabel.text = str(Engine.get_frames_per_second())
	else:
		$CanvasLayer/FPSLabel.text = ""
	

	
	
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
	pass
	#$CanvasLayer/PauseMenu.show()
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_overlayed_menus():
	pass
	#$CanvasLayer/PauseMenu.hide()
	
func pause_game():
	for _exempted_scene in _exempted_scenes:
		if _exempted_scene in EROSceneLoader._scene_path:
			return
	get_tree().set_pause(true)
	show_pause_menu()
	emit_signal("on_pause")
	
func show_dialog_renderer():
	dialog_renderer.show()
	
func hide_dialog_renderer():
	dialog_renderer.hide()
	
	
func unpause_game():
	get_tree().set_pause(false)
	hide_overlayed_menus()
	show_game_ui()
	emit_signal("on_unpause")

func _on_FreeCameraModeButton_pressed():
	EROFreeCamera.enable_free_camera()

func hide_game_ui():
	emit_signal("hide_game_ui")
func show_game_ui():
	emit_signal("show_game_ui")
	
func popup_options():
	options_menu.popup()
extends Node2D

func _ready():
	$CanvasLayer/ActualPauseMenu.visible = false
	set_process_input(true)
func _input(event):
	var is_paused = get_tree().is_paused()
	if event.is_action_pressed("pause"):
		if is_paused:
			if not EROFreeCamera.is_enabled():
				unpause_game()
		else:
			pause_game()
			
func show_pause_menu():
	$CanvasLayer/ActualPauseMenu.visible = true

func hide_pause_menu():
	$CanvasLayer/ActualPauseMenu.visible = false
	
func pause_game():
	get_tree().set_pause(true)
	show_pause_menu()
	
func unpause_game():
	get_tree().set_pause(false)
	hide_pause_menu()

func _on_FreeCameraModeButton_pressed():
	EROFreeCamera.enable_free_camera()

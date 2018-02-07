# Custom loading with loading screen and stuff, sounds fun? it kinda is.
extends Node

var _scene_path
var _scene_packed

func _ready():
	EROLoadingScreen.hide() # Ensure this is hidden
	set_process(false)
func _process(delta):
	if EROResourceQueue.is_ready(_scene_path):
		# change_scene_to is the future
		_scene_packed = EROResourceQueue.get_resource(_scene_path)
		get_tree().change_scene_to(_scene_packed)
		EROLoadingScreen.hide()
		set_process(false)
	else:
		EROLoadingScreen.set_progress(EROResourceQueue.get_progress(_scene_path))
func change_scene(scene_path, loading_screen=true):
	_scene_path = scene_path
	EROResourceQueue.queue_resource(scene_path)
	set_process(true)
	if loading_screen:
		EROLoadingScreen.show()
# Custom loading with loading screen and stuff, sounds fun? it kinda is.
extends Node

var _scene_path = ""
var _current_scene

var _current_scene_args
var _scene_packed

const LOADING_SCREEN_SCENE = preload("res://System/Scenes/Menus/LoadingScreen.tscn")

var loading_screen

func _ready():
	
	loading_screen = LOADING_SCREEN_SCENE.instance()
	loading_screen.hide() # Ensure this is hidden
	add_child(loading_screen)
	set_process(false)

func _process(delta):
	if EROResourceQueue.is_ready(_scene_path):
		# change_scene_to is the future
		_scene_packed = EROResourceQueue.get_resource(_scene_path)
		if _scene_packed:
			_current_scene = _scene_packed.instance()
			
		get_tree().get_root().add_child(_current_scene)
		
		for function in _current_scene_args:
			var args = _current_scene_args[function]
			_current_scene.callv(function, args)
			
		loading_screen.hide()
		set_process(false)
	else:
		loading_screen.set_progress(EROResourceQueue.get_progress(_scene_path))
		
func change_scene(scene_path, show_loading_screen=true, args=null):
	_scene_path = scene_path
	_current_scene_args = args
	if _current_scene:
		_current_scene.queue_free()
		
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
		
	EROResourceQueue.queue_resource(scene_path)
	set_process(true)
	if show_loading_screen:
		loading_screen.show()
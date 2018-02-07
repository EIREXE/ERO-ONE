extends CanvasLayer

onready var version_label = get_node("VersionLabel")

const EDITOR_SCENE_PATH = "res://System/Scenes/Editor/Editor.tscn"

func _ready():
	set_version_label()
	
func set_version_label():
	version_label.text = game_manager.get_version_string()

func load_character_editor():
	EROSceneLoader.change_scene(EDITOR_SCENE_PATH)
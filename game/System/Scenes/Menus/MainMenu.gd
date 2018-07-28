extends CanvasLayer

onready var version_label = get_node("VersionLabel")

const EDITOR_SCENE_PATH = "res://System/Scenes/Editor/Editor.tscn"
const CONTENT_ENTRY_SCENE = preload("res://System/Scenes/Menus/Blocks/ContentEntry.tscn")
func _ready():
	set_version_label()
	populate_content_list()
	$ContentSettingsPanel.hide()
	$ServiceMenu.hide()
func set_version_label():
	version_label.text = game_manager.get_version_string()

func load_character_editor():
	EROSceneLoader.change_scene(EDITOR_SCENE_PATH, true, {"load_body": ["BaseContent.Bodies.Female"]})
	
func populate_content_list():
	for content_pack_name in EROContent.get_all_content_packs():
		var pack = EROContent.get_all_content_packs()[content_pack_name]
		var content_entry = CONTENT_ENTRY_SCENE.instance()
		content_entry.load_entry(pack)
		$ContentSettingsPanel/ScrollContainer/VBoxContainer2.add_child(content_entry)

func _on_ContentSettingsButton_pressed():
	$ContentSettingsPanel.visible = !$ContentSettingsPanel.visible

func quit_game():
	get_tree().quit()

func _on_SettingsButton_pressed():
	EROOverlayedMenus.popup_options()
	pass


func _on_ServiceMenuButton_pressed():
	$ServiceMenu.show()

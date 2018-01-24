extends Node

const CONTENT_ENTRY_SCENE = preload("res://System/Scenes/Menus/Blocks/ContentSettingsEntry.tscn")

func _ready():
	for content_pack_name in EROContent.content_packs:
		var pack = EROContent.content_packs[content_pack_name]
		var content_entry = CONTENT_ENTRY_SCENE.instance()
		content_entry.load_entry(pack)
		$CanvasLayer/Panel/ScrollContainer.add_child(content_entry)
extends "res://System/Scripts/Scenes/Menus/EROGameUI.gd"
onready var sprite = get_node("ViewportContainer/MinimapViewport/Sprite3D")

export(NodePath) var renderer

func _ready():
	sprite.texture = get_node(renderer).get_texture()

func _process(delta):
	var player = EROGameModeManager.game_mode.player

	var camera_gimball = player.character.camera_gimball_base
	var rotation = camera_gimball.global_transform.basis.get_euler()
	sprite.rotation.z = -(rotation.y)
	
	get_node(renderer).get_node("RoadRenderer").set_origin(player.global_transform.origin)
extends "res://System/Scripts/Scenes/Menus/EROGameUI.gd"
onready var sprite = get_node("ViewportContainer/MinimapViewport/Sprite3D")

export(NodePath) var renderer

func _ready():
	set_process(false)
	EROOpenWorld.connect("open_world_ready", self, "open_world_ready")

func open_world_ready():
	set_process(true)
	sprite.texture = get_node(renderer).get_texture()

func _process(delta):
	var player = EROOpenWorld.player
	

	
	var camera_gimball = player.character.camera_gimball_base
	var rotation = camera_gimball.global_transform.basis.get_euler()
	sprite.rotation.z = -(rotation.y)
	
	get_node(renderer).set_origin(player.global_transform.origin)
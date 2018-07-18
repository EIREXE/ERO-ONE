tool
extends Control

export(Texture) var sprite_texture setget set_sprite_texture 
var sprite_rotation setget set_sprite_rotation
class_name MinimapLocation

var sprite

# Called when the node enters the scene tree for the first time.
func _init():
	sprite = TextureRect.new()
	var center_container = CenterContainer.new()
	center_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	add_child(center_container)
	center_container.add_child(sprite)
	
func set_position_centered(position):
	rect_position = position - rect_size / 2

func set_sprite_texture(value):
	sprite_texture = value
	sprite.texture = value

func set_sprite_rotation(value):
	sprite_rotation = value
	sprite.rotation = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends Spatial

signal open_world_ready

var player setget set_player

func set_player(value):
	player = value
	print("OPEN WORLD IS ON STARTUP")
	init()

func init():
	emit_signal("open_world_ready")

func _ready():
	pass
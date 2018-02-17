# This node should be parent of all game UI nodes
# this way when pausing the game this hides too

extends Control

func _ready():
	EROOverlayedMenus.connect("show_game_ui", self, "show")
	EROOverlayedMenus.connect("hide_game_ui", self, "hide")
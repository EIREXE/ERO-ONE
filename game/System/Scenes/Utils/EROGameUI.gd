extends Control

class_name EROGameUI

func _ready():
	EROOverlayedMenus.connect("show_game_ui", self, "show")
	EROOverlayedMenus.connect("hide_game_ui", self, "hide")
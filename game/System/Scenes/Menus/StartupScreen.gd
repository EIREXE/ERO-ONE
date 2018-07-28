extends CanvasLayer

const MAIN_MENU_SCENE = preload("res://System/Scenes/Menus/MainMenu.tscn")

func _ready():
	$AnimationPlayer.play("fade")

func finish_fade():
	get_tree().change_scene_to(MAIN_MENU_SCENE)
	
# For impacient folks
func _input(event):
	if event is InputEventKey:
		finish_fade()
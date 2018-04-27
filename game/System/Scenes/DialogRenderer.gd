extends Node

onready var character_renderer = get_node("CanvasLayer/DialogRenderer/ViewportContainer/Viewport/EROCharacterRenderer")
onready var viewport = get_node("CanvasLayer/DialogRenderer/ViewportContainer/Viewport")
onready var name_label = get_node("CanvasLayer/DialogRenderer/TextPanel/PanelName/NameLabel")
onready var text_label = get_node("CanvasLayer/DialogRenderer//TextPanel/Panel/TextLabel")

var target_text = ""

# THIS TWO MUST BE floats! COME ON GODOT!!!!
var current_position = 0.0
var DIALOG_SPEED_BASE = 15.0

func _ready():
	character_renderer.load_body("TestContent.Bodies.BodyTest")
	character_renderer.set_clothing_set("normal")
	character_renderer.add_item_async("TestContent.Clothing.ElfTop")
	character_renderer.add_item_async("TestContent.Clothing.ElfPanties")
	character_renderer.add_item_async("TestContent.Clothing.ElfBloomers")
	character_renderer.add_item_async("TestContent.Clothing.ElfSocks")
	character_renderer.add_item_async("TestContent.Clothing.ElfShoes")
	character_renderer.add_item_async("TestContent.Clothing.ElfSkirt")
	set_process(true)
	viewport.msaa = EROSettings.msaa
	character_renderer.connect("character_finished_loading", self, "on_character_finished_loading")

func _process(delta):
	# TODO: Implement customizable dialog speed
	if not current_position >= target_text.length():
		current_position += DIALOG_SPEED_BASE*delta
	else:
		current_position = target_text.length()
		set_process(false)
	text_label.text = target_text.substr(0, current_position)

func on_character_finished_loading():
	name_label.text = character_renderer.character_data["name"]

func show_text(text):
	target_text = text
	text_label.text = ""
	current_position = 0.0
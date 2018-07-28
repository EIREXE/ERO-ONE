extends Node

onready var character_renderer = get_node("CanvasLayer/DialogRenderer/ViewportContainer/Viewport/EROCharacterRenderer")
onready var viewport = get_node("CanvasLayer/DialogRenderer/ViewportContainer/Viewport")
onready var name_label = get_node("CanvasLayer/DialogRenderer/TextPanel/PanelName/NameLabel")
onready var text_label = get_node("CanvasLayer/DialogRenderer//TextPanel/Panel/TextLabel")
onready var visual_root = get_node("CanvasLayer/DialogRenderer")
var target_text = ""

# THIS TWO MUST BE floats! COME ON GODOT!!!!
var current_position = 0.0
var DIALOG_SPEED_BASE = 15.0

var is_writing_text = false

signal on_finish_displaying_text

func _ready():
	"""	character_renderer.load_body("TestContent.Bodies.BodyTest")
	character_renderer.set_clothing_set("normal")
	character_renderer.add_item_async("TestContent.Clothing.ElfTop")
	character_renderer.add_item_async("TestContent.Clothing.ElfPanties")
	character_renderer.add_item_async("TestContent.Clothing.ElfBloomers")
	character_renderer.add_item_async("TestContent.Clothing.ElfSocks")
	character_renderer.add_item_async("TestContent.Clothing.ElfShoes")
	character_renderer.add_item_async("TestContent.Clothing.ElfSkirt")"""
	viewport.msaa = EROSettings.msaa
	character_renderer.connect("character_finished_loading", self, "on_character_finished_loading")
	visual_root.hide()
	set_process(false)
func _process(delta):
	# TODO: Implement customizable dialog speed
	if current_position <= target_text.length():
		current_position += DIALOG_SPEED_BASE*delta
	else:
		current_position = target_text.length()

	
	text_label.text = target_text.substr(0, current_position)

func _unhandled_input(event):
	if event.is_action_pressed("dialog_skip"):
		if current_position <= target_text.length():
			current_position = target_text.length()
		else:
			emit_signal("on_finish_displaying_text")
			is_writing_text = false
		get_tree().set_input_as_handled()

func on_character_finished_loading():
	name_label.text = character_renderer.character_data["name"]

func show_text(text):
	set_process(true)
	is_writing_text = true
	target_text = text
	text_label.text = ""
	current_position = 0.0
	
	
func show():
	visual_root.show()
	
func hide():
	visual_root.hide()
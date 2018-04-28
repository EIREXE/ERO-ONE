extends KinematicBody

var vel = Vector3()

var dir = Vector3()

onready var camera_gimball_base = get_node("CharacterCamera")
onready var camera_gimball = get_node("CharacterCamera/CameraGimball")
onready var camera = get_node("CharacterCamera/CameraGimball/Camera")

const MAX_CAMERA_PITCH = 45

var input_movement_vector = Vector3()

var target_visual_direction = Vector3()

const ROTATION_SPEED = 8

onready var character_renderer = get_node("PivotPoint/EROCharacterRenderer")

onready var pivot_point = get_node("PivotPoint")

func _ready():
	capture_mouse()
	
	EROOverlayedMenus.connect("on_unpause", self, "capture_mouse")
	set_process_unhandled_input(true)
	set_physics_process(true)
	
	character_renderer.load_body("TestContent.Bodies.BodyTest")
	character_renderer.set_clothing_set("normal")
	character_renderer.add_item_async("TestContent.Clothing.ElfTop")
	character_renderer.add_item_async("TestContent.Clothing.ElfPanties")
	character_renderer.add_item_async("TestContent.Clothing.ElfBloomers")
	character_renderer.add_item_async("TestContent.Clothing.ElfSocks")
	character_renderer.add_item_async("TestContent.Clothing.ElfShoes")
	character_renderer.add_item_async("TestContent.Clothing.ElfSkirt")

func _physics_process(delta):
	# While character direction changes are instantenous input-wise, they are not when it comes to visuals
	# mainly because it looks terrible if done otherwise
	
	var new_transform = pivot_point.global_transform
	new_transform = new_transform.looking_at(pivot_point.global_transform.origin + target_visual_direction, Vector3(0,1,0))
	
	pivot_point.global_transform = pivot_point.global_transform.interpolate_with(new_transform, ROTATION_SPEED*delta)

func consume_input():
	input_movement_vector = Vector3()

func capture_mouse():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
func add_movement_input(input):
	input_movement_vector += input

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var rotation_y = event.get_relative().x * EROSettings.mouse_sensitivity
		camera_gimball_base.rotate_y(-rotation_y*get_process_delta_time())
		var rotation_x = event.get_relative().y * EROSettings.mouse_sensitivity
		camera_gimball.rotate_x(-rotation_x*get_process_delta_time())
		
		
		# Limit vertical rotation
		if abs(rad2deg(camera_gimball.rotation.x)) >= MAX_CAMERA_PITCH:
			camera_gimball.rotation.x = deg2rad(MAX_CAMERA_PITCH)*sign(camera_gimball.rotation.x)
			
			
func get_camera():
	return get_node("CharacterCamera/CameraGimball/Camera")
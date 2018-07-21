# Generic moving character

extends KinematicBody

var velocity = Vector3()

var input_direction = Vector3()

onready var camera_gimball_base = get_node("CharacterCamera")
onready var camera_gimball = get_node("CharacterCamera/CameraGimball")
onready var camera = get_node("CharacterCamera/CameraGimball/Camera")

const MAX_WALK_SPEED = 2.0 #m/s

const GRAVITY = -38.0

const MAX_CAMERA_PITCH = 45

var input_movement_vector = Vector3()

var target_visual_direction = Vector3()

const WALK_SPEED = 2.5 # Walk acceleration, in seconds per second

const FLOOR_DEACCELERATION = 16

const ROTATION_SPEED = 8

onready var character_renderer = get_node("PivotPoint/EROCharacterRenderer")

onready var pivot_point = get_node("PivotPoint")

var character_rotation_follows_input = true

func _ready():
	capture_mouse()
	
	EROOverlayedMenus.connect("on_unpause", self, "capture_mouse")
	set_process_unhandled_input(true)
	set_physics_process(true)
	
	character_renderer.load_body("BaseContent.Bodies.Female")
	character_renderer.set_clothing_set("normal")

func _physics_process(delta):
	 # Walking
	var horizontal_input_direction = Vector3(input_direction.x, 0, input_direction.z)
	
	horizontal_input_direction = horizontal_input_direction.normalized()
	
	velocity.y += delta*GRAVITY
	
	var horizontal_velocity = velocity
	horizontal_velocity.y = 0
	
	var target = input_direction
	target *= MAX_WALK_SPEED
	
	var new_acceleration
	if input_direction.dot(horizontal_velocity) > 0:
		new_acceleration = WALK_SPEED
	else:
		new_acceleration = FLOOR_DEACCELERATION
	
	horizontal_velocity = horizontal_velocity.linear_interpolate(target, new_acceleration*delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	velocity = move_and_slide(velocity,Vector3(0,1,0),true, 0.05, 4, deg2rad(45))
	
	# While character direction changes are instantenous input-wise, they are not when it comes to visuals
	# mainly because it looks terrible if done otherwise
	
	var new_transform = pivot_point.global_transform
	#new_transform = new_transform.looking_at(pivot_point.global_transform.origin + horizontal_input_direction, Vector3(0,1,0))
	
	if new_transform != pivot_point.global_transform:
		pivot_point.global_transform = pivot_point.global_transform.interpolate_with(new_transform, ROTATION_SPEED*delta)
	
	input_direction = Vector3()
	


func consume_input():
	input_movement_vector = Vector3()

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func add_movement_input(input):
	input_direction += input

func _input(event):
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
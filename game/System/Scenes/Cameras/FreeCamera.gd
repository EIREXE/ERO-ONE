extends KinematicBody

var old_camera

var free_camera_exp = 1

var screenshot_directory = "user://Screenshots"

var _original_dof_strength
var _original_dof_distance
var _original_dof_enabled

onready var fov_slider = $CanvasLayer/FreeCameraMenu/ScrollContainer/Container/FOVContainer/FOVSlider
onready var fov_label = $CanvasLayer/FreeCameraMenu/ScrollContainer/Container/FOVContainer/FOVLabel

onready var dof_strength_slider = $CanvasLayer/FreeCameraMenu/ScrollContainer/Container/DofStrengthContainer/DofStrengthSlider
onready var dof_strength_label = $CanvasLayer/FreeCameraMenu/ScrollContainer/Container/DofStrengthContainer/DofStrengthLabel

onready var dof_distance_slider = $CanvasLayer/FreeCameraMenu/ScrollContainer/Container/DofDistanceContainer/DofDistanceSlider
onready var dof_distance_label = $CanvasLayer/FreeCameraMenu/ScrollContainer/Container/DofDistanceContainer/DofDistanceLabel

onready var roll_slider = $CanvasLayer/FreeCameraMenu/ScrollContainer/Container/RollContainer/RollSlider
onready var roll_label = $CanvasLayer/FreeCameraMenu/ScrollContainer/Container/RollContainer/RollLabel

onready var camera = $RotationGimball/Camera

var env

func _ready():
	set_process(false)
	set_process_unhandled_input(false)
	$CanvasLayer/FreeCameraMenu/HintTextLabel.text = ""
	
	if not Directory.new().dir_exists(screenshot_directory):
		Directory.new().make_dir_recursive(screenshot_directory)
		
	$CanvasLayer/FreeCameraMenu.visible = false
	
func _register_CVARS():
	Console.register_cvar("free_camera_exp", {
		description = "Free camera multiplier",
		arg = ["free_camera_exp", TYPE_REAL],
		target = self
	})
	
func _process(delta):
	var basis = $RotationGimball/Camera.global_transform.basis
	
	var speed = Vector3()
	var camera_speed_multiplier = 1.0
	if Input.is_action_pressed("camera_fast"):
		camera_speed_multiplier = 0.1
	if Input.is_action_pressed("forward"):
		var new_forward_speed = -basis.z*EROSettings.free_camera_speed*camera_speed_multiplier
		speed += new_forward_speed
	elif Input.is_action_pressed("back"):
		var new_forward_speed = basis.z*EROSettings.free_camera_speed*camera_speed_multiplier
		speed += new_forward_speed
	if Input.is_action_pressed("left"):
		var new_side_speed = -basis.x*EROSettings.free_camera_speed*camera_speed_multiplier
		speed += new_side_speed
	elif Input.is_action_pressed("right"):
		var new_side_speed = basis.x*EROSettings.free_camera_speed*camera_speed_multiplier
		speed += new_side_speed
	if Input.is_action_pressed("up"):
		var new_side_speed = basis.y*EROSettings.free_camera_speed*camera_speed_multiplier
		speed += new_side_speed
	elif Input.is_action_pressed("down"):
		var new_side_speed = -basis.y*EROSettings.free_camera_speed*camera_speed_multiplier
		speed += new_side_speed
	move_and_slide(speed)


	update_ui()

func update_ui():
	dof_strength_label.text = str(env.dof_blur_far_amount)
	dof_distance_label.text = str(env.dof_blur_far_distance)
	fov_label.text = "%.2f" % fov_slider.value

func _input(event):
		# Camera movement
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_rotate"):
			var rotation_y = event.get_relative().x * EROSettings.mouse_sensitivity/2
			var rotation_x = event.get_relative().y * EROSettings.mouse_sensitivity/2
			$RotationGimball.rotate_x(-rotation_x*get_process_delta_time())
			rotate_y(-rotation_y*get_process_delta_time())
	if visible:
		if Input.is_action_pressed("pause"):
			disable_free_camera()
	if event is InputEventMouseButton:
		if Input.is_action_pressed("zoom_in"):
			var camera = $RotationGimball/Camera
			var new_fov = $RotationGimball/Camera.fov - 10*EROSettings.zoom_speed*free_camera_exp*get_process_delta_time()
			camera.fov = new_fov
			fov_slider.value = new_fov
		elif Input.is_action_pressed("zoom_out"):
			var camera = $RotationGimball/Camera
			var new_fov = $RotationGimball/Camera.fov + 10*EROSettings.zoom_speed*free_camera_exp*get_process_delta_time()
			camera.fov = new_fov
			fov_slider.value = new_fov 
func enable_free_camera():
	if get_world().environment:
		env = get_world().environment
	else:
		env = get_world().fallback_environment
	
	# Saving original values
	_original_dof_distance = env.dof_blur_far_distance
	_original_dof_enabled = env.dof_blur_far_enabled
	_original_dof_strength = env.dof_blur_far_amount
	
	# We are going to enable blur and set it to 0 strength, that way the user doesn't have to
	# enable it
	env.dof_blur_far_enabled = true
	env.dof_blur_far_quality = Environment.DOF_BLUR_QUALITY_HIGH
	env.dof_blur_far_amount = 0.0
	env.dof_blur_far_distance = 0.0
	
	old_camera = get_viewport().get_camera()

	
	# Inherit values from the old camera
	camera.make_current()
	camera.fov = old_camera.fov
	camera.keep_aspect = old_camera.keep_aspect
	camera.environment = old_camera.get_world().environment
	global_transform = old_camera.global_transform
	
	# Fov slider value isn't automatically updated, this is by design.
	fov_slider.value = camera.fov

	
	set_process(true)
	set_process_unhandled_input(true)
	get_tree().set_pause(true)
	
	visible = true
	$CanvasLayer/FreeCameraMenu.visible = true
	EROOverlayedMenus.hide_overlayed_menus()
	
func disable_free_camera():
	visible = false
	$CanvasLayer/FreeCameraMenu.visible = false
	set_process(false)
	set_process_unhandled_input(false)
	
	$RotationGimball/Camera.clear_current()
	$RotationGimball.set_rotation(Vector3())
	old_camera.make_current()
	EROOverlayedMenus.show_pause_menu()
	
	# Return the original DOF values to the environment
	env.dof_blur_far_distance = _original_dof_distance
	env.dof_blur_far_enabled = _original_dof_enabled
	env.dof_blur_far_amount = _original_dof_strength


	
func is_enabled():
	return visible

# Hint label updating...

func mouse_entered_bar_button(hint):
	$CanvasLayer/FreeCameraMenu/HintTextLabel.text = hint

func mouse_existed_bar_button():
	$CanvasLayer/FreeCameraMenu/HintTextLabel.text = ""


func take_screenshot():
	var date = OS.get_datetime()
	var file_name = "/%d_%d_%d_%d_%d_%d.png"
	file_name = file_name % [date["year"],date["month"], 
							date["day"], date["hour"], 
							date["minute"], date["second"]]
	$CanvasLayer/FreeCameraMenu.visible = false
	VisualServer.viewport_set_clear_mode(get_viewport().get_viewport_rid(),VisualServer.VIEWPORT_CLEAR_ONLY_NEXT_FRAME)
	# We have to wait two framess,  I don't know why
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	var image_path = screenshot_directory + file_name
	img.save_png(image_path)
	$CanvasLayer/FreeCameraMenu.visible = true
	
func change_fov( value ):
	camera.fov = value
	
func change_dof_strength( value ):
	env.dof_blur_far_amount = value
	
func change_dof_distance( value ):
	env.dof_blur_far_distance = value
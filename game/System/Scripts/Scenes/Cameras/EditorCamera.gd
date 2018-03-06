# ERO-ONE character editor camera code

extends Spatial

# Camera Limits
export var camera_min = 3.0
export var camera_max = 20.0

export var y_offset_max = 6
export var y_offset_min = 0

export var x_offset_max = 3
export var x_offset_min = -3

export var starting_y_offset = 1.0

export var starting_y_rotation = 35
export var starting_x_rotation = -20

export var zoom_level = 0.5

var zoom_target = zoom_level # This is what our zoom target is

# Defaults

var default_zoom_level = 7

func reset_camera():
	set_zoom(default_zoom_level)
	zoom_target = default_zoom_level
	set_offset(0,starting_y_offset)
	$RotationPivotInner.rotation.x = deg2rad(starting_x_rotation)
	rotation.y = deg2rad(starting_y_rotation)

func _ready():
	set_process_input(true)
	set_process(true)
	reset_camera()
	
func _process(delta):
	# Zoom interpolation, because we use the wheel by default zoom looks like shit if we didn't
	# interpolate it
	set_zoom(lerp(zoom_level, zoom_target, delta*10))
func _input(event):
	if Input.is_action_pressed("reset_camera"):
		reset_camera()
		
	if event is InputEventMouseMotion:
		# Camera movement
		if Input.is_action_pressed("camera_rotate"):
			var rotation_y = event.get_relative().x * EROSettings.mouse_sensitivity
			rotate_y(-rotation_y*get_process_delta_time())
			var rotation_x = event.get_relative().y * EROSettings.mouse_sensitivity
			$RotationPivotInner.rotate_x(-rotation_x*get_process_delta_time())
			
			# Limit vertical rotation
			if abs(rad2deg($RotationPivotInner.rotation.x)) >= 90:
				$RotationPivotInner.rotation.x = deg2rad(90)*sign($RotationPivotInner.rotation.x)
				
		if Input.is_action_pressed("camera_pan"):
			var y_offset = $RotationPivotInner.translation.y
			var x_offset = $RotationPivotInner.translation.x
			var new_y_offset = y_offset + (event.get_relative().y * EROSettings.mouse_sensitivity) * get_process_delta_time()
			var new_x_offset = x_offset - (event.get_relative().x * EROSettings.mouse_sensitivity) * get_process_delta_time()
			set_offset(new_x_offset, new_y_offset)
		if Input.is_action_pressed("camera_height"):
			var y_offset = $RotationPivotInner.translation.y
			var x_offset = $RotationPivotInner.translation.x
			var new_y_offset = y_offset - (event.get_relative().y * EROSettings.mouse_sensitivity) * get_process_delta_time()
			set_offset(x_offset, new_y_offset)
			
	if event is InputEventMouseButton:
		var zoom_difference = Vector3(EROSettings.mouse_sensitivity,EROSettings.mouse_sensitivity,EROSettings.mouse_sensitivity)
		if event.is_action("zoom_in"):
			zoom_target = zoom_level-(EROSettings.zoom_speed*15.0*get_process_delta_time())
		elif event.is_action("zoom_out"):
			zoom_target = zoom_level+(EROSettings.zoom_speed*15.0*get_process_delta_time())

func set_zoom(level):
	zoom_level = level
	var camera_translation = $RotationPivotInner/Camera.translation
	var normalized = camera_translation.normalized()
	var translation_result = normalized*level
	
	# Ensures camera distance is always over or at the camera minimum
	if translation_result.length() < camera_min:
		$RotationPivotInner/Camera.translation = normalized*camera_min
		zoom_level = camera_min
	elif translation_result.length() > camera_max:
		$RotationPivotInner/Camera.translation = normalized*camera_max
		zoom_level = camera_max
	else:
		$RotationPivotInner/Camera.translation = translation_result
		
# Mainly used for panning
func set_offset(x_offset, y_offset):
	
	# Y offset and checks
	if y_offset > y_offset_max:
		$RotationPivotInner.translation.y = y_offset_max
	elif y_offset < y_offset_min:
		$RotationPivotInner.translation.y = y_offset_min
	else:
		$RotationPivotInner.translation.y = y_offset
	
	# X offset and checks
	if x_offset > x_offset_max:
		$RotationPivotInner.translation.x = x_offset_max
	elif x_offset < x_offset_min:
		$RotationPivotInner.translation.x = x_offset_min
	else:
		$RotationPivotInner.translation.x = x_offset
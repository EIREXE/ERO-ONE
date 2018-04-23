extends Spatial

onready var character = get_node("EROCharacter")



func _ready():
	set_process(true)

func _process(delta):
	var input_movement_vector = Vector3()
	
	input_movement_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	input_movement_vector.z = Input.get_action_strength("forward") - Input.get_action_strength("back")
		
	input_movement_vector = input_movement_vector.normalized()
	
	character.add_movement_input(input_movement_vector)
	
	var buttons = get_tree().get_nodes_in_group("Buttons")
	
	var closest_button_to_screen_center
	for button in buttons:
		if not button.is_disabled:
			if not button.is_visible_on_screen():
				continue
				
			var screen_center = get_viewport().size / 2
			
			var distance_to_center = character.get_camera().unproject_position(button.translation) - screen_center
			distance_to_center = distance_to_center.length()
			

			
			var distance_to_button = button.global_transform.origin - character.global_transform.origin
			
			distance_to_button = distance_to_button.length()
			
			
			if distance_to_button <= button.max_distance:
				if closest_button_to_screen_center:
					# If we already have an existing button compare our distance to screen center
					
					var closest_distance_to_center = character.get_camera().unproject_position(closest_button_to_screen_center.translation) - screen_center
					closest_distance_to_center = closest_distance_to_center.length()
					
					if distance_to_center < closest_distance_to_center:
						closest_button_to_screen_center = button
				else:
					closest_button_to_screen_center = button
	
	# disable the rest
		
	for button in buttons:
		if button != closest_button_to_screen_center:
			if button.is_deployed:
				button.undeploy()
			
	if closest_button_to_screen_center:
		
		if not closest_button_to_screen_center.is_deployed:
			closest_button_to_screen_center.deploy()
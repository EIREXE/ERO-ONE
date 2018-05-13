extends "res://System/Scenes/World/Character/Scripts/states/BaseState/BaseState.gd"

var target_facing

func get_FSM(): return fsm; #defined in parent class
func get_logic_root(): return logic_root; #defined in parent class 

func state_init(args = null):
	.state_init()


const WALK_SPEED = 1

const ROTATION_SPEED = 5

var rotation_interp_value = 0

var last_dir = Vector3()

#when entering state, usually you will want to reset internal state here somehow
func enter(from_state = null, from_transition = null, args = []):
	.enter(from_state, from_transition, args)
	#rotation_interp_value = 0
	#last_dir = Vector3()

#when updating state, paramx can be used only if updating fsm manually
func update(delta, args=null):
	
	var cam_xform = logic_root.get_camera().get_global_transform()

	var input_direction = Vector3()

	input_direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	input_direction.z = Input.get_action_strength("forward") - Input.get_action_strength("back")

	var movement_input = Vector3()
	movement_input += -cam_xform.basis.z.normalized() * input_direction.z
	movement_input += cam_xform.basis.x.normalized() * input_direction.x
	
	movement_input.y = 0
	

	
	
	logic_root.add_movement_input(movement_input)
	
	# While character direction changes are instantenous input-wise, they are not when it comes to visuals
	# mainly because it looks terrible if done otherwise

	var target_visual_direction = movement_input.normalized()
	
	# Make input change the movement direciton
	
	 #logic_root.dir += input_world_direction*(WALK_SPEED*delta)
	#logic_root.target_visual_direction = target_visual_direction
	.update(delta, args)
#when exiting state
func exit(to_state=null):
	.exit(to_state)

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
	rotation_interp_value = 0
	last_dir = Vector3()

#when updating state, paramx can be used only if updating fsm manually
func update(delta, args=null):
	
	var cam_xform = logic_root.get_camera().get_global_transform()

	var movement_vector = logic_root.input_movement_vector.normalized()

	var input_world_direction = Vector3()
	input_world_direction += -cam_xform.basis.z.normalized() * movement_vector.z
	input_world_direction += cam_xform.basis.x.normalized() * movement_vector.x
	
	input_world_direction.y = 0
	
	# While character direction changes are instantenous input-wise, they are not when it comes to visuals
	# mainly because it looks terrible if done otherwise

	var target_visual_direction = input_world_direction
	
	# Make input change the movement direciton
	
	logic_root.dir += input_world_direction*(WALK_SPEED*delta)
	logic_root.target_visual_direction = target_visual_direction
	.update(delta, args)
#when exiting state
func exit(to_state=null):
	.exit(to_state)

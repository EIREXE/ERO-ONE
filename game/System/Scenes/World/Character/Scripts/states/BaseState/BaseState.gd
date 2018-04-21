extends "res://addons/moe.ero-one.fsm/content/FSMState.gd"

var gravity_enabled = true

const GRAVITY = -23.0


const MAX_SPEED = 2 # m/s

const MOVEMENT_SPEED = 2

const ACCELERATION = 2.5

const DEACCELERATION = 16

const MAX_SLOPE_ANGLE = 40



const ACCEL = 4.5

const DEACCEL = 16

func get_FSM(): return fsm; #defined in parent class
func get_logic_root(): return logic_root; #defined in parent class 

func state_init(args = null):
	.state_init()

#when entering state, usually you will want to reset internal state here somehow
func enter(from_state = null, from_transition = null, args = []):
	.enter(from_state, from_transition, args)
	
#when updating state, paramx can be used only if updating fsm manually
func update(delta, args=null):
	.update(delta, args)
	
	 # Walking

	var cam_xform = logic_root.get_camera().get_global_transform()
	

	
	logic_root.dir.y = 0
	logic_root.dir = logic_root.dir.normalized()
	
	logic_root.vel.y += delta*GRAVITY
	
	var hvel = logic_root.vel
	hvel.y = 0
	
	var target = logic_root.dir
	target *= MAX_SPEED
	
	var accel
	if logic_root.dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel*delta)
	logic_root.vel.x = hvel.x
	logic_root.vel.z = hvel.z
	logic_root.vel = logic_root.move_and_slide(logic_root.vel,Vector3(0,1,0),true, 0.05, 4, deg2rad(45))
	
	logic_root.consume_input()
	logic_root.dir = Vector3()
	#logic_root.velocity = get_logic_root().move_and_slide(velocity,Vector3(0,1,0), false, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	#logic_root.movement_velocity = Vector3()
#when exiting state
func exit(to_state=null):
	.exit(to_state)

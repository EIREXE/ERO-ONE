extends "res://addons/moe.ero-one.fsm/content/FSMState.gd"

var gravity_enabled = true

const GRAVITY = -23.0


const MAX_SPEED = 2 # m/s

const MOVEMENT_SPEED = 2

const FLOOR_ACCELERATION = 2.5

const FLOOR_DEACCELERATION = 16

const MAX_SLOPE_ANGLE = 40

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
	

	#logic_root.velocity = get_logic_root().move_and_slide(velocity,Vector3(0,1,0), false, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	#logic_root.movement_velocity = Vector3()
#when exiting state
func exit(to_state=null):
	.exit(to_state)

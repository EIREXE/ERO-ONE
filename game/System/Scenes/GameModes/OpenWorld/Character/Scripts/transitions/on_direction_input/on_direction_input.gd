tool
extends "res://addons/moe.ero-one.fsm/content/FSMTransition.gd";

func get_fsm(): return fsm; #access to owner FSM, defined in parent class
func get_logic_root(): return logic_root; #access to logic root of FSM (usually fsm.get_parent())

const MOVEMENT_ACTIONS = ["back", "forward", "left", "right"]

var motion_input_detected = false

func transition_init(args = []): 
	#you can optionally implement this to initialize transition on it's creation time 
	pass

func prepare(new_state, args = []): 
	motion_input_detected = false

func input(event, args=[]):
	pass

func transition_condition(delta, args = []):
	var movement_action_pressed = false
	for action in MOVEMENT_ACTIONS:
		if Input.is_action_pressed(action):
			movement_action_pressed = true
	return movement_action_pressed
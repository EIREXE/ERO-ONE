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
	for action in MOVEMENT_ACTIONS:
		if event.is_action(action):
			if event.is_pressed():
				if not logic_root.is_on_wall():
					motion_input_detected = true

func transition_condition(delta, args = []):
	return motion_input_detected
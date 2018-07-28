extends "res://System/Scenes/World/Character/Scripts/states/BaseState/BaseState.gd"

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

#when exiting state
func exit(to_state=null):
	.exit(to_state)

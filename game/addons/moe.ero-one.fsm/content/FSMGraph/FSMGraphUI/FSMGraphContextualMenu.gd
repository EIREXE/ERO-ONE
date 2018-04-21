tool
extends Control

onready var state_name_dialog = get_node("StateNameDialog")

enum OPTIONS {
	CREATE_STATE,
	CREATE_TRANSITION_FROM_EXISTING,
	CREATE_STATE_INHERITED
}

var base_state = null

onready var graph_ui = get_node("..")

func popup():
	$PopupMenu.popup()
	$PopupMenu.rect_global_position = get_global_mouse_position()

	
func ask_for_state_name():
	state_name_dialog.popup_centered()
	state_name_dialog.get_node("LineEdit").grab_focus()

func on_create_state(text=null):
	state_name_dialog.hide()
	graph_ui.graph.createStateGraphAndFSMNode(state_name_dialog.get_node("LineEdit").text, get_global_mouse_position(),null, base_state);

func on_create_inherited_state(ID):
	var state_name = $StateListMenu.get_item_text(ID)
	base_state = state_name 
	ask_for_state_name()

func on_contextual_option_selected(ID):
	match ID:
		OPTIONS.CREATE_STATE:
			base_state = null
			ask_for_state_name()
		OPTIONS.CREATE_TRANSITION_FROM_EXISTING:
			pass
		OPTIONS.CREATE_STATE_INHERITED:
			var fsm = graph_ui.graph.fsmRef.get_ref();
			var states = fsm.get_states()
			$StateListMenu.clear()
			for state in states:
				$StateListMenu.add_item(state.name)
			$StateListMenu.popup()
			$StateListMenu.rect_global_position = get_global_mouse_position()
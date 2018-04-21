tool
extends Node

var scene_to_manage = null;
export var DEBUG_INFO = "";

func _enter_tree():
	set_name("eirteam.fsm_plugin_helper");
	
	#
	if(scene_to_manage==null): 
		scene_to_manage = preload("content/FSM.tscn").instance();

	#
	get_parent().add_child(scene_to_manage);
	scene_to_manage.set_owner(get_tree().get_edited_scene_root());
	queue_free();
	
func _exit_tree(): pass
tool
extends Node
##################################### README  ###############################
# @author: Jakub Grzesik
#
# * To create new state check  "Create New:" subsection in FSM inspector
#
# * Dont be afraid to check FSM script to check available methods
#
# * Exported Variables of FSM which are intended to be used by users:
#
#     NodePath logic_root_path: states usually perform logic based on variables in
#         some external node, like 'Enemy'. This variable usually points to this node.
#         It dont have any other purpose other than to be available for child states.
#
#     bool only_active_state_on_scene: if this is true, then only active state is present
#         on scene tree. It might be handy if states have visual representation
#
#     bool init_manually: #you can set this to true to set export vars in runtime from code,
#         before you will be able to use this FSM you will need to run init() function.
#         Run init() only after setting exported variables.
#
#     string Initial state: you can choose from this list with which state FSM should start.
#
#     int update_mode: if set to manual, then it's up to you to update this FSM. In this case
#         you need to call FSM.update(inDeltaTime) to update this fsm (usually once per frame)
#
#
##########
# * Exported variables that are editor helpers:
#
#      Subdirectory for states: you can set name of directory which will be automatically
#          created to hold all states for this FSM
#
#      Create state with name: when you enter and accept name for a state it will be
#          immediatelly created and added to scene tree as a child of current FSM
#          This state will have an unique script in which you can implement state logic.
#
#
###########
# * Functions that are intended to be used by users:
#
#     get_state_id(): return name of current state
#
#     get_state(): return node with current state
#
#     change_state_to(inNewStateID): can be used to change state.
#        Usually dont need to be used if you are using graph to link your states
#
#     state_time(): returns how long current state is active
#
#     update(inDeltaTime): update FSM to update current state. Should be
#        used in every game tick, but should use it only if you are using
#        update_mode="Manual".
#
#    init(): use only if init_manually = true. You will be able to pass additional arguments
#        to your states and transitions
#
#
################
# * Members that are intended to be used by users:
#    STATE: you can use this dictionary to access state id. Using is is recommended because it's less error prone than
#        entering states ids by hand. ex. fsm.change_state_to(fsm.STATE.START) <- when one of your states is named 'START')

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################
var FSMState = preload("res://addons/moe.ero-one.fsm/content/FSMState.gd");
var fsm_debugger_scene = preload("res://addons/moe.ero-one.fsm/content/FSMDebugger/FSMDebugger.tscn");
var fsm_spatial_debugger_scene = preload("res://addons/moe.ero-one.fsm/content/FSMDebugger/FSMDebugger3D.tscn");

##################################################################################
#########                       Signals definitions                      #########
##################################################################################
signal state_changed(newStateID, oldStateID);

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################

#you can use this dictionary to access state id. Using is is recommended because it's less error prone than
#entering states ids by hand. ex. fsm.set_state(fsm.STATE.START) <- when one of your states is named 'START')
var STATE = {"":""};

#same as above but for transitions
var TRANSITION = {"":""};

const HISTORY_MAX_SIZE = 10;
const UPDATE_MODE_MANUAL = 0;
const UPDATE_MODE_PROCESS = 1;
const UPDATE_MODE_FIXED_PROCESS = 2;

const TYPE_3D = 0;
const TYPE_2D = 1;

export (NodePath) var logic_root_path = NodePath("..");
export (bool) var only_active_state_on_scene = false setget set_only_active_state_on_scene;
export (bool) var init_manually = false;
export (int, "Manual", "Process", "Fixed") var update_mode = UPDATE_MODE_PROCESS;
export (bool) var receive_singals_only_on_activated_items = true;
export (bool) var debug_enabled = false;

var state_transitions_map = {};

var init_state_ID = "" setget set_init_state_ID; #id of initial state for this fsm (id is the same as state node name)
var current_state_ID = init_state_ID;
var current_state = null
var states = {};
var transitions = {};
var state_time = 0;
var states_history = [];
var states_node = null;
var transitions_node = null;
var last_transition_id = null;

##################################################################################
#########                          Init code                             #########
##################################################################################
func _ready():
	set_process(false)
	set_physics_process(false)
	set_process_input(true)
	set_process_unhandled_input(true)
	toolInit();
	add_to_group("FSM");
	if(init_manually):
		return;
	init();

func init(args = null):

	#
	states_node = get_node("States");
	transitions_node = get_node("Transitions");

	if(states_node.get_child_count()==0):
		return;

	#
	if(Engine.is_editor_hint()): return;
	if(get_child_count()==0): return;

	if(debug_enabled):
		var debugger;
		if(get_parent() is Spatial):
			debugger = fsm_spatial_debugger_scene.instance();
		else:
			debugger = fsm_debugger_scene.instance();
		add_child(debugger);
		debugger.manualInit(self);

	#
	ensureinit_state_ID_is_set();

	#
	states = {}; #to be sure
	STATE = {};  #to be sure
	var children_states = states_node.get_children();
	for children_state in children_states:
		if(children_state is preload("FSMState.gd")):
			states[children_state.get_name()] = children_state;
			STATE[children_state.get_name()] = children_state.get_name();
			if(!Engine.is_editor_hint()):
				children_state.logic_root = get_node(logic_root_path);
				children_state.fsm = self;
				children_state.state_init(args);

	#
	initTransitions(args);

	#
	if only_active_state_on_scene:

		#remove transitions
		var transitions = transitions_node.get_children();
		for transition in transitions:
			transitions_node.remove_child(transition);

		# states
		# ensures the rest of states are removed from the scene if
		# only_active_state_on_scene is enabled, but keeps them in memory
		for state in states.keys():
			if state != init_state_ID:
				var state_to_remove = states_node.get_node(state);
				states_node.remove_child(state_to_remove);

	# sets the init_state as the current state
	# if not, falls back to the first state in the tree
	if init_state_ID != "":
		current_state = states[init_state_ID];
		current_state_ID = init_state_ID;
	else:
		current_state = states_node.get_children()[0];
		current_state_ID = current_state.get_name();

	ensure_transitions_for_state_are_ready(current_state_ID)

	#
	current_state.enter();

	#
	initupdate_mode();

func initupdate_mode():
	if(update_mode==UPDATE_MODE_MANUAL): return;
	elif(update_mode==UPDATE_MODE_PROCESS): set_process(true);
	elif(update_mode==UPDATE_MODE_FIXED_PROCESS): set_physics_process(true);

func initTransitions(args):
	TRANSITION = {};
	for state in states_node.get_children(): #ensure even states without transitions are here
		state_transitions_map[state.get_name()] = [];

	var scene_transitions = transitions_node.get_children()
	for transition in scene_transitions:
		TRANSITION[transition.get_name()] = transition.get_name();
		transition.manualInit(args);
		transitions[transition.get_name()] = transition;
		var transitionSourceStates = transition.getAllSourceNodes();
		for state in transitionSourceStates:
			if(!state_transitions_map.has(state.get_name())):
				state_transitions_map[state.get_name()] = [];
			if(!state_transitions_map[state.get_name()].has(transition)):
				state_transitions_map[state.get_name()].append(transition);

func ensureinit_state_ID_is_set():
	if(init_state_ID == ""):
		init_state_ID = states_node.get_child(0).get_name();

# Creates the nodes that hold the transitions and states nodes
func init_holder_nodes():
	if(has_node("States")):
		states_node = get_node("States");
	else:
		states_node = createEmptyHolderNode();
		add_child(states_node);
		states_node.set_name("States");
		states_node.set_owner(get_tree().get_edited_scene_root());

	if(has_node("Transitions")):
		transitions_node = get_node("Transitions");
	else:
		transitions_node= createEmptyHolderNode();
		add_child(transitions_node);
		transitions_node.set_name("Transitions");
		transitions_node.set_owner(get_tree().get_edited_scene_root());

# Returns a base node depending on what kind of node the FSM node itself is
func createEmptyHolderNode():
	if(self is Node2D):
		return Node2D.new();
	elif(self is Spatial):
		return Spatial.new();
	elif(self is Control):
		return Control.new();
	else:
		return Node.new();


##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func state_time():
	return state_time;

func get_state_id():
	return current_state_ID;

func get_state():
	return current_state;

func change_state_to(in_new_state_id):
	if current_state_ID != in_new_state_id:
		set_state(in_new_state_id);

func set_state(in_state_ID, args = null):

	#
	var previous_state_ID = current_state_ID;
	current_state.exit(in_state_ID);
	archive_state_in_history(previous_state_ID)

	#
	if(receive_singals_only_on_activated_items):
		var incomingConnections = current_state.get_incoming_connections();
		for connection in incomingConnections:
			current_state.store_incoming_signals();

		var oldTransitions = state_transitions_map[previous_state_ID];
		for transition in oldTransitions:
			transition.store_incoming_signals();


	if(only_active_state_on_scene):

		#states
		states_node.remove_child(current_state);
		states_node.add_child(states[in_state_ID]);

		#transitions
		var transitions = transitions_node.get_children();
		for transition in transitions: transitions_node.remove_child(transition);

	#
	state_time = 0.0;
	current_state = states[in_state_ID];
	current_state_ID = current_state.get_name()
	ensure_transitions_for_state_are_ready(in_state_ID, args);
	current_state.enter(previous_state_ID, last_transition_id, args);

	if(receive_singals_only_on_activated_items):
		current_state.restore_incoming_signals();

	#
	emit_signal("state_changed", current_state_ID, previous_state_ID);

func ensure_transitions_for_state_are_ready(in_state_ID, args=null):
	if(!state_transitions_map.has(in_state_ID)): return;
	var new_transitions = state_transitions_map[in_state_ID];
	for new_transition in new_transitions:
		if(!transitions_node.has_node(new_transition.get_name())):
			transitions_node.add_child(new_transition);
		new_transition.prepareTransition(in_state_ID, args);

		if(receive_singals_only_on_activated_items):
			new_transition.restore_incoming_signals();


func get_logic_root():
	return get_node(logic_root_path);

func get_state_from_id(in_state_ID):
	return states_node.get_node(in_state_ID);

func get_transition(inID):
	if(Engine.is_editor_hint()): return transitions_node.get_node(inID);  #<- not used because transition might not be in tree during runtime
	return transitions[inID];

#sugar
func get_transition_by_id(inID): return get_transition(inID);

func get_last_used_transition():
	return get_transition(last_transition_id);

func last_transition_id():
	return last_transition_id;

func get_active_transitions():
	return state_transitions_map[current_state_ID];

### less often used below
######
func get_states():
	return states_node.get_children();

func has_state_with_ID(inID):
	return states_node.has_node(inID);

func get_transitions():
	return transitions_node.get_children();

func hasTransition(inID):
	return transitions_node.has_node(inID);

func remove_target_connection_for_transition_id(inID):
	get_transition(inID).clearTarget_stateNode();

func remove_connection_to_transition_from_state(in_state_ID, inTransitionID):
	var state_node = get_state_from_id(in_state_ID);
	var transition_node = get_transition(inTransitionID);
	transition_node.removeSourceConnection(state_node);

func add_transition_between_states(source_state_ID, target_state_ID, transition_ID):
	#assert: you should create transition from inspector first! (don't make a lot of sense to create it from code:
	#you will need to implement custom transition logic anyway)
	assert transitions.has(transition_ID);
	var transitionNode = transitions[transition_ID];
	transitionNode.addSourceStateNode(states_node.get_node(source_state_ID));
	transitionNode.setTarget_stateNode(states_node.get_node(target_state_ID));


#### History
#######
func archive_state_in_history(state):
	if states_history.size() > HISTORY_MAX_SIZE:
		states_history.pop_back();
	states_history.push_front(state)

func getPrevStateFromHistory(depth=0): #0 means prev
	if states_history.size()<=depth: return null;
	var historicState = states_history[depth];
	return historicState;


#### setters bellow are used by tool
#######
func set_init_state_ID(inInitState):
	init_state_ID = inInitState;
	if(is_inside_tree() && Engine.is_editor_hint() && only_active_state_on_scene):
		hideAllVisibleStatesExceptInitOne();

func set_only_active_state_on_scene(inVal):
	only_active_state_on_scene = inVal;
	if(is_inside_tree() && Engine.is_editor_hint()):
		if(only_active_state_on_scene):
			hideAllVisibleStatesExceptInitOne();
		else:
			showAllVisibleStates();

##################################################################################
#########                         Public Methods                         #########
##################################################################################
#call function in current state
func state_call(method, args = null):
	if(current_state.has_method(method)):
		current_state.call(method, args);

#just an alias for update, for the cases when delta time dont have much sense
func perform():
	update(0);

func update(delta, args = null):
	var next_state_ID = checkTransitionsAndGetNextStateID(delta, args);
	assert((typeof(next_state_ID)==TYPE_STRING));  #ERROR: current_state.computeNextState() is not returning String!" Take a look at current_state_ID variable in debugger
	if(next_state_ID!=current_state_ID):
		set_state(next_state_ID);
		

	state_time += delta;
	return current_state.update(delta, args);
	
func _input(event, args = null):
	if current_state.has_method("input"):
		return current_state.input(event)
		
	var relatedTransitions = state_transitions_map[current_state_ID]
	for transition in relatedTransitions:
		if transition.has_method("input"):
			transition.input(event)
	
func _unhandled_input(event, args = null):
	if current_state.has_method("unhandled_input"):
		return current_state.unhandled_input(event)
	
	var relatedTransitions = state_transitions_map[current_state_ID]
	for transition in relatedTransitions:
		if transition.has_method("unhandled_input"):
			transition.unhandled_input(event)

#############
### Transitions check
func checkTransitionsAndGetNextStateID(inDeltaTime, args = null): #work

	if(!state_transitions_map.has(current_state_ID)):
		return current_state_ID;

	var relatedTransitions = state_transitions_map[current_state_ID];
	
	for transition in relatedTransitions:
		
		if(transition.check(inDeltaTime, args)):
			last_transition_id = transition.get_name();
			return transition.getTarget_state_id();
	return current_state_ID;


func transitionReady2BeChecked(inDeltaTime, transition):
	if(transition.intervalBetweenChecks>0.0):
		transition.timeSinceLastCheck += inDeltaTime;
		if(transition.timeSinceLastCheck<transition.intervalBetweenChecks):
			return false;
		else:
			transition.timeSinceLastCheck = 0.0;
	return true;

##################################################################################
#########                    Implemented from parent                     #########
##################################################################################
func _process(delta):
	update(delta);

func _physics_process(delta):
	update(delta);

##############################################################
######################        ################################
############### TOOL / PLUGIN part ###########################
########################    ##################################
##############################################################
var FSMGraphScn = preload("FSMGraph/FSMGraph.tscn");
var FSMGraphInstance;

const INSP_INIT_STATE = "Initial state:";
const INSP_SUBDIR_4_STATES  = "Create new:/Subdirectory for FSM nodes:";
const INSP_CREATE_NEW_STATE = "Create new:/Create state with name:";
const INSP_CREATE_NEW_TRANSITION = "Create new:/Create transition with name:";
const GRAPH_DATA = "GraphData"

const SUBDIR_4_STATES = "states";
const SUBDIR_4_TRANSITIONS = "transitions";

var additionalSubDirectory4FSMData = "FSM";
var additionalGraphData = {};

func toolInit():
	if(!Engine.is_editor_hint()): return;
	init_holder_nodes();

#func getBaseFolderFilepath():
#	var owner = get_owner();
#	var dirPath = owner.get_filename().get_base_dir();
#	if(additionalSubDirectory4FSMData!=""):
#		dirPath = dirPath + "/" +additionalSubDirectory4FSMData + "/" + in_state_ID;
#	else:
#		dirPath = dirPath + "/" + in_state_ID;
#	return dirPath;

############
### Creating States/Transitions
func createState(inStateName, parent_state = null):
	var parent_script = null
	if parent_state:
		for state in get_states():
			if state.name == parent_state:
				parent_script = state.script.resource_path
				break
	createElement(inStateName, states_node, SUBDIR_4_STATES, "res://addons/moe.ero-one.fsm/content/StateTemplate.gd", null, parent_script)

func createTransition(inTransitionName, inScriptPath = null):
	var script = null;
	if(inScriptPath!=null):
		script = load(inScriptPath);
	createElement(inTransitionName, transitions_node, SUBDIR_4_TRANSITIONS, "res://addons/moe.ero-one.fsm/content/TransitionTemplate.gd", script);

func createElement(inElementName, inHolderNode, inElementsSubfolder, inTemplateScriptPath, inAlreadyExistingScript2Use = null, script_parent = null):
	if (inElementName==null) || (inElementName.empty()) || has_node(inElementName): return;

	#
	var lowner = get_owner();

	#
	var dirMaker = Directory.new();
	var dirPath = getFolderFilepath4Element(inElementName, inElementsSubfolder);
	dirMaker.make_dir_recursive(dirPath);

	var scriptFilePath = dirPath + "/" + inElementName + ".gd";
	var sceneFilePath = dirPath + "/" + inElementName + ".tscn";

	#
	var script = inAlreadyExistingScript2Use;
	if(script==null):
		var script_file = File.new();
		script_file.open(scriptFilePath, File.WRITE);
		var script_text = load(inTemplateScriptPath).get_source_code()

		if script_parent:
			var script_text_split = script_text.split("\n")
			for i in range(script_text_split.size()):
				var line = script_text_split[i]
				if line.find("extends") != -1:
					script_text_split[i] = "extends \"%s\"" % [script_parent]
					script_text = PoolStringArray(script_text_split).join("\n")
					break;


		script_file.store_string(script_text);
		script_file.close();
		script = load(scriptFilePath);

	#
	var scnStateNode = Node.new();
	scnStateNode.set_script(script);
	scnStateNode.set_name(inElementName);
	var packedScn = PackedScene.new();
	packedScn.pack(scnStateNode);
	ResourceSaver.save(sceneFilePath, packedScn);

	var scn2Add = load(sceneFilePath).instance();
	inHolderNode.add_child(scn2Add)
	scn2Add.set_owner(get_tree().get_edited_scene_root());

func getFolderFilepath4Element(inElementID, inElementsSubdir):
	var lowner = get_owner();
	var dirPath = lowner.get_filename().get_base_dir();
	if(additionalSubDirectory4FSMData!=""):
		dirPath = dirPath + "/" +additionalSubDirectory4FSMData + "/" + inElementsSubdir + "/" + inElementID;
	else:
		dirPath = dirPath + "/" + inElementsSubdir + "/" + inElementID;
	return dirPath;


############
#### properties
func _get_property_list():
	var currentStatesList = states_node.get_children();
	var statesListString = "";
	for state in currentStatesList:
		statesListString = statesListString + state.get_name() + ",";
	statesListString.erase(statesListString.length()-1,1)

	return [
		{
            "hint": PROPERTY_HINT_ENUM,
            "usage": PROPERTY_USAGE_DEFAULT,
 			"hint_string":statesListString,
            "name": INSP_INIT_STATE,
            "type": TYPE_STRING
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT,
            "name": INSP_SUBDIR_4_STATES,
            "type": TYPE_STRING
        },
		{
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT,
            "name": INSP_CREATE_NEW_STATE,
            "type": TYPE_STRING
        },
			{
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT,
            "name": INSP_CREATE_NEW_TRANSITION,
            "type": TYPE_STRING
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_STORAGE,
            "name": GRAPH_DATA,
            "type": TYPE_DICTIONARY
        }
    ];
func _get(property):
	if(property == INSP_SUBDIR_4_STATES):
		return additionalSubDirectory4FSMData;
	elif(property==INSP_INIT_STATE):
		return init_state_ID;
	elif(property==GRAPH_DATA):
		return additionalGraphData;

func _set(property, value):
	if(property == INSP_SUBDIR_4_STATES):
		additionalSubDirectory4FSMData = value;
		return true;
	elif(property == INSP_CREATE_NEW_STATE):
		createState(value);
		return false;
	elif(property==INSP_CREATE_NEW_TRANSITION):
		createTransition(value);
		return false;
	elif(property==INSP_INIT_STATE):
		set_init_state_ID(value);
		return true
	elif(property==GRAPH_DATA):
		additionalGraphData = value;
		return true;

#### visibility of states
#######
func showAllVisibleStates():
	callMethodInStatesAndAllDirectChilds("show");
func hideAllVisibleStatesExceptInitOne():
	callMethodInStatesAndAllDirectChilds("hide");

func callMethodInStatesAndAllDirectChilds(inMethodName):
	var states = states_node.get_children();
	for state in states:
		if(state.get_name()==init_state_ID):
			showStateOrItsDirectChilds(state);
			continue;
		if(state.has_method(inMethodName)):
			state.call(inMethodName);
			continue;
		var stateChilds = state.get_children();
		for stateChild in stateChilds:
			if(stateChild.has_method(inMethodName)): stateChild.call(inMethodName);

func showStateOrItsDirectChilds(inState):
	if(inState.has_method("show")):
		inState.show;
	else:
		var stateChilds = inState.get_children();
		for stateChild in stateChilds:
			if(stateChild.has_method("show")): stateChild.show();

##############
#### Graph
func toolSave2Dict():
	if(FSMGraphInstance!=null):
		return FSMGraphInstance.toolSave2Dict();

func toolLoadFromDict(state):
	if(FSMGraphInstance!=null):
		FSMGraphInstance.restorePernamentData(state);


##################################################################################
#########                         Inner Classes                          #########
##################################################################################

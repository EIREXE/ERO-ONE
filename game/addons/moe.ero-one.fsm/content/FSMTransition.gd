tool
extends Node
################################### R E A D M E ##################################
# For more informations check script attached to FSM node
#
#

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
export (Array) var path2SourceStates = [NodePath()] setget setSourceStateNodesPaths;
export (NodePath) var path2Target_state = null; #NodePath("");
export (float) var intervalBetweenChecks = -1.0; #in seconds, -1 mean disable
#export (Vector2) var devGraphPos = Vector2(0,0); #position in editor tool graph

onready var fsm;
onready var logic_root;
#onready var sourceStateNodes = []
onready var target_stateNode;

var timeSinceLastCheck = 0.0;
var transAccomplished = false;

var incomingSignals = [];

func _ready():
	if(!Engine.is_editor_hint()): return;
	initSourceStates();
	fixCommonProblems();

func manualInit(inParam1=null, inParam2=null, inParam3=null, inParam4=null, inParam5=null):
	initSourceStates();
	fixCommonProblems();
	if(is_inside_tree()):
		if(!Engine.is_editor_hint()):
			transitionInit(inParam1, inParam2, inParam3, inParam4, inParam5);

func initSourceStates():
	if(!is_inside_tree()): return;
	if(!Engine.is_editor_hint()):
		fsm = get_parent().get_parent();
		logic_root = fsm.get_logic_root();
	refreshSourceNodes();
	refreshTargetNodeFromPath();

func getAllSourceNodes():
	var sourceNodes = [];
	for path in path2SourceStates:
		if(has_node(path)):
			if(get_node(path)!=self):
				sourceNodes.append(get_node(path));
	return sourceNodes;

func refreshSourceNodes():
	pass
#	for sourceStatePath in path2SourceStates:
#		if(has_node(sourceStatePath)):
#			if(!sourceStateNodes.has(get_node(sourceStatePath))):
#				sourceStateNodes.append(get_node(sourceStatePath));

func removeSourceConnection(inSourceStateNode):
	path2SourceStates.erase(get_path_to(inSourceStateNode));

func refreshTargetNodeFromPath():
	if(path2Target_state==null): return;
	if(has_node(path2Target_state)):
		target_stateNode = get_node(path2Target_state);
	else:
		target_stateNode = null;

func setSourceStateNodesPaths(inPathsArray):
	path2SourceStates = inPathsArray;

func addSourceStateNode(inSourceStateNode):
	if(!path2SourceStates.has(get_path_to(inSourceStateNode))):
		path2SourceStates.append(get_path_to(inSourceStateNode));
	refreshSourceNodes(); #problem was here?

func clearTarget_stateNode():
	path2Target_state = null; #NodePath("");
	target_stateNode = null;

func setTarget_stateNode(inTarget_stateNode):
	if(has_node(get_path_to(inTarget_stateNode))):
		path2Target_state = get_path_to(inTarget_stateNode);
	refreshTargetNodeFromPath();

func getTargetFSMState():
	if(path2Target_state==null): return null;
	if(has_node(path2Target_state)):
		return get_node(path2Target_state);

#rather private ones
func fixCommonProblems():
	if(getTargetFSMState()!=null):
		if(getTargetFSMState()==self):
			clearTarget_stateNode();

func check(inDeltaTime, args=null):
	if !Engine.is_editor_hint():
		if(transAccomplished): return true;
		return transition_condition(inDeltaTime, args)

func prepareTransition(inNewStateID, args=null):
	transAccomplished = false;
	return prepare(inNewStateID, args);

#####
## Signals
func store_incoming_signals():
	incomingSignals.clear();
	var incomingConnections = get_incoming_connections();
	for connection in incomingConnections:
		incomingSignals.append(SignalData.new(connection.source, connection.signal_name, connection.method_name));
		connection.source.disconnect(connection.signal_name, self, connection.method_name);

func restore_incoming_signals():
	for storedSignal in incomingSignals:
		if(!storedSignal.signalSourceRef.get_ref()): continue;
		storedSignal.signalSourceRef.get_ref().connect(storedSignal.signalName, self, storedSignal.targetFuncName);

#######################################
################ Public
func accomplish():
	transAccomplished = true;

func getTarget_state_id():
	return target_stateNode.get_name(); #cant assume target_stateNode is in the tree at the moment

######################################
####### Implement those below ########
func transitionInit(inParam1=null, inParam2=null, inParam3=null, inParam4=null, inParam5=null): pass
func prepare(inNewStateID, inArg0 = null, inArg1 = null, inArg2 = null): pass
func transition_condition(inDeltaTime, args=null): #optional params. They exist if you have pushed them in update
	#IMPLEMENT CHECK LOGIC HERE
	return false;

### Internal classes
#############
class SignalData:
	var signalSourceRef;
	var signalName;
	var targetFuncName;

	func _init(inSource, inName, inTargetFunc):
		signalSourceRef = weakref(inSource);
		signalName = inName;
		targetFuncName = inTargetFunc;

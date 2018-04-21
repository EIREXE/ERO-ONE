tool
extends Panel
################################### R E A D M E ##################################
#
#
#

##################################################################################
#########                     Imported classes/scenes                    #########
##################################################################################

##################################################################################
#########                       Signals definitions                      #########
##################################################################################
signal arrowDragFinishedAtEmptySpace(inFromGraphNode, inAtPos);
signal openScriptRequest(inFsmNode);
signal selectNodeRequest(inFsmNode);

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
const GraphNodeScript = preload("GraphNode/GraphNode.gd");
const TransitionGraphNodeScn = preload("TransitionGraphNode/TransitionGraphNode.tscn");
const TransitionGraphNodeScript = preload("TransitionGraphNode/TransitionGraphNode.gd");
const StateGraphNodeScn = preload("StateGraphNode/StateGraphNode.tscn");
const StateGraphNodeScript = preload("StateGraphNode/StateGraphNode.gd");

var pernamentData = {};
var fsmRef= returnEmptyWeakRef();



onready var text_label = get_node("ScrollContainer/Label")
onready var graph_nodes = get_node("ScrollContainer/graphNodes")
onready var scroll_container = get_node("ScrollContainer")

##################################################################################
#########                          Init code                             #########
##################################################################################
func _notification(what):
	if(what == NOTIFICATION_READY):
		ensureGraphNodesSignalsConnected();
		scroll_container.set_enable_h_scroll(true);
		scroll_container.set_enable_v_scroll(true);
		scroll_container.get_node("initSetup").play("default"); #dont know why but I need to do this because editor constantly resets some properties
		scroll_container.set_h_scroll(1200);
		scroll_container.set_v_scroll(2500);



func manualInit(inFSM):
	clearGraphNodes();
	fsmRef = weakref(inFSM);
	refreshFromFSMData();
	ensureGraphNodesSignalsConnected();
	restoreAdditionalData();

func refresh():
	pass
#	if(fsm!=null):
	#	restoreAdditionalData();
#	clearGraphNodes();
#	refreshFromFSMData();
#	ensureGraphNodesSignalsConnected();

func clearGraphNodes():
	for node in graph_nodes.get_children():
		node.set_name(node.get_name() + "_");
		node.queue_free();
	if(!fsmRef.get_ref()): return;
	saveAdditionalData();

func refreshFromFSMData():
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;
	var fsm = fsmRef.get_ref();

	var states = fsm.get_states();
	for state in states:
		createStateGraphNode(Vector2(50,50), state.get_name());
	var transitions = fsm.get_transitions();
	for transition in transitions:
		transition.refreshTargetNodeFromPath();
		var transGraphNode = createTransitionGraphNode(Vector2(250,50), transition.get_name());
		var transitionGraphNode = graph_nodes.get_node(transition.get_name());
		var sourceNodes = transition.getAllSourceNodes();
		for sourceStateNode in sourceNodes:
			var sourceGraphState = graph_nodes.get_node(sourceStateNode.get_name());
			connectGraphNodes(sourceGraphState, transitionGraphNode);
		if(transition.target_stateNode!=null) && (transition.target_stateNode!=transition):
			var targetGraphState = transition.target_stateNode.get_name();
			connectGraphNodes(transitionGraphNode, graph_nodes.get_node(targetGraphState));

##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func getNearestGraphNode(inPos):
	var currentMinDst = 90000;
	var candidate = null;
	for graphNode in graph_nodes.get_children():
		var dst = graphNode.getGlobalCenterPos().distance_to(inPos);
		if(dst<currentMinDst):
			currentMinDst = dst;
			candidate = graphNode;
	return candidate;

##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################

##################################################################################
#########                       Connected Signals                        #########
##################################################################################
func _on_StateRepresentation_arrowDragEnd( inFromGraphNode, inAtPos, inSlot ):
	var nearestGraphNode = getNearestGraphNode(inAtPos);
	if(nearestGraphNode.getGlobalCenterPos().distance_to(inAtPos) > 150):
		#onEmpty arrow drag
		emit_signal("arrowDragFinishedAtEmptySpace", inFromGraphNode, inAtPos)
	else:
		connectionRequest(inFromGraphNode, nearestGraphNode);

func _on_StateRepresentation_connection2Empty( inStateRepresentation, inAtPos, inSlot ):
	var newGraphNode = automaticallyCreateGraphNode(inAtPos);
	connectGraphNodes(inStateRepresentation, newGraphNode);

func onGraphNodeMovementEnd(inGraphNode):
	saveAdditionalData();
#	get_node("Label").set_text("Saving data");

func onGraphNodeClick(inGraphNode):
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;

	var node = null;
	if(inGraphNode is StateGraphNodeScript):
		node = fsmRef.get_ref().get_state_from_id(inGraphNode.get_name());
	elif(inGraphNode is TransitionGraphNodeScript):
		node = fsmRef.get_ref().get_transition(inGraphNode.get_name());
	if(node!=null):
		emit_signal("selectNodeRequest", node);

func onGraphNodeDoubleClick(inGraphNode):
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;
	
	if(inGraphNode is TransitionGraphNodeScript):
		var fsmTransition = fsmRef.get_ref().get_transition(inGraphNode.get_name());
		emit_signal("openScriptRequest", fsmTransition);
	else: #State graph node
		var fsmState = fsmRef.get_ref().get_state_from_id(inGraphNode.get_name());
		emit_signal("openScriptRequest", fsmState);

func _on_FSMGraph_gui_input( ev ):
	pass

func onGraphNodeConnectionRemoveRequest(inSourceGraphNode, inTargetGraphNode):
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;

	get_node("ScrollContainer/Label").set_text("inTargetGraphNode: " + inTargetGraphNode.get_name());
	if(inSourceGraphNode.baseType==GraphNodeScript.TYPE_TRANSITION):
		fsmRef.get_ref().remove_target_connection_for_transition_id(inSourceGraphNode.get_name());
	elif(inTargetGraphNode.baseType==GraphNodeScript.TYPE_TRANSITION):
		fsmRef.get_ref().remove_connection_to_transition_from_state(inSourceGraphNode.get_name(), inTargetGraphNode.get_name());

##################################################################################
#########     Methods fired because of events (usually via Groups interface)  ####
##################################################################################

##################################################################################
#########                         Public Methods                         #########
##################################################################################
func connectGraphNodes(inFromNode, inTargetNode):
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;
	var fsm = fsmRef.get_ref();

	inFromNode.createNewArrowAndConnect2(inTargetNode);
	ensureGraphNodesSignalsConnected();

	#var text = text_label.get_text() + " a ";
	#text_label.set_text(text)

	if(inFromNode is TransitionGraphNodeScript):
		if(fsm.hasTransition(inFromNode.get_name()) && fsm.has_state_with_ID(inTargetNode.get_name())):
			var transFSMnode = fsm.get_transition(inFromNode.get_name());
			var stateFSMnode = fsm.get_state_from_id(inTargetNode.get_name());
			transFSMnode.setTarget_stateNode(stateFSMnode);
	elif(inTargetNode is TransitionGraphNodeScript):
		if(fsm.hasTransition(inTargetNode.get_name()) && fsm.has_state_with_ID(inFromNode.get_name())):
			var transFSMnode = fsm.get_transition(inTargetNode.get_name());
			var stateFSMnode = fsm.get_state_from_id(inFromNode.get_name());
			transFSMnode.addSourceStateNode(stateFSMnode);

	#text_label.set_text(text)

func saveVisualData2Dictionary():
	var data = {};
#	for graphNode in graphNodes.get_children():
#		data[graphNode.get_name()] = graphNode.get_
#fsm.additionalGraphData = data



##################################################################################
#########                         Inner Methods                          #########
##################################################################################
func ensureGraphNodesSignalsConnected():
	for graphNode in graph_nodes.get_children():
		if(!graphNode.is_connected("arrowDragEnd", self, "_on_StateRepresentation_arrowDragEnd")):
			graphNode.connect("arrowDragEnd", self, "_on_StateRepresentation_arrowDragEnd");

		if(!graphNode.is_connected("movementEnd", self, "onGraphNodeMovementEnd")):
			graphNode.connect("movementEnd", self, "onGraphNodeMovementEnd");

		if(!graphNode.is_connected("doubleClick", self, "onGraphNodeDoubleClick")):
			graphNode.connect("doubleClick", self, "onGraphNodeDoubleClick");

		if(!graphNode.is_connected("singleClick", self, "onGraphNodeClick")):
			graphNode.connect("singleClick", self, "onGraphNodeClick");

		if(!graphNode.is_connected("connectionRemoveRequest", self, "onGraphNodeConnectionRemoveRequest")):
			graphNode.connect("connectionRemoveRequest", self, "onGraphNodeConnectionRemoveRequest");


func connectionRequest(inSourceNodegraph, inTargetNodeGraph):
	var text = get_node("ScrollContainer/Label").get_text() + " a ";
	if(inSourceNodegraph.baseType == inTargetNodeGraph.inputConnectionType):
		if(inSourceNodegraph.canConnect2AnotherNode() && inTargetNodeGraph.isAcceptingIncomingConnections()):
			connectGraphNodes(inSourceNodegraph, inTargetNodeGraph);
	get_node("ScrollContainer/Label").set_text(text)

#############
### Graph node creation
func automaticallyCreateGraphNode(inSourceGraphNode, inPos):
	if(inSourceGraphNode.outputConnectionType == GraphNodeScript.TYPE_TRANSITION):
		return createTransitionGraphNode(inPos, "Transitin node");
	elif(inSourceGraphNode.outputConnectionType == GraphNodeScript.TYPE_STATE):
		return createStateGraphNode(inPos, "STATE NAME2");

func createTransitionGraphNode(inPos, inName):
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;
	var fsm = fsmRef.get_ref();

	var newGraphNode = TransitionGraphNodeScn.instance();
	graph_nodes.add_child(newGraphNode);
	newGraphNode.setCenterPos(inPos);
	newGraphNode.setName(inName);
	newGraphNode.set_name(inName);
	newGraphNode.manualInit(fsm);
	return newGraphNode;

func createStateGraphNode(inPos, inName):
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;
	var fsm = fsmRef.get_ref();

	var newGraphNode = StateGraphNodeScn.instance();
	graph_nodes.add_child(newGraphNode);
	newGraphNode.setCenterPos(inPos);
	newGraphNode.setName(inName);
	newGraphNode.set_name(inName);
	newGraphNode.manualInit(fsm);
	return newGraphNode;

func createStateGraphAndFSMNodeAndConnect2(inStateName,inGlobalPos, createRequestFromGraphNode):
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;
	var fsm = fsmRef.get_ref();
	var node = createStateGraphNode(inGlobalPos, inStateName);
	fsm.createState(inStateName);
	connectionRequest(createRequestFromGraphNode, graph_nodes.get_node(inStateName));
	node.set_global_position(inGlobalPos);

func createStateGraphAndFSMNode(inStateName,inGlobalPos, createRequestFromGraphNode, parent_state=null):
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;
	var fsm = fsmRef.get_ref();
	var node = createStateGraphNode(inGlobalPos, inStateName);
	fsm.createState(inStateName, parent_state);
	node.set_global_position(inGlobalPos);

func createTransitionGraphAndFSMNodeAndConnect2(inTransitionName, inGlobalPos, createRequestComesFromGraphNode, inExternalScript = null):
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;
	var fsm = fsmRef.get_ref();
	var node = createTransitionGraphNode(inGlobalPos,inTransitionName);
	fsm.createTransition(inTransitionName, inExternalScript);
	connectionRequest(createRequestComesFromGraphNode, graph_nodes.get_node(inTransitionName));
	node.set_global_position(inGlobalPos);

#func createAndConnect
#		connectionRequest(inStateRepresentation, newGraphNode);

###############
### Saving/Loading data not from model
func saveAdditionalData():
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;
	var fsm = fsmRef.get_ref();
	if(fsm==null): return;
	for graphNode in graph_nodes.get_children():
		fsm.additionalGraphData[graphNode.get_name()] = graphNode.get_position();

func restoreAdditionalData():
	if(!fsmRef.get_ref()):
		get_parent().hide();
		return;
	var fsm = fsmRef.get_ref();
	if(fsm==null): return;
	for graphNodeName in fsm.additionalGraphData.keys():
		if(!graph_nodes.has_node(graphNodeName)): continue;
		var pos = fsm.additionalGraphData[graphNodeName];
		graph_nodes.get_node(graphNodeName).set_position(pos)
#		get_node("Label").set_text("restore data: " + graphNodeName + " " +str(pos))


func toolSave2Dict():
	var storage = {};
	return storage;
	for graphNode in graph_nodes.get_children():
		storage[graphNode.get_name()] = graphNode.get_position();

func toolLoadFromDict(inDict):
	return
	pernamentData = inDict;
	restorePernamentData();

func restorePernamentData():
	for graphNodeName in pernamentData.keys():
		if(!graph_nodes.has_node(graphNodeName)): return;
		var pos = pernamentData[graphNodeName];
		graph_nodes.get_node(graphNodeName).set_position(pos)
		text_label.set_text("restore data: " + graphNodeName + " " +str(pos))



##########
## Helpers
static func returnEmptyWeakRef():
	var tempObj = Node.new();
	var weakRef = weakref(tempObj);
	tempObj.free()
	return weakRef;

##################################################################################
#########                         Inner Classes                          #########
##################################################################################






func gui_input(ev):
	if(ev is InputEventMouseMotion):
		var middleBtnClicked = (ev.button_mask & BUTTON_MASK_MIDDLE);
		if(middleBtnClicked):
			scroll_container.set_v_scroll(scroll_container.get_v_scroll() - ev.relative.y);
			scroll_container.set_h_scroll(scroll_container.get_h_scroll() - ev.relative.x);

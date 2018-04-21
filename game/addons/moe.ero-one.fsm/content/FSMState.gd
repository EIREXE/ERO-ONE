extends Node;

var logic_root;
var fsm;

func state_init(args=null): pass
func enter(from_state=null, from_transition=null, args=null): pass
func update(delta_time,args=null): pass
func exit(to_state=null): pass

func computeNextState():
	return self.get_name()

######### INTERNAL/PRIVATE PART ########
var incomingSignals = [];

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

class SignalData:
	var signalSourceRef;
	var signalName;
	var targetFuncName;
	
	func _init(inSource, inName, inTargetFunc):
		signalSourceRef = weakref(inSource);
		signalName = inName;
		targetFuncName = inTargetFunc;
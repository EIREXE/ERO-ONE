extends Spatial

onready var character = get_node("EROCharacter")

func _ready():
	set_process(true)

func _process(delta):
	var input_movement_vector = Vector3()
	
	if Input.is_action_pressed("forward"):
		input_movement_vector.z += 1
	if Input.is_action_pressed("back"):
		input_movement_vector.z -= 1
	if Input.is_action_pressed("left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("right"):
		input_movement_vector.x = 1
		
	input_movement_vector = input_movement_vector.normalized()
	
	character.add_movement_input(input_movement_vector)

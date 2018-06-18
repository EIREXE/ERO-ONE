extends Node

var player_pleasure = 0 setget set_player_pleasure
var partner_pleasure = 0 setget set_partner_pleasure

var partner_orgasms = 0

var thrust_speed = 1 setget set_thrust_speed # Thrusts/s

var base_thrust_pleasure = 0.025 # Base pleasure per thrust without any multipliers
var global_pleasure_multiplier = 1.0

var sweetspot = 0.5 # Speed sweetspot
var sweetspot_margin = 0.025 # Speed sweetspot margin
var sweetspot_multiplier = 1.0 # Multiplier when speed is just right

var orgasm_line = 0.75
var post_orgasm_line_modifier = 1.5

var partner_auto_orgasm = true # If set to true the partner will orgasm automatically on reaching max pleasure

var thrust_timer = Timer.new()

onready var gauge = get_node("CanvasLayer/HModeGauge")

func set_player_pleasure(value):
	player_pleasure = value
	gauge.player_pleasure_level = player_pleasure
	
func set_partner_pleasure(value):
	partner_pleasure = value
	gauge.partner_pleasure_level = partner_pleasure

func set_thrust_speed(value):
	thrust_speed = value
	gauge.speed = value
	gauge.is_sweetspotted = is_sweetspotted()

func _ready():
	set_process(true)
	set_process_input(true)
	set_thrust_speed(0.5)


func _input(event):
	var new_speed = 0.0
	if event.is_action("increase_thrust_speed"):
		new_speed = 1.0*get_process_delta_time()
	elif event.is_action("decrease_thrust_speed"):
		new_speed = -1.0*get_process_delta_time()
	thrust_speed += new_speed
	set_thrust_speed(clamp(thrust_speed, 0.0, 1.0))

func _process(delta):
	var partner_pleasure_delta = base_thrust_pleasure
	partner_pleasure_delta*=get_sensitivity_multiplier()
	partner_pleasure_delta*=get_sweetspot_multiplier()
	partner_pleasure_delta*=global_pleasure_multiplier
	
	# Apply the post-orgasm line modifier
	if partner_pleasure >= orgasm_line:
		partner_pleasure_delta*=post_orgasm_line_modifier
	
	# RECODE?: At the moment pleasure is only increased when sweetspotting, maybe
	# this shouldn't be like this, look into this when Irene is around
	if is_sweetspotted() or partner_pleasure >= orgasm_line:
		set_partner_pleasure(partner_pleasure + partner_pleasure_delta*delta)
	
	# Automatic partner orgasm
	if partner_pleasure >= 1.0 and partner_auto_orgasm:
		partner_orgasm()
	
# The more orgasms the partner has the more sensitive they are, this effect
# drops off the more orgasms they have.
func get_sensitivity_multiplier():
	return sqrt(partner_orgasms)*0.75+1

func get_sweetspot_multiplier():
	if is_sweetspotted():
		return sweetspot_multiplier
		
	else:
		return 0.25

func is_sweetspotted():
	var is_sweetspotted = false
	if thrust_speed >= sweetspot-sweetspot_margin and thrust_speed <= sweetspot+sweetspot_margin:
		is_sweetspotted = true
	return is_sweetspotted

func player_orgasm():
	pass
	
func partner_orgasm():
	partner_pleasure = 0
	partner_orgasms += 1

func together_orgasm():
	partner_orgasm()
	player_orgasm()
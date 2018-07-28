tool
extends Control

const ROTARY_MIN_ANGLE = -135
const ROTARY_MAX_ANGLE = 135

const ROTARY_BASE_WIDTH = 25.0

const REFERENCE_WIDTH = 225

var main_rotary_width = 25.0

export (float, 0, 1) var player_pleasure_level = 0.0 setget set_player_pleasure_level
export (float, 0, 1) var partner_pleasure_level = 0.0 setget set_partner_pleasure_level
export (float, 0, 1) var speed = 0.0 setget set_speed

onready var player_pleasure_indicator = get_node("PlayerPleasureIndicator")
onready var partner_pleasure_indicator = get_node("PartnerPleasureIndicator")

export (bool) var is_sweetspotted = false setget set_sweetspotted

var heart_graphic = preload("res://System/Textures/ui/HMode/heart.svg")

func set_sweetspotted(value):
	is_sweetspotted = value
	update()

func set_player_pleasure_level(value):
	player_pleasure_level = value


	update()
	
func set_speed(value):
	speed = value
	update()
	
func set_partner_pleasure_level(value):
	partner_pleasure_level = value
	update()

func draw_circle_arc(center, radius, angle_from, angle_to, color, width):
	var total_degrees = angle_to-angle_from
	var nb_points = int((total_degrees/270)*64)
	var points_arc = PoolVector2Array()
	if nb_points > 0:
		for i in range(nb_points+1):
			var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
			points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
		
		draw_polyline(points_arc, color, width, true)
		
func _ready():
	set_process(true)
	update()
	
func _draw():
	# 225 x 225 is the reference
	player_pleasure_indicator.indicator_value = player_pleasure_level
	partner_pleasure_indicator.indicator_value = partner_pleasure_level
	
	main_rotary_width = (ROTARY_BASE_WIDTH/REFERENCE_WIDTH)*rect_size.x
	
	# Speed indicator
	var speed_indicator_color = Color(1,1,1)
	if is_sweetspotted:
		speed_indicator_color = Color("f4a0ff")
	draw_rotary_indicator((140.0/REFERENCE_WIDTH)*rect_size.x, speed, 2.0, false, speed_indicator_color)
	
	if is_sweetspotted:
		pass
		#draw_heart()
	
	
	# Draw MAX-P indicators

func draw_rotary_indicator(radius, completion, width, draw_base=true, color=Color(1,1,1)):
	var completion_angle = completion*(ROTARY_MAX_ANGLE-ROTARY_MIN_ANGLE)
	completion_angle = ROTARY_MIN_ANGLE + completion_angle
	
	# Draws the base
	if draw_base:
		draw_circle_arc(rect_size/2, radius, ROTARY_MIN_ANGLE, ROTARY_MAX_ANGLE, Color(0,0,0, 0.5), width)
	

	# Draws the completed part
	draw_circle_arc(rect_size/2, radius, ROTARY_MIN_ANGLE, completion_angle, color, width)
	
func draw_heart():
	var width_size = (64.0/REFERENCE_WIDTH)*rect_size.x
	var rect2_pos = rect_size/2 - Vector2(width_size, width_size)/2
	var rect2_size = Vector2(width_size,width_size)
	draw_texture_rect(heart_graphic, Rect2(rect2_pos, rect2_size), false, Color(1.0,1.0,1.0,1.0))
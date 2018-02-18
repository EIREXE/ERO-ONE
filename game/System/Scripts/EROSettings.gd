  extends Node

var resolution = Vector2(1280,720) setget set_resolution
var fullscreen = false setget set_fullscreen
var borderless = false setget set_borderless

var msaa = VisualServer.VIEWPORT_MSAA_2X setget set_msaa

var fxaa = false setget set_fxaa

var mouse_sensitivity = 1.0 setget set_mouse_sensitivity

var zoom_speed = 2.5 setget set_zoom_speed
var free_camera_speed = 4.0 setget set_free_camera_speed

var main_config_path = "user://Config/settings.ini"
var config_directory = "user://Config"

var show_fps = false setget set_show_fps

func _ready():
	
	if not Directory.new().dir_exists(config_directory):
		Directory.new().make_dir_recursive(config_directory)
	
	var ERR = load_settings(main_config_path)
	
	if ERR != OK:
		save_settings(main_config_path)
		
	Console.register_cvar("mouse_sensitivity", {
		description = "Mouse sensitvity",
		arg = ["sensitivity", TYPE_REAL],
		target = self
	})
	Console.register_cvar("zoom_speed", {
		description = "Editor zoom speed",
		arg = ["speed", TYPE_REAL],
		target = self
	})
	Console.register_cvar("free_camera_speed", {
		description = "Free camera speed",
		arg = ["speed", TYPE_REAL],
		target = self
	})
	
	Console.register_cvar("show_fps", {
		description = "Show fps",
		arg = ["enable", TYPE_BOOL],
		target = self
	})
func save_settings(path=main_config_path):
	var config_file = ConfigFile.new()
	# Display settings
	config_file.set_value("display", "resolution", resolution)
	config_file.set_value("display", "fullscreen", fullscreen)
	config_file.set_value("display", "borderless", borderless)
	
	# Graphics values
	config_file.set_value("graphics", "MSAA", msaa)

	# Input values
	config_file.set_value("input", "mouse_sensitivity", mouse_sensitivity)
	
	# Camera values
	config_file.set_value("camera", "zoom_speed", zoom_speed)
	config_file.set_value("camera", "free_camera_speed", free_camera_speed)
	config_file.save(path)
func load_settings(path):
	var config_file = ConfigFile.new()
	var ERR = config_file.load(path)
	if ERR == OK:
		config_file.get_value("display", "resolution") 
		for value in config_values:
			if config_file.has_section_key(value["section"],value["key"]):
				call(value["set"],config_file.get_value(value["section"], value["key"]))
		return OK
	else:
		return FAILED

func set_resolution(new_resolution):
	if typeof(new_resolution) == TYPE_VECTOR2:
		resolution = new_resolution
		Console.write_line("TODO: set_resolution", Console.COLOR_WARN, "EROSettings")
	else:
		Console.write_line("Resolution must be a Vector2!", Console.COLOR_ERR, "EROSettings")
		
func set_fullscreen(new_fullscreen):
	if not fullscreen == new_fullscreen:
		OS.set_window_fullscreen(fullscreen)
	fullscreen = new_fullscreen

func set_borderless(new_borderless):
	if borderless != new_borderless:
		OS.set_borderless_window(borderless)
	borderless = new_borderless

func set_msaa(new_msaa):

	if msaa != new_msaa:
		print("setting MSAA to %d" % [new_msaa])
		get_viewport().msaa = new_msaa
	msaa = new_msaa

func set_mouse_sensitivity(new_mouse_sensitivity):
	mouse_sensitivity = new_mouse_sensitivity

func set_zoom_speed(new_zoom_speed):
	zoom_speed = new_zoom_speed

func set_free_camera_speed(new_free_camera_speed):
	free_camera_speed = new_free_camera_speed

func set_show_fps(new_value):
	show_fps = new_value

func set_fxaa(new_value):
	if fxaa != new_value:
		get_viewport().fxaa = true
	fxaa = new_value

# Config vlaue map, to make adding new stuff easier
var config_values = [{
		section="display",
		key="resolution",
		set="set_resolution"
	},
	{
		section="display",
		key="fullscreen",
		set="set_fullscreen"
	},
	{
		section="display",
		key="borderless",
		set="set_borderless"
	},
	{
		section="graphics",
		key="MSAA",
		set="set_msaa"
	},
	{
		section="input",
		key="mouse_sensitivity",
		set="set_mouse_sensitivity"
	},
	{
		section="camera",
		key="zoom_speed",
		set="set_zoom_speed"
	},
	{
		section="camera",
		key="free_camera_speed",
		set="set_free_camera_speed"
	},
	{
		section="display",
		key="show_fps",
		set="set_show_fps"
	},
	{
		section="display",
		key="fxaa",
		set="set_fxaa"
	},
]

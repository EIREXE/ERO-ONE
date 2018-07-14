tool
extends Spatial

export(bool) var disconnected setget set_disconnected

var imm

func set_disconnected(value):
	disconnected = value
	if Engine.editor_hint:
		draw_debug_line()


func _ready():
	if disconnected:
		add_to_group("minimap_roads")
	draw_debug_line()
	if Engine.editor_hint:
		set_notify_transform(true)
		
func _notification(what):
	if Engine.editor_hint:
		if what == Spatial.NOTIFICATION_TRANSFORM_CHANGED:
			draw_debug_line()
		
func draw_debug_line():
	if Engine.editor_hint:
		if not disconnected:
			if not imm:
				imm = ImmediateGeometry.new()
				add_child(imm)
			imm.clear()
			imm.begin(Mesh.PRIMITIVE_LINES)
			imm.set_color(Color(0.0, 0.0, 0.0))
			
			imm.add_vertex(to_local(get_parent().global_transform.origin))
			imm.set_color(Color(0.0, 0.0, 0.0))
			imm.add_vertex(Vector3(0.0, 0.0, 0.0))
			imm.end()
		else:
			if imm:
				imm.clear()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

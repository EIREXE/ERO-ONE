
extends 'BaseType.gd'


func _init():
	name = 'Float'
	t = TYPE_REAL


func get(value):  # float
	if rematch and rematch is RegExMatch:
		return float(rematch.get_string().replace(',', '.'))

	return 0.0

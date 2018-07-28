
extends 'BaseType.gd'


var value


func _init():
	name = 'String'
	t = TYPE_STRING


# @param  Varian  _value
func check(_value):  # int
	value = _value
	return OK


func get(value):  # Variant
	return str(value)

extends RefCounted
class_name Blackboard

var data: Dictionary = {}

func set_value(key: String, value) -> void:
	data[key] = value

func get_value(key: String, default_value = null):
	if data.has(key):
		return data[key]
	return default_value

func has(key: String) -> bool:
	return data.has(key)

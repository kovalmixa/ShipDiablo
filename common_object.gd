extends Node

class_name CommonObject

var id : String
var type : String
var size : Vector2
var dir : String
var icon : String
var texture : String

func _init():
	id = ""
	type = ""
	size = Vector2(1, 1)
	icon = ""
	texture = ""
	dir = ""
	
func clone():
	var new_object = CommonObject.new()
	new_object.id = id
	new_object.type = type
	new_object.name = name
	new_object.size = size
	new_object.dir = dir
	new_object.icon = icon
	new_object.texture = texture
	return new_object
	
func read(_path : String) -> void:
	var file = ConfigFile.new()
	var error = file.load(_path + ".dat")
	if error != OK:
		print("Error loading config file!")
		print(_path)
		return
	
	name = file.get_value("general", "name")
	var slot_width = file.get_value("general", "slot_width", 1)
	var slot_height = file.get_value("general", "slot_height", 1)
	size = Vector2(slot_width, slot_height)
	icon = dir
	texture = dir
	var _texture = texture
	var _icon = file.get_value("graphics", "icon")
	icon += "/%s" % _icon
	texture += "/%s" % file.get_value("graphics", "texture", _icon)

func parse_id(_string) ->void:
	id = _string
	dir = "res://game_objects"
	if _string.find("sh") == 0:
		dir += "/ships"
		type = "hull"
		_string = _string.substr(3, _string.length() - 3)
	elif _string.find("t") == 0:
		dir += "/turrets"
		type = "turret"
		_string = _string.substr(2, _string.length() - 2)
	dir += "/%s" % _string
	var file_dir = dir
	file_dir += "/%s" % _string
	read(file_dir)

func get_object():
	var object = clone()
	return object

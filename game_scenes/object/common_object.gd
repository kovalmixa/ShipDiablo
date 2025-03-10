extends Node

class_name CommonObject

var id: String
var type: String
var size_type: String
var size: Vector2
var is_placable: bool

var dir: String
var icon: String
var textures: Array
var mass: int

func _init()-> void:
	id = ""
	type = ""
	size_type = ""
	size = Vector2(1, 1)
	is_placable = false

	dir = ""
	icon = ""
	textures.clear()
	
func clone():
	var new_object = CommonObject.new()
	new_object.id = id
	new_object.type = type
	new_object.size_type = size_type
	new_object.name = name
	new_object.size = size
	new_object.is_placable = is_placable
	new_object.dir = dir
	new_object.icon = icon
	new_object.textures = textures.duplicate()
	new_object.mass = mass
	return new_object
	
func read(_path : String) -> void:
	var file = ConfigFile.new()
	var error = file.load(_path + ".dat")
	if error != OK:
		print("Error loading config file!")
		return
	name = file.get_value("general", "name")
	size_type = file.get_value("general", "size_type", "")
	var slot_width = file.get_value("general", "slot_width", 1)
	var slot_height = file.get_value("general", "slot_height", 1)
	mass = file.get_value("general", "mass", 1)
	size = Vector2(slot_width, slot_height)
	icon = dir
	var _icon = file.get_value("graphics", "icon")
	icon += "/%s" % _icon
	var texture_arr = file.get_value("graphics", "texture", _icon).split(",")
	for txtr in texture_arr:
		var texture_path = dir + "/%s" % txtr
		textures.append(texture_path)
		
func parse_id(_string) ->void:
	id = _string
	dir = "res://game_objects"
	if _string.find("sh") == 0:
		dir += "/ships"
		type = "hull"
		is_placable = true
		_string = _string.substr(3, _string.length() - 3)
	elif _string.find("t") == 0:
		dir += "/turrets"
		type = "turret"
		is_placable = false
		_string = _string.substr(2, _string.length() - 2)
	dir += "/%s" % _string
	var file_dir = dir
	file_dir += "/%s" % _string
	read(file_dir)

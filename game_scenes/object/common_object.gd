extends Node

class_name CommonObject

var id : String
var type : String
var size_type : String
var size : Vector2

var dir : String
var icon : String
var textures :Array
var texture_index : int

var weapons_list :Array

class Weapon:
	var type :String
	var slot :int
	var size :String
	var x :int
	var y :int
	var floor :int

func _init():
	id = ""
	type = ""
	size_type = ""
	size = Vector2(1, 1)

	dir = ""
	icon = ""
	textures.clear()
	texture_index = 0
	
	weapons_list.clear()
	
func clone():
	var new_object = CommonObject.new()
	new_object.id = id
	new_object.type = type
	new_object.size_type = size_type
	new_object.name = name
	new_object.size = size
	new_object.dir = dir
	new_object.icon = icon
	new_object.texture_index = texture_index
	for i in range (textures.size()):
		new_object.textures.append(textures[i])
	for i in range (weapons_list.size()):
		new_object.weapons_list.append(weapons_list[i])
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
	size = Vector2(slot_width, slot_height)
	icon = dir
	var _icon = file.get_value("graphics", "icon")
	icon += "/%s" % _icon
	var texture_str = file.get_value("graphics", "texture", _icon)
	texture_index = texture_str.count(",") + 1
	
	for i in range(texture_index):
		textures.append(dir) 
		var index = texture_str.find(",")
		var texture_name
		if index != -1:
			texture_name = texture_str.substr(0, index)
		else:
			texture_name = texture_str
		textures[i] += "/%s" % texture_name
	
	var i: int = 0
	while file.has_section("weapon_%d" % i):
		var section_name = "weapon_%d" % i
		var weapon = Weapon.new()
		weapon.type = file.get_value(section_name, "type", "")
		weapon.slot = file.get_value(section_name, "slot", 0)
		weapon.size = file.get_value(section_name, "size")
		weapon.x = file.get_value(section_name, "x")
		weapon.y = file.get_value(section_name, "y")
		weapon.floor = file.get_value(section_name, "floor", 0)
		weapons_list.append(weapon) 
		i += 1
		
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

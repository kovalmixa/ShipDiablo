extends CommonObject

class_name WeaponObject

var object = get_parent()
var offset : Vector2
var rotation_speed : float

func clone():
	var new_object = WeaponObject.new()
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
	new_object.offset = offset
	new_object.rotation_speed = rotation_speed
	return new_object

func read(_path : String) -> void:
	var file = ConfigFile.new()
	var error = file.load(_path + ".dat")
	if error != OK:
		print("Error loading config file!")
		return
	super(_path)
	var offset_x = file.get_value("graphics", "offset_x", 0)
	var offset_y = file.get_value("graphics", "offset_y", 0)
	offset = Vector2(offset_x, offset_y)
	rotation_speed = file.get_value("rotation", "rotation_speed", 0)
	

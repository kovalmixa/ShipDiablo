extends CommonObject

class_name WeaponObject

var object = get_parent()

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
	return new_object

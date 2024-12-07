extends CommonObject

class_name WeaponObject

var object = get_parent()

var offset: Vector2

var rotation_speed: float

var weapon_list: Array
	
class Weapon:
	var x: int
	var y: int
	var projectile: projectileObject

func clone():
	var new_object = WeaponObject.new()
	new_object.id = id
	new_object.type = type
	new_object.size_type = size_type
	new_object.name = name
	new_object.size = size
	new_object.is_placable = is_placable
	new_object.dir = dir
	new_object.icon = icon
	new_object.weapon_list = weapon_list.duplicate()
	new_object.textures = textures.duplicate()
	new_object.offset = offset
	new_object.rotation_speed = rotation_speed
	return new_object

func read(_path: String) -> void:
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
	var i: int = 0
	while file.has_section("weapon_%d" % i):
		var section = "weapon_%d" % i
		var weapon = Weapon.new()
		weapon.x = file.get_value(section, "x", 0)
		weapon.y = file.get_value(section, "y", 0)
		var projectile_type = file.get_value(section, "projectile")
		var projectile_dir = "res://game_objects/projectiles/"
		var projectile_texture_name = file.get_value(projectile_type, "texture")
		var p_texture = projectile_dir + "%s" % projectile_texture_name
		var p_life_time = file.get_value(projectile_type, "life_time")
		var p_speed = file.get_value(projectile_type, "speed")
		weapon.projectile = projectileObject.new(p_texture, p_life_time, p_speed)
		weapon_list.append(weapon)
		i += 1

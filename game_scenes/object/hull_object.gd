extends CommonObject

class_name HullObject

var weapons_list: Array

class Weapon:
	var type: String
	var slot: int
	var size: String
	var x: int
	var y: int
	var floor: int
	var rotation_sector: Array
	var fire_sector: Array
var object = get_parent()

var has_any_turrets : bool

func _init() -> void:
	super()
	weapons_list.clear()

func clone():
	var new_object = HullObject.new()
	new_object.id = id
	new_object.type = type
	new_object.size_type = size_type
	new_object.name = name
	new_object.size = size
	new_object.is_placable = is_placable
	new_object.dir = dir
	new_object.icon = icon
	new_object.weapons_list = weapons_list.duplicate()
	new_object.textures = textures.duplicate()
	return new_object

func read(_path : String) -> void:
	var file = ConfigFile.new()
	var error = file.load(_path + ".dat")
	if error != OK:
		print("Error loading config file!")
		return
	super(_path)
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
		var rotation_sector_str = file.get_value(section_name, "rotation_sector", "0,360").split(";")
		for sctr in rotation_sector_str:
			var sector_t = sctr.split(",")
			var x_t = int(sector_t[0])
			var y_t = int(sector_t[1])
			weapon.rotation_sector.append(Vector2(x_t, y_t))
		var fire_sector_str = file.get_value(section_name, "rotation_sector", rotation_sector_str).split(";")
		for sctr in fire_sector_str:
			var sector_t = sctr.split(",")
			var x_t = int(sector_t[0])
			var y_t = int(sector_t[1])
			weapon.fire_sector.append(Vector2(x_t, y_t))
		weapons_list.append(weapon) 
		i += 1

extends CommonObject

class_name HullObject

var weapons_list :Array

class Weapon:
	var type :String
	var slot :int
	var size :String
	var x :int
	var y :int
	var floor :int
	var sector : Array
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
		var sector_str = file.get_value(section_name, "sector", "0,360")
		#var sector_str_index = sector_str.count(";") + 1
		#for j in range(sector_str_index):
		#	var index = sector_str.fin(";")
		#	var x_t = sector_t
		#	var sector_t = Vector2()
		#	if index != -1:
		#		texture_name = texture_str.substr(0, index)
		#	else:
		#		texture_name = texture_str
		#	textures[i] += "/%s" % texture_name
		#	weapon.sector.append(sector_t)
		
		weapons_list.append(weapon) 
		i += 1

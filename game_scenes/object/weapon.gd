extends Node2D

var type : String
var weapon

func _ready() -> void:
	weapon = WeaponObject.new()

func add_weapon(_j, _obj, _slot_type):
	if _obj:
		weapon = _obj.clone()
		$Sprite2D.texture = ResourceLoader.load(weapon.textures[0])
	else:
		weapon._init()
		$Sprite2D.texture = null

func shoot(_mouse_position):
	if weapon.id != "":
		print(name, _mouse_position)

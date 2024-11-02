extends Node2D

class_name TurretObj
var type : String
var turret

func _ready() -> void:
	turret = Turret.new()

func default():
	turret._init()
	$Sprite2D.texture = null

func add_turret(_obj):
	turret = _obj.clone()
	$Sprite2D.texture = ResourceLoader.load(turret.textures[0])

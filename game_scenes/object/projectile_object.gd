extends Node

class_name projectileObject

var texture: String
var life_time: float
var speed: int

func _init(_textrue: String, _life_time: float, _speed: int) -> void:
	texture = _textrue
	life_time = _life_time
	speed = _speed

extends Node2D

var type : String
var weapon
var rotation_direction = rotation

func _ready() -> void:
	weapon = WeaponObject.new()
	
func add_weapon(_j, _obj, _slot_type):
	if _obj:
		weapon = _obj.clone()
		$Sprite2D.texture = ResourceLoader.load(weapon.textures[0])
		$Sprite2D.offset = weapon.offset
	else:
		weapon._init()
		$Sprite2D.texture = null

func _on_shoot(_target_position):
	if weapon.id != "":
		print(name, _target_position)

func _on_rotate(_target_position):
	if weapon.id != "":
		var direction = (_target_position - position).normalized()
		rotation_direction = atan2(direction.y, direction.x) + PI/2

func rotation_process(delta):
	if weapon.id != "":
		var angle_difference = wrapf(rotation_direction - rotation, -PI, PI)
		if abs(angle_difference) > 0.1:
			rotation += sign(angle_difference) * weapon.rotation_speed * delta

func _process(delta: float) -> void:
	rotation_process(delta)
	

extends Node2D

var projectile_scene = preload("res://game_scenes/object/projectile.tscn")
var type: String
var slot: int
var weapon
var rotation_sector: Array
var fire_sector: Array
var rotation_direction = rotation
var can_shoot: bool

func _ready() -> void:
	weapon = WeaponObject.new()
	
func add_weapon(_j, _obj, _slot_type):
	if slot == _j:
		if _obj && type == _slot_type:
			weapon = _obj.clone()
			$Sprite2D.texture = ResourceLoader.load(weapon.textures[0])
			$Sprite2D.offset = weapon.offset
		else:
			weapon._init()
			$Sprite2D.texture = null

func _on_shoot(_target_position, _position, _rotation):
	if weapon.id != "":
		var direction = (_target_position - position - _position).normalized()
		var angle_to_target = atan2(direction.y, direction.x) + PI/2 - _rotation
		if can_shoot:
			for wpn in weapon.weapon_list:
				shoot(_target_position, wpn, _rotation)

func shoot(_target_position, _weapon, _rotation):
	var projectile = projectile_scene.instantiate()
	projectile.position = get_global_position() + Vector2(_weapon.x, -_weapon.y).rotated(rotation + _rotation)
	projectile.rotation = rotation - PI / 2 + _rotation
	projectile.target_position = _target_position
	projectile.texture = _weapon.projectile.texture
	projectile.life_time = _weapon.projectile.life_time
	projectile.speed = _weapon.projectile.speed
	get_tree().get_root().call_deferred("add_child", projectile)

func _on_rotate(_target_position, _position, _rotation):
	if weapon.id != "":
		var direction = (_target_position - position - _position).normalized()
		rotation_direction = atan2(direction.y, direction.x) + PI/2 - _rotation

func rotation_process(delta):
	if weapon.id != "":
		var angle_difference = wrapf(rotation_direction - rotation, -PI, PI)
		if abs(angle_difference) > 0.1:
			if in_sector(sign(angle_difference), rotation_sector, delta):
				rotation += sign(angle_difference) * weapon.rotation_speed * delta
		can_shoot = in_sector(sign(angle_difference), fire_sector, delta)
			
func in_sector(_angle_difference, _sector, delta = null):
	if delta != null:
		var rotation_value = rotation + _angle_difference * weapon.rotation_speed * delta
		for sctr in _sector:
			if rotation_value > deg_to_rad(sctr.x) && rotation_value < deg_to_rad(sctr.y):
				return true
		return false
	
func _process(delta: float) -> void:
	rotation_process(delta)
	

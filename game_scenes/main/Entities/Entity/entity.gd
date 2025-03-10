extends CharacterBody2D

class_name Entity

signal attack_sig(_target_position)
signal rotate_weapon(_target_position, _rotation)
const weapon_scene = preload("res://game_scenes/object/weapon.tscn")

@export var type: String
@export var max_speed = 300
@export var speed = 0.0
@export var speed_level = 0
@export var acceleration = 50.0
@export var rotation_speed = 1.025
@export var rotation_direction = 0
var mass = 0
var hull
var weapon_object_list: Array
var is_player
var PlayerFeatures

func _ready() -> void:
	hull = HullObject.new()
	
func setup(_type: String, _is_player: bool) -> void:
	type = _type
	is_player = _is_player
	add_hull(get_default())
	var hull_sprite = $Vehicle.get_node("hull_sprite_0")
	$CollisionShape2D.scale = Vector2(2,2)
	
	if is_player:
		UI.Inventory.hull_equip.object_changed.connect(_on_object_changed)
		var player_features_instance = preload("res://game_scenes/main/Entities/Player/PlayerFeatures.tscn")
		PlayerFeatures = player_features_instance.instantiate()
		add_child(PlayerFeatures)

func add_hull(_obj):
	destr()
	if typeof(_obj) == TYPE_OBJECT:
		hull = _obj.clone()
	else:
		hull._init()
		hull.parse_id(_obj)
	load_textures()
	if is_player && UI.Inventory:
		update_slot_weapons()
	calculate_mass()

func destr():
	for i in range (hull.textures.size()):
		var hull_sprite = "hull_sprite_%d" % i
		var children = $Vehicle.get_node(hull_sprite).get_children()
		for child in children:
			child.free()
		$Vehicle.get_node(hull_sprite).free()
	
func load_textures():
	for i in range (hull.textures.size()):
		var hull_sprite = Sprite2D.new()
		hull_sprite.texture = ResourceLoader.load(hull.textures[i])
		hull_sprite.name = "hull_sprite_%d" % i
		hull_sprite.scale = Vector2(5,5)
		$Vehicle.add_child(hull_sprite)
		var sprite2 = $Vehicle.get_node("hull_sprite_%d" % i)
		$CollisionShape2D.shape.height = sprite2.texture.get_height()
		$CollisionShape2D.shape.radius = sprite2.texture.get_width()

func update_slot_weapons():
	weapon_object_list.clear()
	var weapons = UI.Inventory.get_node("weapons")
	var i: int = 0
	const weapon_grid_load = preload("res://game_scenes/UI/inventory/slots_equip.tscn")
	var last_type = ""
	var children = weapons.get_children()
	var inventory_grid = UI.Inventory.get_node("inventory_grid")
	var saved_weapons: Array
	for child in children:
		for j in range(0, child.ARRAY_WIDTH):
			var slot = child.get_node("slot_%d_%d" % [0, j])
			if slot.object.id != "":
				saved_weapons.append(slot.object)
		child.destr()
		child.free()
	var slot_quantity = count_all_slots()
	while i < hull.weapons_list.size():
		if hull.weapons_list[i].type != last_type:
			last_type = hull.weapons_list[i].type
			var weapon_grid = weapon_grid_load.instantiate()
			setup_weapon_grid(weapon_grid, last_type, weapons, i);
			weapons.add_child(weapon_grid)
		var weapon_grid = weapons.get_node(last_type)
		var weapon = weapon_scene.instantiate()
		var x = hull.weapons_list[i].x
		var y = hull.weapons_list[i].y
		weapon.position = Vector2(x, -y)
		weapon.name = "weapon_%d" % i
		attack_sig.connect(weapon._on_shoot)
		rotate_weapon.connect(weapon._on_rotate)
		weapon_object_list.append(weapon)
		weapon.type = last_type
		weapon.slot = hull.weapons_list[i].slot
		var hull_sprite_name = "hull_sprite_%d" % hull.weapons_list[i].floor
		var hull_sprite = $Vehicle.get_node(hull_sprite_name)
		for sctr in hull.weapons_list[i].rotation_sector:
			weapon.rotation_sector.append(sctr)
		for sctr in hull.weapons_list[i].fire_sector:
			weapon.fire_sector.append(sctr)
		hull_sprite.add_child(weapon)
		var slot = "slot_%d_%d" % [0, hull.weapons_list[i].slot]
		weapon_grid.get_node(slot).slot_object_size = hull.weapons_list[i].size
		weapon_grid.get_node(slot).object_changed()
		weapon_object_list.append(hull_sprite.get_node("weapon_%d" % i))
		weapon_grid.object_changed.connect(_on_object_changed)
		weapon_grid.object_changed.connect(hull_sprite.get_node("weapon_%d" % i).add_weapon)
		i += 1
	i = 0
	for wpn in weapons.get_children():
		while i < wpn.ARRAY_WIDTH:
			var slot = "slot_%d_%d" % [0, i]
			for j in range(saved_weapons.size()):
				if saved_weapons[j].size_type == wpn.get_node(slot).slot_object_size:
					wpn.add_object_to_slot(0, i, saved_weapons[j])
					saved_weapons.remove_at(j)
					break
			i += 1
	for wpn in saved_weapons:
		inventory_grid.add_to_inventory(wpn)

func setup_weapon_grid(weapon_grid, last_type, weapons, i):
	weapon_grid.name = last_type
	weapon_grid.position.y = weapons.position.y + i * 40 
	weapon_grid.position.x = weapons.position.x
	weapon_grid.WIDTH = 1.6
	weapon_grid.HEIGHT = 1.6
	weapon_grid.type = last_type
	weapon_grid.ARRAY_WIDTH = count_type_slots(last_type)
	weapon_grid.OBJECT = "WeaponObject"
	weapon_grid.is_visible = true

func count_type_slots(_last_type):
	var i = 0
	var quantity = 0
	while i < hull.weapons_list.size() && hull.weapons_list[i].type == _last_type:
		quantity = hull.weapons_list[i].slot
		i += 1
	return quantity + 1

func count_all_slots():
	var quantity = 0
	var i = 0
	var last_type = ""
	while i < hull.weapons_list.size():
		if last_type != hull.weapons_list[i].type:
			quantity += count_type_slots("")
		last_type = hull.weapons_list[i].type
		i += 1
	return quantity

func _on_object_changed(_j, _obj, _slot_type):
	if _slot_type == "hull":
		if !_obj:
			add_hull(get_default())
		else:
			add_hull(_obj)
	else:
		calculate_mass()

func calculate_mass():
	mass = hull.mass
	for weap in weapon_object_list:
		mass += weap.weapon.mass

func get_default() -> String:
	if type == "ship":
		return "sh_boat"
	return ""
	
func _is_on_hull_area(_position: Vector2) -> bool:
	var shape = $CollisionShape2D.shape
	var a = shape.radius
	var b = shape.height / 2
	var x = _position.x
	var y = _position.y
	return (x * x) / (a * a) + (y * y) / (b * b) <= 1
	
func movement(delta):
	var target_speed = speed_level * -max_speed / 3
	if speed < target_speed:
		speed = min(speed + acceleration * delta, target_speed)
	elif speed > target_speed:
		speed = max(speed - acceleration * delta, target_speed)
	rotation += rotation_direction * rotation_speed * delta
	var motion = transform.y * speed * delta
	var collision = move_and_collide(motion)
	if collision:
		var collider = collision.get_collider()
		if collider is CharacterBody2D:
			var push_direction = (collider.global_position - global_position).normalized()
			var push_force = mass * push_direction * speed / -10
			print("Mass: %d" % mass)
			collider.velocity += push_force
			collider.set_meta("is_pushed", true)
	move_and_slide()

func attack(_target_position):
	attack_sig.emit(_target_position, position, rotation)

func weapon_rotation(_target_position):
	rotate_weapon.emit(_target_position, position, rotation)

func _physics_process(delta: float) -> void:
	movement(delta)
	if get_meta("is_pushed", false):
		var damping_factor = 1 / hull.mass
		velocity *= damping_factor 
		if velocity.length() < 1:
			set_meta("is_pushed", false)

extends CharacterBody2D

class_name ShipClass

signal attack_sig(_mouse_position)

var weapon_scene = load("res://game_scenes/object/weapon.tscn")

@export var max_speed = 300
@export var speed = 0.0
@export var speed_level = 0
@export var acceleration = 50.0
@export var rotation_speed = 1.025
@export var rotation_direction = 0
var hull

func _ready() -> void:
	hull = HullObject.new()

func add_hull(_obj):
	destr()
	if typeof(_obj) == TYPE_OBJECT:
		hull = _obj.clone()
	else:
		hull._init()
		hull.parse_id(_obj)
	load_ship_textures()
	update_slot_weapons()

func destr():
	for i in range (hull.texture_index):
		var hull_sprite = "hull_sprite_%d" % i
		var children = $Ship.get_node(hull_sprite).get_children()
		for child in children:
			child.free()
		$Ship.get_node(hull_sprite).free()

func load_ship_textures():
	for i in range (hull.texture_index):
		var hull_sprite = Sprite2D.new()
		hull_sprite.texture = ResourceLoader.load(hull.textures[i])
		hull_sprite.name = "hull_sprite_%d" % i
		hull_sprite.scale = Vector2(5,5)
		$Ship.add_child(hull_sprite)
		var sprite2 = $Ship.get_node("hull_sprite_%d" % i)
		$CollisionShape2D.shape.height = sprite2.texture.get_height()
		$CollisionShape2D.shape.radius = sprite2.texture.get_width()

func update_slot_weapons():
	var weapons = Inventory.get_node("weapons")
	var i: int = 0
	var weapon_grid_load = load("res://game_scenes/inventory/weapon_grid.tscn")
	var last_type = ""
	var children = weapons.get_children()
	var inventory_grid = Inventory.get_node("inventory_grid")
	for child in children:
		for j in range(0, child.ARRAY_WIDTH):
			var slot = child.get_node("slot_%d_%d" % [0, j])
			inventory_grid.add_to_inventory(slot.object)
		child.destr()
		child.free()
	var slot_quantity = count_all_slots()
	while i < hull.weapons_list.size():
		if hull.weapons_list[i].type != last_type:
			last_type = hull.weapons_list[i].type
			var weapon_grid = weapon_grid_load.instantiate()
			weapon_grid.name = last_type
			weapon_grid.position.y = weapons.position.y + i * 40 
			weapon_grid.position.x = weapons.position.x
			weapon_grid.WIDTH = 1.6
			weapon_grid.HEIGHT = 1.6
			weapon_grid.type = last_type
			weapon_grid.ARRAY_WIDTH = count_type_slots(last_type)
			weapon_grid.OBJECT = "WeaponObject"
			weapon_grid.is_visible = true
			weapons.add_child(weapon_grid)
		var weapon_grid = weapons.get_node(last_type)
		var weapon = weapon_scene.instantiate()
		var x = hull.weapons_list[i].x
		var y = hull.weapons_list[i].y
		weapon.position = Vector2(x, -y)
		weapon.name = "weapon_%d" % i
		attack_sig.connect(weapon.shoot)
		weapon.type = last_type
		var hull_sprite_name = "hull_sprite_%d" % hull.weapons_list[i].floor
		var hull_sprite = $Ship.get_node(hull_sprite_name)
		hull_sprite.add_child(weapon)
		var slot = "slot_%d_%d" % [0, hull.weapons_list[i].slot]
		weapon_grid.get_node(slot).slot_object_size = hull.weapons_list[i].size
		weapon_grid.get_node(slot).object_changed()
		weapon_grid.object_changed.connect(hull_sprite.get_node("weapon_%d" % i).add_weapon)
		i += 1

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
			add_hull("sh_boat")
		else:
			add_hull(_obj)

func movement(delta):
	var target_speed = speed_level * -max_speed / 3
	if speed < target_speed:
		speed = min(speed + acceleration * delta, target_speed)
	elif speed > target_speed:
		speed = max(speed - acceleration * delta, target_speed)
	rotation += rotation_direction * rotation_speed * delta
	velocity =  transform.y * speed
	move_and_slide()

func attack(_mouse_position):
	attack_sig.emit(_mouse_position)

func _physics_process(delta):
	movement(delta)

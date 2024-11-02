extends CharacterBody2D

class_name Ship

var turret_scene = load("res://game_scenes/object/turret.tscn")

@export var max_speed = 300
@export var speed = 0.0
@export var speed_level = 0
@export var acceleration = 50.0
@export var rotation_speed = 1.025
@export var rotation_direction = 0
var hull

func _ready() -> void:
	hull = Hull.new()

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

func add_turret(_j, _obj):
	for i in range (hull.texture_index):
		var hull_sprite_name = "hull_sprite_%d" % i
		var hull_sprite = $Ship.get_node(hull_sprite_name)
		var turret = "turret_%d" % _j
		if !hull_sprite.has_node(turret):
			continue
		if hull_sprite.get_node(turret).type == _obj.type:
			hull_sprite.get_node(turret).add_turret(_obj)
	
func remove_turret(_j):
	for i in range (hull.texture_index):
		var hull_sprite_name = "hull_sprite_%d" % i
		var hull_sprite = $Ship.get_node(hull_sprite_name)
		var turret = "turret_%d" % _j
		if !hull_sprite.has_node(turret):
			continue
		hull_sprite.get_node(turret).default()

func _on_object_changed(_j, _obj, _slot_type):
	if _slot_type == "hull":
		if !_obj:
			add_hull("sh_boat")
		else:
			add_hull(_obj)
	elif _slot_type == "turret":
		if !_obj:
			remove_turret(_j)
		else:
			add_turret(_j, _obj)

func update_slot_weapons():
	var weapons = Inventory.get_node("weapons")
	var i: int = 0
	var weapon_grid_load = load("res://game_scenes/inventory/weapon_grid.tscn")
	var last_type = ""
	var children = weapons.get_children()
	var inventory_grid = Inventory.get_node("inventory_grid")
	for child in children:
		for j in range(0, child.array_width):
			var slot = child.get_node("slot_%d_%d" % [0, j])
			inventory_grid.add_to_inventory(slot.object)
		child.destr()
		child.free()
	var j: int = 0
	while i < hull.weapons_list.size():
		if hull.weapons_list[i].type != last_type:
			last_type = hull.weapons_list[i].type
			var weapon_grid = weapon_grid_load.instantiate()
			weapon_grid.name = last_type
			weapon_grid.position.y = weapons.position.y + i * 40 
			weapon_grid.position.x = weapons.position.x
			weapon_grid.type = last_type
			weapon_grid.array_width =  count_slots(last_type)
			weapon_grid.is_visible = true
			weapons.add_child(weapon_grid)
			j = 0
		var weapon_grid = weapons.get_node(last_type)
		var slot = "slot_%d_%d" % [0, j]
		weapon_grid.get_node(slot).slot_object_size = hull.weapons_list[i].size
		weapon_grid.get_node(slot).object_changed()
		var turret = turret_scene.instantiate()
		var x = hull.weapons_list[i].x
		var y = hull.weapons_list[i].y
		turret.position = Vector2(x, -y)
		turret.name = "turret_%d" % i
		turret.type = last_type
		var hull_sprite_name = "hull_sprite_%d" % hull.weapons_list[i].floor
		var hull_sprite = $Ship.get_node(hull_sprite_name)
		hull_sprite.add_child(turret)
		i += 1
		j += 1

func count_slots(_last_type):
	var i = 0
	var quantity = 0
	while i < hull.weapons_list.size():
		if _last_type == hull.weapons_list[i].type:
			quantity += 1
		i += 1
	return quantity

func movement(delta):
	var target_speed = speed_level * -max_speed / 3
	if speed < target_speed:
		speed = min(speed + acceleration * delta, target_speed)
	elif speed > target_speed:
		speed = max(speed - acceleration * delta, target_speed)
	rotation += rotation_direction * rotation_speed * delta
	velocity =  transform.y * speed
	move_and_slide()

func _physics_process(delta):
	movement(delta)

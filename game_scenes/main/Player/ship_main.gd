extends CharacterBody2D

class_name Ship

@export var max_speed = 300
@export var speed = 0.0
@export var speed_level = 0
@export var acceleration = 50.0
@export var rotation_speed = 1.025
@export var rotation_direction = 0
var hull

func _ready() -> void:
	hull = Hull.new()

func addHull(_obj):
	if typeof(_obj) == TYPE_OBJECT:
		hull = _obj.clone()
	else:
		hull._init()
		hull.parse_id(_obj)
	$Sprite2D.texture = ResourceLoader.load(hull.texture)
	$CollisionShape2D.shape.height = $Sprite2D.texture.get_height()
	$CollisionShape2D.shape.radius = $Sprite2D.texture.get_width()
	update_slot_weapons()

func _on_object_changed(_obj, _slot_type):
	if _slot_type == "hull":
		if !_obj:
			addHull("sh_boat")
		else:
			addHull(_obj)
	elif _slot_type == "turret":
		pass

func update_slot_weapons():
	var weapons = Inventory.get_node("weapons")
	var i: int = 0
	var weapon_grid_load = load("res://game_scenes/inventory/weapon_grid.tscn")
	var last_type = ""
	var children = weapons.get_children()
	if hull.weapons_list.size() == 0:
		print(hull.name)
	for child in children:
		child.destr()
		child.free()
		
	while i < hull.weapons_list.size():
		if hull.weapons_list[i].type != last_type:
			last_type = hull.weapons_list[i].type
			var weapon_grid = weapon_grid_load.instantiate()
			weapon_grid.name = last_type
			weapon_grid.position.y = weapons.position.y + i * 40 
			weapon_grid.position.x = weapons.position.x
			weapon_grid.type = last_type
			weapon_grid.array_width = count_slots(last_type)
			weapons.add_child(weapon_grid)
		i += 1

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

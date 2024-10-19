extends Ship

var hull
func _ready():
	hull = Hull.new()
	hull.parse_id("sh_boat")
	$Sprite2D.scale = Vector2(5,5)
	$CollisionShape2D.scale = Vector2(2,2)
	$CollisionShape2D.shape.height = $Sprite2D.texture.get_height()
	$CollisionShape2D.shape.radius = $Sprite2D.texture.get_width()

func addHull(_obj):
	if typeof(_obj) == TYPE_OBJECT:
		hull = _obj.clone()
	else:
		hull.parse_id(_obj)
	$Sprite2D.texture = ResourceLoader.load(hull.texture)
	$CollisionShape2D.shape.height = $Sprite2D.texture.get_height()
	$CollisionShape2D.shape.radius = $Sprite2D.texture.get_width()
	#hull.turret_positions.clear()
	#if hull.id != "sh_boat":
	#	hull.turret_positions.append(Vector2(0,-20))
	#else:
	#	hull.turret_positions.append([Vector2(0,-10)])
	#if hull.has_any_turrets:
	#	change_turrets()

func _on_object_changed(_obj, _slot_type):
	if _slot_type == "hull":
		if !_obj:
			addHull("sh_boat")
		else:
			addHull(_obj)
	elif _slot_type == "turret":
		pass

func change_turrets():
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_up") && speed > -max_speed:
		speed_level += 1
	elif Input.is_action_just_pressed("ui_down") && speed < max_speed / 3:
		speed_level -= 1
	rotation_direction = Input.get_axis("ui_left" , "ui_right")

func _process(delta: float) -> void:
	pass

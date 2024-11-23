extends ShipClass

func _ready():
	super()
	add_hull("sh_boat")
	var hull_sprite = $Ship.get_node("hull_sprite_0")
	$CollisionShape2D.scale = Vector2(2,2)
	$CollisionShape2D.shape.height = hull_sprite.texture.get_height()
	$CollisionShape2D.shape.radius = hull_sprite.texture.get_width()

func _is_on_hull_area(_mouse_position):
	var radius = 70 / $Camera2D.zoom.x
	var axis1 = pow(position.x - _mouse_position.x , 2)
	var axis2 = pow(position.y - _mouse_position.y , 2)
	var length_between_points = sqrt(axis1 + axis2)
	if length_between_points <= radius:
		return true
	return false

func movement_control():
	if Input.is_action_just_pressed("ui_up") && speed > -max_speed:
		speed_level += 1
	elif Input.is_action_just_pressed("ui_down") && speed < max_speed / 3:
		speed_level -= 1
	rotation_direction = Input.get_axis("ui_left" , "ui_right")

func attack_control(event):
	if event is InputEventMouseButton:
		var mouse_position = get_viewport().get_mouse_position()
		if !Inventory.is_on_inventory_UI && event.pressed && !_is_on_hull_area(mouse_position):
			if event.button_index == MOUSE_BUTTON_LEFT:
				attack(get_global_mouse_position())
		
func _input(event: InputEvent) -> void:
	movement_control()
	attack_control(event)

func _process(delta: float) -> void:
	weapon_rotation(get_global_mouse_position(), position, rotation)

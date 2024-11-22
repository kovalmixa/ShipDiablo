extends ShipClass

func _ready():
	super()
	add_hull("sh_boat")
	var hull_sprite = $Ship.get_node("hull_sprite_0")
	$CollisionShape2D.scale = Vector2(2,2)
	$CollisionShape2D.shape.height = hull_sprite.texture.get_height()
	$CollisionShape2D.shape.radius = hull_sprite.texture.get_width()

func movement_control():
	if Input.is_action_just_pressed("ui_up") && speed > -max_speed:
		speed_level += 1
	elif Input.is_action_just_pressed("ui_down") && speed < max_speed / 3:
		speed_level -= 1
	rotation_direction = Input.get_axis("ui_left" , "ui_right")

func attack_control(event):
	if event is InputEventMouseButton:
		if !Inventory.is_on_inventory_UI && event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				attack(get_viewport().get_mouse_position())
		
func _input(event: InputEvent) -> void:
	movement_control()
	attack_control(event)

func _process(delta: float) -> void:
	pass

extends Ship

func _ready():
	super()
	addHull("sh_boat")
	$Sprite2D.scale = Vector2(5,5)
	$CollisionShape2D.scale = Vector2(2,2)
	$CollisionShape2D.shape.height = $Sprite2D.texture.get_height()
	$CollisionShape2D.shape.radius = $Sprite2D.texture.get_width()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_up") && speed > -max_speed:
		speed_level += 1
	elif Input.is_action_just_pressed("ui_down") && speed < max_speed / 3:
		speed_level -= 1
	rotation_direction = Input.get_axis("ui_left" , "ui_right")

func _process(delta: float) -> void:
	pass

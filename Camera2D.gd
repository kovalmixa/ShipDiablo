extends Camera2D

var inventory_position

func _ready():
	zoom = Vector2(1,1)

func _input(event):
	var current_zoom = zoom
	var new_zoom = 0.0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		new_zoom += 1
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		new_zoom -= 1
	new_zoom = current_zoom.x + new_zoom / 10
	if new_zoom <= 3 && new_zoom >= 0.1:
		zoom = Vector2(new_zoom, new_zoom)

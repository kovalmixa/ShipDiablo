extends Node2D

@onready var entity = $Entity
@export var type = ""
@export var is_player = false
var AI

func _ready():
	entity.setup(type, is_player)
	entity = $Entity

func setup() -> void:
	var new_script
	if type == "ship":
		new_script = preload("res://game_scenes/main/Entities/Entity/ship_class.gd")
	$Entity.set_script(new_script)
	$Entity.setup(type, is_player)

func _input(event: InputEvent) -> void:
	if is_player:
		player_movement_control()
		player_attack_control(event)

func player_movement_control():
	if Input.is_action_just_pressed("ui_up") && entity.speed > -entity.max_speed:
		entity.speed_level += 1
	elif Input.is_action_just_pressed("ui_down") && entity.speed < entity.max_speed / 3:
		entity.speed_level -= 1
	entity.rotation_direction = Input.get_axis("ui_left" , "ui_right")

func player_attack_control(event):
	if event is InputEventMouseButton:
		var PlayerFeatures = entity.PlayerFeatures
		var Camera = PlayerFeatures.Camera
		var padding = Vector2(get_viewport().size.x / 2 , get_viewport().size.y / 2)
		var zoom = Camera.zoom
		var mouse_position = get_viewport().get_mouse_position() / zoom - padding / zoom + entity.position
		if !UI.is_on_UI && !UI.Inventory.selection && !UI.Inventory.has_placed_obj:
			if event.pressed && !entity._is_on_hull_area(mouse_position):
				if event.button_index == MOUSE_BUTTON_LEFT:
					entity.attack(get_global_mouse_position())

func _is_on_hull_dep_area(_position) -> bool:
	var PlayerFeatures = entity.PlayerFeatures
	var Camera = PlayerFeatures.Camera
	var radius = 70 / Camera.zoom.x
	var body_position = entity.position
	var axis1 = pow(body_position.x - _position.x , 2)
	var axis2 = pow(body_position.y - _position.y , 2)
	var length_between_points = sqrt(axis1 + axis2)
	if length_between_points <= radius:
		return true
	return false

func _process(delta: float) -> void:
	entity.weapon_rotation(get_global_mouse_position())

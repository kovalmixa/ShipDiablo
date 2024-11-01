
extends Node2D

class_name slot_array

@export var array_width = 1
@export var array_height = 1 
@export var width :float = 1
@export var height :float = 1
@export var slot_texture = "res://textures/slot.png"

var base_scene = load("res://game_scenes/object/base.tscn")
var object_scene = load("res://game_scenes/object/object.tscn")
var slot_scale : Vector2
var label = Label.new()
var player_position = Vector2(0, 0)
var grid_size : Vector2
var slot_size : Vector2
var	array_top_corner
var array_low_corner
var is_on_array_grid
var is_visible = false
var is_grid_cleaned = false

var viewport_position =  Vector2(0,0)
var last_viewport_position = Vector2(0,0)

func _ready():
	slot_scale = Vector2(width, height)
	slot_size.x = load("res://textures/slot.png").get_width() * slot_scale.x
	slot_size.y = load("res://textures/slot.png").get_height() * slot_scale.y
	grid_size.x = slot_size.x * array_width
	grid_size.y = slot_size.y * array_height
	var half_grid = Vector2(grid_size.x / 2, grid_size.y / 2)
	array_top_corner = position - half_grid
	array_low_corner = position + half_grid
	draw_grid()
	draw_objects()
	label.name = "item_info"
	
func draw_grid():
	for i in range (array_height):
		for j in range (array_width):
			var slot_base = base_scene.instantiate()
			var x = int(array_top_corner.x + slot_size.x * j + slot_size.x / 2)
			var y = int(array_top_corner.y + slot_size.y * i + slot_size.y / 2)
			slot_base.position = Vector2(x, y)
			slot_base.name = "base%d_%d" % [i, j]
			slot_base.scale = slot_scale
			slot_base.top_level = true
			slot_base.texture = ResourceLoader.load(slot_texture)
			add_child(slot_base)

func draw_objects():
	for i in range (array_height):
		for j in range (array_width):
			var slot = object_scene.instantiate()
			var x = int(array_top_corner.x + slot_size.x * j + slot_size.x / 2)
			var y = int(array_top_corner.y + slot_size.y * i + slot_size.y / 2)
			slot.position = Vector2(x, y)
			slot.name = "slot_%d_%d" % [i, j]
			slot.scale = slot_scale
			slot.top_level = true
			slot.slot_size = slot_size
			slot._scale = Vector2(width, height)
			slot.array = get_path()
			add_child(slot)
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_viewport()
	mouse_click(event)
		
func mouse_viewport():
	if is_visible:
		var size = Vector2(1,1)
		var mouse_position = get_viewport().get_mouse_position()
		is_on_array_grid = _is_on_array_grid(mouse_position)
		if is_on_array_grid:
			var i = int((mouse_position.y - array_top_corner.y) / slot_size.y)
			var j = int((mouse_position.x - array_top_corner.x) / slot_size.x)
			viewport_position = Vector2(j, i)
			if array_width == 1 && array_height == 1:
				get_node("base%d_%d" % [i, j]).enable_shader()
			elif last_viewport_position.y != i || last_viewport_position.x != j:
				var slot = "slot_%d_%d" % [i, j]
				size = get_node(slot).object.size
				disable_slot_shaders(last_viewport_position.y, last_viewport_position.x, size)
				enable_slot_shaders(i, j, size)
			show_item_info(i, j, mouse_position)
			last_viewport_position = Vector2(i, j)
			is_grid_cleaned = false
		elif !is_grid_cleaned:
			if has_node("item_info"):
				remove_child(get_node("item_info"))
			disable_slot_shaders(last_viewport_position.y, last_viewport_position.x, size)
			is_grid_cleaned = true
		last_viewport_position = viewport_position
		
func enable_slot_shaders(_i, _j, _size):
	var slot = "slot_%d_%d" % [_i, _j]
	for i in range (_i, _i + _size.y):
		for j in range (_j, _j + _size.x):
			if i < array_height && j < array_width && i >= 0 && j >= 0:
				get_node("base%d_%d" % [i, j]).enable_shader()
				
func disable_slot_shaders(_i, _j, _size):
	var slot = "slot_%d_%d" % [_i, _j]
	for i in range (_i, _i + _size.y):
		for j in range (_j, _j + _size.x):
			if i < array_height && j < array_width && i >= 0 && j >= 0:
				get_node("base%d_%d" % [i, j]).disable_shader()

func mouse_click(event):
	pass
	
func _is_on_array_grid(_mouse_position):
	if _mouse_position.x > array_top_corner.x && _mouse_position.x < array_low_corner.x:
		if _mouse_position.y > array_top_corner.y && _mouse_position.y < array_low_corner.y:
			return true
	return false

func show_item_info(_i, _j, _mouse_position):
	if has_node("item_info"):
		remove_child(label)
	var slot = "slot_%d_%d" % [_i, _j]
	if get_node(slot).object.id != "":
		label.position = _mouse_position - Vector2(100, 50)
		label.text = get_node(slot).object.name + " %d" % get_node(slot).quantity
		label.top_level = true
		add_child(label)
		
func add_object_to_slot(_i, _j, _string, _quantity):
	var slot = get_node("slot_%d_%d" % [_i, _j])
	var size : Vector2
	if typeof(_string) == TYPE_OBJECT:
		size = _string.size
	else:
		size = check_size(_string)
	for i in range (_i, _i + size.y):
		for j in range (_j, _j + size.x):
			var sub_slot = get_node("slot_%d_%d" % [i, j])
			if sub_slot.object.id != "":
				if typeof(_string) == TYPE_OBJECT:
					if sub_slot.object.id == _string.id:
						_i = sub_slot.i
						_j = sub_slot.j
				else:
					if sub_slot.object.id == _string:
						_i = sub_slot.i
						_j = sub_slot.j
	for i in range (_i, _i + size.y):
		for j in range (_j, _j + size.x):
			var sub_slot = get_node("slot_%d_%d" % [i, j])
			if !(i == _i && j == _j):
				sub_slot.is_sub_slot = true
			sub_slot.i = _i
			sub_slot.j = _j
			sub_slot.add_object(_string, _quantity)
	
func can_add_to_slot(_i, _j, _string):
	if typeof(_string) == TYPE_STRING:
		if _string == "":
			return false
	var size :Vector2
	if typeof(_string) == TYPE_OBJECT:
		size = _string.size
	else:
		size = check_size(_string)
	if _j + size.x > array_width || _i + size.y > array_height:
		return false
	for i in range (_i, _i + size.y):
		for j in range (_j, _j + size.x):
			var sub_slot = "slot_%d_%d" % [i, j]
			if get_node(sub_slot).object.id != "":
				var id : String
				if typeof(_string) == TYPE_OBJECT:
					id = _string.id
				else:
					id = _string
				if get_node(sub_slot).object.id  != id:
					return false
	return true
	
func check_size(_string):
	var object = CommonObject.new()
	object.parse_id(_string)
	return object.size

func get_object(_i, _j):
	var slot = get_node("slot_%d_%d" % [_i, _j])
	return slot.object

func destr():
	var children = get_children()
	for child in children:
		child.free()

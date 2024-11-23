extends Node2D

@export var padding = 10

var object

var quantity : int
var i : int
var j : int
var is_sub_slot = false
var is_selection_slot = false
var is_inventory_object = false
var is_equipment_slot = false
var slot_object_size = ""
var slot_size : Vector2
var _scale : Vector2
var load_spite_position : Vector2
var load_label_position : Vector2
var slot_texture_scale : Vector2
var array : NodePath

func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is Label:
			child.position = position
			child.scale = Vector2(0.5, 0.5)
	quantity = 0
	load_spite_position = $Sprite2D.position
	load_label_position = $Quantity.position

func _is_zero(_quantity):
	if quantity == 0:
		var size = object.size
		if is_selection_slot:
			queue_free()
			return true
		default_slot()
		return true
	return false

func add_object(_string, _quantity = 1):
	if typeof(_string) == TYPE_OBJECT:
		quantity += _quantity
		if _is_zero(quantity):
			return
		object = _string.clone()
		object_changed()
		return
	quantity += _quantity
	if _is_zero(quantity):
		return
	object.parse_id(_string)
	object_changed()

func default_slot():
	object._init()
	quantity = 0
	is_sub_slot = false
	object_changed()
	
func slot_object_appereance(_position):
	var size : Vector2
	if is_equipment_slot:
		size = Vector2(1,1)
		$Sprite2D.position = load_spite_position
	else:
		size = object.size
	var texture_height = $Sprite2D.texture.get_height()
	if _scale.y > 1:
		$Sprite2D.scale = Vector2(0.9, 0.9) * (float(slot_size.y / _scale.y + padding) / float(texture_height)) * size.y
	else:
		$Sprite2D.scale = Vector2(0.9, 0.9) * (float(slot_size.y + padding) / float(texture_height)) * size.y
	$Quantity.position.x = _position.x + (size.x - 1) * (slot_size.y) / 2
	if size.x > 1:
		$Quantity.position.x += (slot_size.x - padding)
	else:
		$Quantity.position.x += (slot_size.x + padding) / 6
	$Quantity.position.y = _position.y + (size.y - 1) * (slot_size.y) 
	$Quantity.position.y += padding / size.y / 2 
	$Quantity.add_theme_font_size_override("font_size", (slot_size.y / (slot_size.y / 34) - padding) / 1.5)
	
	$Size.position.x = _position.x - (slot_size.x + padding) / 4
	$Size.position.y = _position.y + (size.y - 1) * (slot_size.y) + padding / size.y / 2
	$Size.add_theme_font_size_override("font_size", slot_size.y / (slot_size.y / 34) - padding)
	if _scale.y > 1:
		$Size.add_theme_font_size_override("font_size", slot_size.y / (slot_size.y / 34))
	
func  object_changed():
	if object.id == "" || is_sub_slot:
		$Sprite2D.texture = null
		$Quantity.text = ""
		if is_equipment_slot:
			var size = object.size
			$Size.position.x = load_label_position.x - (slot_size.x + padding) / 4
			$Size.position.y = load_label_position.y + (size.y - 1) * (slot_size.y) + padding / size.y / 2 
			$Size.text = slot_object_size
			$Size.add_theme_font_size_override("font_size", slot_size.y / (slot_size.y / 34))
		else:
			$Size.text = ""
		if object.id == "":
			$Sprite2D.position = load_spite_position
			$Quantity.position = load_label_position
	else:
		var size = object.size
		$Sprite2D.position.x = load_spite_position.x + (size.x - 1) * (slot_size.x) / 2
		$Sprite2D.position.y = load_spite_position.y + (size.y - 1) * (slot_size.y) / 2
		$Sprite2D.texture = ResourceLoader.load(object.icon)
		var icon = object.icon
		if is_equipment_slot && object.type == "hull":
			$Sprite2D.position = load_spite_position
			var texture_height = $Sprite2D.texture.get_height()
			$Sprite2D.position.y = load_spite_position.y 
			var persentage_of_scale = 1 / (_scale.y - (_scale.y - size.y))
			$Sprite2D.scale = Vector2(0.9, 0.9) * size.y * (slot_size.y / texture_height * persentage_of_scale)
			$Sprite2D.scale.y /= _scale.y / _scale.x
			$Sprite2D.scale /= _scale.y
		elif is_inventory_object:
			$Sprite2D.scale = Vector2(1,1)
		elif is_selection_slot:
			var texture_height = $Sprite2D.texture.get_height()
			$Sprite2D.scale = Vector2(0.9, 0.9) * (float(34 + padding) / float(texture_height)) * size.y
		else:
			slot_object_appereance(load_label_position)
		if quantity > 1:
			$Quantity.text = "%d" % quantity
		else:
			$Quantity.text = ""
		$Size.text = object.size_type

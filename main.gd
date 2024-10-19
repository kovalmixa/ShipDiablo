extends Node2D

var is_on_hull_area = false

@onready var Player = $Player

func _ready():
	Inventory.add_object_to_world.connect(_on_add_object_to_world)
	Inventory.remove_object_from_world.connect(_on_remove_object_from_world)
	Inventory.inventory_closed.connect(_on_inventory_closed)
		
func inventory_obj_init():
	var inventory_object = Inventory.object_scene.instantiate()
	inventory_object.name = "inventory_object"
	inventory_object.is_inventory_object = true
	add_child(inventory_object)
		
func _on_add_object_to_world(_obj):
	if has_node("inventory_object"):
		return
	inventory_obj_init()
	get_node("inventory_object").add_object(_obj.object.id, _obj.quantity)
	get_node("inventory_object").scale = Vector2(5,5)
	var sprite = get_node("inventory_object").get_node("Sprite2D")
	sprite.offset -= Vector2(0, sprite.texture.get_height() / 4)
	Inventory.get_node("selected_slot").free()
	Inventory.selection = false
	
func _on_remove_object_from_world(_slot_array):
	if !has_node("inventory_object"):
		return
	var selected_slot = Inventory.object_scene.instantiate()
	selected_slot.name = "selected_slot"
	selected_slot.slot_size = Vector2(34, 34)
	selected_slot.is_selection_slot = true
	var inventory_object = get_node("inventory_object")
	Inventory.add_child(selected_slot)
	Inventory.get_node("selected_slot").add_object(inventory_object.object, inventory_object.quantity)
	Inventory.selection = true
	inventory_object.free()
		
func _is_on_hull_area(_mouse_position):
	var radius = 70 / $Player/Camera2D.zoom.x
	var axis1 = pow(Player.position.x - _mouse_position.x , 2)
	var axis2 = pow(Player.position.y - _mouse_position.y , 2)
	var length_between_points = sqrt(axis1 + axis2)
	if length_between_points <= radius:
		return true
	return false
	
func _input(event: InputEvent) -> void:
	mouse_click(event)
	
func mouse_click(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if is_on_hull_area:
				if has_node("inventory_object"):
					place_the_hull()
				else:
					take_the_hull()
		
func place_the_hull():
	if Player.hull.id == get_node("inventory_object").object.id:
		return
	$inventory_object/Sprite2D.self_modulate = Color(1, 1, 1)
	if Player.hull.id != get_node("inventory_object").object.id && Player.hull.id != "sh_boat":
		Inventory.get_node("Inventory_grid").add_to_inventory(Player.hull.id, 1)
	var hull_equip_slot = Inventory.get_node("ship_slots_equip_hull")
	hull_equip_slot.add_object_to_slot(0, 0, get_node("inventory_object").object)
	get_node("inventory_object").add_object(get_node("inventory_object").object.id, -1)
	if get_node("inventory_object").object.id == "":
		get_node("inventory_object").free()
	
func take_the_hull():
	if !Inventory.visible || Player.hull.id == "sh_boat":
		return
	if has_node("inventory_object") && get_node("inventory_object").object.id == Player.hull.id:
		get_node("inventory_object").add_object(get_node("inventory_object").object)
		var hull_equip_slot = Inventory.get_node("ship_slots_equip_hull")
		hull_equip_slot.add_object_to_slot(0, 0, get_node("inventory_object").object, -1)
	elif !has_node("inventory_object"):
		inventory_obj_init()
		get_node("inventory_object").add_object(Player.hull.id)
		get_node("inventory_object").scale = Vector2(5,5)
		var sprite = get_node("inventory_object").get_node("Sprite2D")
		sprite.offset -= Vector2(0, sprite.texture.get_height() / 4)
		var hull_equip_slot = Inventory.get_node("ship_slots_equip_hull")
		hull_equip_slot.add_object_to_slot(0, 0, Player.hull.get_object(), -1)
		
func _on_inventory_closed():
	if has_node("inventory_object"):
		var Inventory_grid = Inventory.get_node("Inventory_grid")
		var inventory_object = get_node("inventory_object")
		Inventory_grid.add_to_inventory(inventory_object.object.id, inventory_object.quantity)
		inventory_object.free()
	
func _process(delta: float) -> void:
	var padding = Vector2(get_viewport().size.x / 2 , get_viewport().size.y / 2)
	var zoom = $Player/Camera2D.zoom
	var mouse_position = get_viewport().get_mouse_position() / zoom - padding / zoom + $Player.position 
	is_on_hull_area = _is_on_hull_area(mouse_position)
	if has_node("inventory_object"):
		get_node("inventory_object").position = mouse_position
		var texture_width = $inventory_object/Sprite2D.texture.get_width() /  6
		var texture_height = $inventory_object/Sprite2D.texture.get_height() / 6
		var texture_scale = Vector2(texture_width, texture_height)
		var texture_size = texture_scale * 6
		var object_size = get_node("inventory_object").object.size
		$inventory_object/Label.add_theme_font_size_override("font_size", 50 / zoom.x)
		$inventory_object/Label.position = mouse_position + texture_scale
		if is_on_hull_area:
			$inventory_object/Sprite2D.self_modulate = Color(0, 1, 0)
			get_node("inventory_object").position.x = Player.position.x
			get_node("inventory_object").position.y = Player.position.y + texture_size.y / 2
			get_node("inventory_object").rotation = Player.rotation
		else:
			$inventory_object/Sprite2D.self_modulate = Color(1, 0, 0)
			get_node("inventory_object").position.x = mouse_position.x
			get_node("inventory_object").position.y = mouse_position.y + texture_size.y / 2
			get_node("inventory_object").rotation = 0

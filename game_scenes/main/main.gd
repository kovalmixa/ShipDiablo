extends Node2D

var is_on_hull_area = false

@onready var Player = $Player
const object_scene = preload("res://game_scenes/object/object.tscn")

func _ready():
	UI.Inventory.add_object_to_world.connect(_on_add_object_to_world)
	UI.Inventory.remove_object_from_world.connect(_on_remove_object_from_world)
	UI.inventory_closed.connect(_on_inventory_closed)
		
func inventory_obj_init():
	var inventory_object = object_scene.instantiate()
	inventory_object.name = "inventory_object"
	inventory_object.is_inventory_object = true
	inventory_object.object = CommonObject.new()
	add_child(inventory_object)
		
func _on_add_object_to_world(_obj):
	if has_node("inventory_object"):
		return
	inventory_obj_init()
	get_node("inventory_object").add_object(_obj.object, _obj.quantity)
	get_node("inventory_object").scale = Vector2(5,5)
	var sprite = get_node("inventory_object").get_node("Sprite2D")
	sprite.offset -= Vector2(0, sprite.texture.get_height() / 4)
	UI.Inventory.get_node("selected_slot").free()
	UI.Inventory.selection = false
	UI.Inventory.has_placed_obj = true
	
func _on_remove_object_from_world(_slot_array):
	if !has_node("inventory_object"):
		return
	var selected_slot = object_scene.instantiate()
	selected_slot.name = "selected_slot"
	selected_slot.slot_size = Vector2(34, 34)
	selected_slot.is_selection_slot = true
	var inventory_object = get_node("inventory_object")
	UI.Inventory.add_child(selected_slot)
	UI.Inventory.get_node("selected_slot").add_object(inventory_object.object, inventory_object.quantity)
	UI.Inventory.selection = true
	UI.Inventory.has_placed_obj = false
	inventory_object.free()
	
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
	var hull = Player.entity.hull
	if hull.id == get_node("inventory_object").object.id:
		return
	$inventory_object/Sprite2D.self_modulate = Color(1, 1, 1)
	if hull.id != get_node("inventory_object").object.id && hull.id != "sh_boat":
		UI.Inventory.get_node("Inventory_grid").add_to_inventory(hull.id, 1)
		UI.Inventory.has_placed_obj = false
	var hull_equip_slot = UI.Inventory.hull_equip
	hull_equip_slot.add_object_to_slot(0, 0, get_node("inventory_object").object)
	get_node("inventory_object").add_object(get_node("inventory_object").object.id, -1)
	if get_node("inventory_object").object.id == "":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_node("inventory_object").free()
		UI.Inventory.has_placed_obj = false
		
func take_the_hull():
	var hull = Player.entity.hull
	if !UI.Inventory.visible || hull.id == "sh_boat":
		return
	if has_node("inventory_object") && get_node("inventory_object").object.id == hull.id:
		var hull_equip_slot = UI.Inventory.get_node("ship_slots_equip_hull")
		hull_equip_slot.add_object_to_slot(0, 0, get_node("inventory_object").object, -1)
	elif !has_node("inventory_object"):
		inventory_obj_init()
		get_node("inventory_object").add_object(hull.id)
		get_node("inventory_object").scale = Vector2(5,5)
		var sprite = get_node("inventory_object").get_node("Sprite2D")
		sprite.offset -= Vector2(0, sprite.texture.get_height() / 4)
		var hull_equip_slot = UI.Inventory.hull_equip
		hull_equip_slot.add_object_to_slot(0, 0, hull.clone(), -1)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _on_inventory_closed():
	if has_node("inventory_object"):
		var inventory_grid = UI.Inventory.get_node("inventory_grid")
		var inventory_object = get_node("inventory_object")
		inventory_grid.add_to_inventory(inventory_object.object.id, inventory_object.quantity)
		inventory_object.free()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(delta: float) -> void:
	var padding = Vector2(get_viewport().size.x / 2 , get_viewport().size.y / 2)
	var PlayerFeatures = $Player.entity.PlayerFeatures
	var Camera = PlayerFeatures.Camera
	var zoom = Camera.zoom
	var mouse_position = get_viewport().get_mouse_position() / zoom - padding / zoom + Player.entity.position 
	is_on_hull_area = Player._is_on_hull_dep_area(mouse_position)
	if has_node("inventory_object"):
		var inventory_object = get_node("inventory_object")
		inventory_object.position = mouse_position
		var texture_width = $inventory_object/Sprite2D.texture.get_width() /  6
		var texture_height = $inventory_object/Sprite2D.texture.get_height() / 6
		var texture_scale = Vector2(texture_width, texture_height)
		var texture_size = texture_scale * 6
		var object_size =inventory_object.object.size
		$inventory_object/Quantity.add_theme_font_size_override("font_size", 50 / zoom.x)
		$inventory_object/Quantity.position = mouse_position + texture_scale
		var player_body = Player.entity
		if is_on_hull_area && Player.entity.hull.id != inventory_object.object.id:
			$inventory_object/Sprite2D.self_modulate = Color(0, 1, 0)
			inventory_object.position.x = player_body.position.x
			inventory_object.position.y = player_body.position.y
			inventory_object.rotation = player_body.rotation
		else:
			$inventory_object/Sprite2D.self_modulate = Color(1, 0, 0)
			inventory_object.position.x = mouse_position.x
			inventory_object.position.y = mouse_position.y + texture_size.y / 2
			inventory_object.rotation = 0

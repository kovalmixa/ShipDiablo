extends slot_array

class_name Inventory_type

var last_selection_state = false
var last_viewport_position2 = Vector2(0,0)

func _ready() -> void:
	super()
	Inventory.inventory_opened.connect(_on_inventory_opened)
	Inventory.inventory_closed.connect(_on_inventory_closed)

func mouse_viewport():
	var selection = Inventory.selection
	if is_visible:
		var mouse_position = get_viewport().get_mouse_position()
		is_on_array_grid = _is_on_array_grid(mouse_position)
		if is_on_array_grid:
			var i = int((mouse_position.y - array_top_corner.y) / slot_size.y)
			var j = int((mouse_position.x - array_top_corner.x) / slot_size.x)
			viewport_position = Vector2(j, i)
			if array_width == 1 && array_height == 1:
				get_node("base%d_%d" % [i, j]).enable_shader()
			elif last_viewport_position.y != i || last_viewport_position.x != j:
				if selection && Inventory.has_node("selected_slot"):
					var size = Inventory.get_node("selected_slot").object.size
					disable_slot_shaders(last_viewport_position.y, last_viewport_position.x, size)
					enable_slot_shaders(i, j, size)
				else:
					var slot = "slot_%d_%d" % [i, j]
					var size = get_node(slot).object.size
					disable_slot_shaders(last_viewport_position.y, last_viewport_position.x, size)
					enable_slot_shaders(i, j, size)
			show_item_info(i, j, mouse_position)
			last_viewport_position = Vector2(i, j)
		else:
			var slot = "slot_%d_%d" % [viewport_position.y, viewport_position.x]
			var size = get_node(slot).object.size
			disable_slot_shaders(last_viewport_position.y, last_viewport_position.x, size)
			if has_node("item_info"):
				remove_child(get_node("item_info"))
			if last_viewport_position != Vector2(0,0):
				last_viewport_position = Vector2(0,0)
			else:
				last_viewport_position = Vector2(1,1)
		last_viewport_position = viewport_position

func enable_slot_shaders(_i, _j, _size):
	var selection = Inventory.selection
	var slot = "slot_%d_%d" % [_i, _j]
	if get_node(slot).is_sub_slot && !selection:
		_i = get_node(slot).i
		_j = get_node(slot).j
	if !selection:
		_size = get_node(slot).object.size
	for i in range (_i, _i + _size.y):
		for j in range (_j, _j + _size.x):
			if i < array_height && j < array_width && i >= 0 && j >= 0:
				get_node("base%d_%d" % [i, j]).enable_shader()
				
func disable_slot_shaders(_i, _j, _size):
	var selection = Inventory.selection
	var slot = "slot_%d_%d" % [_i, _j]
	if get_node(slot).is_sub_slot && !selection:
		_i = get_node(slot).i
		_j = get_node(slot).j
	if !selection:
		_size = get_node(slot).object.size
	for i in range (_i, _i + _size.y):
		for j in range (_j, _j + _size.x):
			if i < array_height && j < array_width && i >= 0 && j >= 0:
				get_node("base%d_%d" % [i, j]).disable_shader()

func mouse_click(event: InputEvent) -> void:
	var selection = Inventory.selection
	if !Inventory.visible:
		return
	if event is InputEventMouseButton:
		if is_on_array_grid && event.pressed:
			var i = int((event.position.y - array_top_corner.y) / slot_size.y)
			var j = int((event.position.x - array_top_corner.x) / slot_size.x)
			if event.button_index == MOUSE_BUTTON_LEFT:
				left_click(i, j)
			elif !selection && event.button_index == MOUSE_BUTTON_RIGHT:
				if !selection && get_node("slot_%d_%d" % [i, j]).object.id == "":
					return
				var quantity
				if get_node("slot_%d_%d" % [i, j]).quantity > 1:
					quantity = 0.5
				else:
					quantity = 1
				selection = !selection
				if selection:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				Inventory.selection = selection
				select_inventory_slot(i, j, quantity)
			elif selection && event.button_index == MOUSE_BUTTON_RIGHT:
				if Inventory.has_node("selected_slot"):
					if can_add_to_slot(i, j, Inventory.get_node("selected_slot").object):
						add_object_to_slot(i, j, Inventory.get_node("selected_slot").object, 1)
						Inventory.get_node("selected_slot").add_object(Inventory.get_node("selected_slot").object, -1)
						if Inventory.get_node("selected_slot").quantity == 0:
							Inventory.get_node("selected_slot").free()
							Inventory.selection = false
							Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
											
func left_click(_i, _j):
	var selection = Inventory.selection
	if !selection && get_node("slot_%d_%d" % [_i, _j]).object.id == "":
		return
	var quantity = 1
	selection = !selection
	Inventory.selection = selection
	if selection:
		select_inventory_slot(_i, _j, quantity)
	elif Inventory.has_node("selected_slot"):
		if can_add_to_slot(_i, _j, Inventory.get_node("selected_slot").object):
			var selected_slot = Inventory.get_node("selected_slot")
			add_object_to_slot(_i, _j, selected_slot.object, selected_slot.quantity)
			Inventory.get_node("selected_slot").free()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Inventory.selection = true
						
func select_inventory_slot(_i, _j, _quantity):
	var slot = "slot_%d_%d" % [_i, _j]
	if get_node(slot).object.id != "":
		if get_node(slot).is_sub_slot:
			_i = get_node(slot).i
			_j = get_node(slot).j
			slot = "slot_%d_%d" % [_i, _j]
		var size = get_node(slot).object.size
		var selected_slot = object_scene.instantiate()
		selected_slot.name = "selected_slot"
		selected_slot.is_selection_slot = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Inventory.add_child(selected_slot)
		Inventory.get_node("selected_slot").add_object(get_node(slot).object, floor(get_node(slot).quantity * _quantity))
		add_object_to_slot(_i, _j, get_node(slot).object, -floor(get_node(slot).quantity * _quantity))
		disable_slot_shaders(_i, _j, size)
			
func add_to_inventory(_string, _quantity):
	var size = check_size(_string)
	for i in range (array_width - size.y + 1):
		for j in range (array_height - size.x + 1):
			if  can_add_to_slot(i, j, _string):
				add_object_to_slot(i, j, _string, _quantity)
				return
				
func _on_inventory_opened():
	is_visible = true
	
func _on_inventory_closed():
	is_visible = false

func _process(delta: float) -> void:
	var selection = Inventory.selection
	if !Inventory.visible:
		return
	var last_texture_size
	if selection && Inventory.has_node("selected_slot"):
		var mouse_position = get_viewport().get_mouse_position()
		var object_size = Inventory.get_node("selected_slot").object.size
		Inventory.get_node("selected_slot").position = mouse_position
		Inventory.get_node("selected_slot").get_node("Quantity").position = mouse_position + slot_size / 2 
	if selection == false && last_selection_state != selection:
		var grid_coordinates = get_viewport().get_mouse_position() - array_top_corner
		for i in range (array_height):
			for j in range (array_width):
				if int(grid_coordinates.y / slot_size.y) == i && int(grid_coordinates.x / slot_size.x) == j:
					continue
				get_node("base%d_%d" % [i, j]).disable_shader()
	last_selection_state = selection

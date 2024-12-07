extends slot_array

class_name Inventory_type

var last_selection_state = false
var last_viewport_position2 = Vector2(0,0)

func _ready() -> void:
	super()
	UI.inventory_opened.connect(_on_inventory_opened)
	UI.inventory_closed.connect(_on_inventory_closed)

func mouse_viewport():
	var selection = UI.Inventory.selection
	if is_visible:
		var mouse_position = get_viewport().get_mouse_position()
		is_on_array_grid = _is_on_array_grid(mouse_position)
		if is_on_array_grid:
			var i = int((mouse_position.y - array_top_corner.y) / slot_size.y)
			var j = int((mouse_position.x - array_top_corner.x) / slot_size.x)
			viewport_position = Vector2(j, i)
			if ARRAY_WIDTH == 1 && ARRAY_HEIGHT == 1:
				get_node("base%d_%d" % [i, j]).enable_shader()
			elif last_viewport_position.y != i || last_viewport_position.x != j:
				if selection && UI.Inventory.has_node("selected_slot"):
					var size = UI.Inventory.get_node("selected_slot").object.size
					disable_slot_shaders(last_viewport_position.y, last_viewport_position.x, size)
					enable_slot_shaders(i, j, size)
				else:
					var slot = "slot_%d_%d" % [i, j]
					var size = get_node(slot).object.size
					disable_slot_shaders(last_viewport_position.y, last_viewport_position.x, size)
					enable_slot_shaders(i, j, size)
			show_item_info(i, j, mouse_position)
			last_viewport_position = Vector2(i, j)
			is_grid_cleaned = false
		elif !is_grid_cleaned:
			disable_slot_shaders(0, 0, Vector2(ARRAY_WIDTH, ARRAY_HEIGHT))
			var slot = "slot_%d_%d" % [viewport_position.y, viewport_position.x]
			var size = get_node(slot).object.size
			if !selection:
				disable_slot_shaders(last_viewport_position.y, last_viewport_position.x, size)
			if has_node("item_info"):
				remove_child(get_node("item_info"))
			if last_viewport_position != Vector2(0,0):
				last_viewport_position = Vector2(0,0)
			else:
				last_viewport_position = Vector2(1,1)
			is_grid_cleaned = true
		last_viewport_position = viewport_position

func enable_slot_shaders(_i, _j, _size):
	var selection = UI.Inventory.selection
	var slot = "slot_%d_%d" % [_i, _j]
	if get_node(slot).is_sub_slot && !selection:
		_i = get_node(slot).i
		_j = get_node(slot).j
	if !selection:
		_size = get_node(slot).object.size
	for i in range (_i, _i + _size.y):
		for j in range (_j, _j + _size.x):
			if i < ARRAY_HEIGHT && j < ARRAY_WIDTH && i >= 0 && j >= 0:
				get_node("base%d_%d" % [i, j]).enable_shader()
				
func disable_slot_shaders(_i, _j, _size):
	var selection = UI.Inventory.selection
	var slot = "slot_%d_%d" % [_i, _j]
	if get_node(slot).is_sub_slot && !selection:
		_i = get_node(slot).i
		_j = get_node(slot).j
	if !selection:
		_size = get_node(slot).object.size
	for i in range (_i, _i + _size.y):
		for j in range (_j, _j + _size.x):
			if i < ARRAY_HEIGHT && j < ARRAY_WIDTH && i >= 0 && j >= 0:
				get_node("base%d_%d" % [i, j]).disable_shader()

func mouse_click(event: InputEvent) -> void:
	var selection = UI.Inventory.selection
	if !UI.Inventory.visible:
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
				UI.Inventory.selection = selection
				select_inventory_slot(i, j, quantity)
			elif selection && event.button_index == MOUSE_BUTTON_RIGHT:
				if UI.Inventory.has_node("selected_slot"):
					if can_add_to_slot(i, j, UI.Inventory.get_node("selected_slot").object):
						add_object_to_slot(i, j, UI.Inventory.get_node("selected_slot").object, 1)
						UI.Inventory.get_node("selected_slot").add_object(UI.Inventory.get_node("selected_slot").object, -1)
						if UI.Inventory.get_node("selected_slot").quantity == 0:
							UI.Inventory.get_node("selected_slot").free()
							UI.Inventory.selection = false
							Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
											
func left_click(_i, _j):
	var selection = UI.Inventory.selection
	if !selection && get_node("slot_%d_%d" % [_i, _j]).object.id == "":
		return
	var quantity = 1
	selection = !selection
	UI.Inventory.selection = selection
	if selection:
		select_inventory_slot(_i, _j, quantity)
	elif UI.Inventory.has_node("selected_slot"):
		if can_add_to_slot(_i, _j, UI.Inventory.get_node("selected_slot").object):
			var selected_slot = UI.Inventory.get_node("selected_slot")
			add_object_to_slot(_i, _j, selected_slot.object, selected_slot.quantity)
			UI.Inventory.get_node("selected_slot").free()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			UI.Inventory.selection = true
						
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
		selected_slot.slot_size = Vector2(34, 34)
		selected_slot.is_selection_slot = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		UI.Inventory.add_child(selected_slot)
		UI.Inventory.get_node("selected_slot").add_object(get_node(slot).object, floor(get_node(slot).quantity * _quantity))
		add_object_to_slot(_i, _j, get_node(slot).object, -floor(get_node(slot).quantity * _quantity))
		disable_slot_shaders(_i, _j, size)
			
func add_to_inventory(_string, _quantity = 1):
	var size
	if typeof(_string) == TYPE_STRING:
		if _string == "":
			return
		size = check_size(_string)
	else:
		if _string.id == "":
			return
		size = _string.size
	for i in range (ARRAY_WIDTH - size.y + 1):
		for j in range (ARRAY_HEIGHT - size.x + 1):
			if can_add_to_slot(i, j, _string):
				add_object_to_slot(i, j, _string, _quantity)
				return
				
func _on_inventory_opened():
	is_visible = true
	
func _on_inventory_closed():
	is_visible = false

func slot_selection_proc():
	var selection = UI.Inventory.selection
	if !UI.Inventory.visible:
		return
	if selection && UI.Inventory.has_node("selected_slot"):
		var selected_slot = UI.Inventory.get_node("selected_slot")
		var mouse_position = get_viewport().get_mouse_position()
		selected_slot.position = mouse_position
		selected_slot.slot_object_appereance(mouse_position)
	elif last_selection_state != selection:
		var grid_coordinates = get_viewport().get_mouse_position() - array_top_corner
		for i in range (ARRAY_HEIGHT):
			for j in range (ARRAY_WIDTH):
				if int(grid_coordinates.y / slot_size.y) == i && int(grid_coordinates.x / slot_size.x) == j:
					continue
				get_node("base%d_%d" % [i, j]).disable_shader()
	last_selection_state = selection

func _process(delta: float) -> void:
	slot_selection_proc()

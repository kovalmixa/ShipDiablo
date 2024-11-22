extends CanvasLayer

signal inventory_opened()
signal inventory_closed()
signal add_object_to_world(_obj)
signal remove_object_from_world()

var selection = false
var is_on_inventory_UI = false
var on_slot_array = ""
var children
		
func _ready():
	inventory_opened.connect(_on_inventory_opened)
	inventory_closed.connect(_on_inventory_closed)
	children = get_children()
	
	var Inventory_grid = get_node("inventory_grid")
	Inventory_grid.add_to_inventory("t_mg45", 12)
	Inventory_grid.add_to_inventory("sh_small_patrol_boat", 12)
 
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed && event.keycode == KEY_I:
		if !visible:
			inventory_opened.emit()
		else:
			inventory_closed.emit()
	if visible && event is InputEventKey && event.pressed && event.keycode == KEY_ESCAPE:
		inventory_closed.emit()
			
func _on_inventory_opened():
	show()

func _on_inventory_closed():
	if has_node("selected_slot"):
		$Inventory_grid.add_to_inventory(get_node("selected_slot").object.id, get_node("selected_slot").quantity)
		get_node("selected_slot").free()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		selection = false
	hide()

func _is_on_inventory_UI():
	for child in children:
		if child == $weapons:
			for child2 in child.get_children():
				if child2 is Inventory_type:
					if child2.is_on_array_grid:
						is_on_inventory_UI = true
						on_slot_array = child2.name
						return
		if child is Inventory_type:
			if child.is_on_array_grid:
				is_on_inventory_UI = true
				on_slot_array = child.name
				return
	is_on_inventory_UI = false
	return

func _process(delta):
	if visible:
		_is_on_inventory_UI()
		if !is_on_inventory_UI && selection && has_node("selected_slot"):
			if get_node("selected_slot").object.type == "hull":
				add_object_to_world.emit(get_node("selected_slot"))
		elif is_on_inventory_UI:
			remove_object_from_world.emit(on_slot_array)

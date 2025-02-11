extends CanvasLayer

signal add_object_to_world(_obj)
signal remove_object_from_world()

var selection = false
var is_on_UI = false
var has_placed_obj = false
var on_slot_array = ""
var children
var hull_equip
		
func _ready() -> void:
	
	children = get_children()
	hull_equip = $hull_equip
	
	var Inventory_grid = get_node("inventory_grid")
	Inventory_grid.add_to_inventory("t_mg45", 12)
	Inventory_grid.add_to_inventory("sh_small_patrol_boat", 12)
	UI.inventory_opened.connect(_on_inventory_opened)
	UI.inventory_closed.connect(_on_inventory_closed)
			
func _on_inventory_opened() -> void:
	show()

func _on_inventory_closed() -> void:
	if has_node("selected_slot"):
		$Inventory_grid.add_to_inventory(get_node("selected_slot").object.id, get_node("selected_slot").quantity)
		get_node("selected_slot").free()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		selection = false
	hide()

func _is_on_UI() -> bool:
	for child in children:
		if child == $weapons:
			for child2 in child.get_children():
				if child2 is Inventory_type:
					if child2.is_on_array_grid:
						on_slot_array = child2.name
						return true
		if child is Inventory_type:
			if child.is_on_array_grid:
				on_slot_array = child.name
				return true
	return false

func _process(delta) -> void:
	if visible:
		is_on_UI = _is_on_UI()
		if !is_on_UI && selection && has_node("selected_slot"):
			if get_node("selected_slot").object.is_placable:
				add_object_to_world.emit(get_node("selected_slot"))
		elif is_on_UI:
			remove_object_from_world.emit(on_slot_array)

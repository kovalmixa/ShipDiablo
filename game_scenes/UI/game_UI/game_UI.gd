extends CanvasLayer

var children
var is_on_UI = false

func _ready():
	children = get_children()
	UI.inventory_opened.connect(_on_inventory_opened)
	UI.inventory_closed.connect(_on_inventory_closed)
	for child in get_children():
		if child is slot_array:
			child.is_visible = true

func _on_inventory_opened() -> void:
	for child in get_children():
		if child is slot_array:
			child.is_visible = false
	hide()
	
func _on_inventory_closed() -> void:
	for child in get_children():
		child.is_visible = true
	is_on_UI = false
	show()

func _is_on_UI() -> bool:
	for child in children:
		if child is slot_array:
			if child.is_on_array_grid:
				return true
	return false
	
func _process(delta):
	if visible:
		var ability_list = get_node("ability_list")
		var ability_mouse = get_node("ability_mouse")
		is_on_UI = _is_on_UI()

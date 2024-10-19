extends CanvasLayer

func _ready():
	Inventory.inventory_opened.connect(_on_inventory_opened)
	Inventory.inventory_closed.connect(_on_inventory_closed)
	for child in get_children():
		child.is_visible = true

func _on_inventory_opened():
	for child in get_children():
		child.is_visible = false
	hide()
	
func _on_inventory_closed():
	for child in get_children():
		child.is_visible = true
	show()

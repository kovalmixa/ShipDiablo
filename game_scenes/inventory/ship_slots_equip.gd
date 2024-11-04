extends Inventory_type

signal object_changed(_j, _obj, _slot_type)

var main
var player

@export var type = ""

func _ready() -> void:
	super()
	main = get_tree().root.get_node("Main")
	player = main.get_node("Player")
	object_changed.connect(player._on_object_changed)
	
func draw_objects() -> void:
	super()
	for i in range (ARRAY_HEIGHT):
		for j in range (ARRAY_WIDTH):
			var slot = get_node("slot_%d_%d" % [i, j])
			slot.is_equipment_slot = true
		
func mouse_click(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if is_on_array_grid && event.pressed:
			var i = int((event.position.y - array_top_corner.y) / slot_size.y)
			var j = int((event.position.x - array_top_corner.x) / slot_size.x)
			if event.button_index == MOUSE_BUTTON_LEFT:
				var slot = "slot_%d_%d" % [i, j]
				var selection = Inventory.selection
				if selection:
					var selected_slot = Inventory.get_node("selected_slot")
					if selected_slot.object.type != type:
						return
					if selected_slot.object.size_type != get_node(slot).slot_object_size:
						return
					if get_node(slot).object.id == "" || get_node(slot).object.id != selected_slot.object.id:
						var object = selected_slot.object
						add_object_to_slot(i, j, object)
						if object.id == selected_slot.object.id:
							if selected_slot.quantity == 1:
								Inventory.selection = false
								Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
							selected_slot.add_object(object, -1)
				else:
					if get_node(slot).object.id != "":
						Inventory.selection = true
						select_inventory_slot(i, j, 1)
	
func add_object_to_slot(_i, _j, _object, _quantity = 1):
	var object
	if OBJECT == "HullObject":
		object = HullObject.new()
	elif OBJECT == "WeaponObject":
		object = WeaponObject.new()
	object.parse_id(_object.id)
	var selection = Inventory.selection
	var slot = "slot_%d_%d" % [_i, _j]
	if (get_node(slot).object.id == object.id)  || get_node(slot).object.id  == "":
		get_node(slot).add_object(object, _quantity)
		if get_node(slot).object.id == "":
			object = null
		object_changed.emit(_j, object, type)
	elif selection && get_node(slot).object.id  != object.id:
		var selected_slot = Inventory.get_node("selected_slot")
		if selected_slot.quantity == 1:
			var temp_obj = selected_slot.object.clone()
			selected_slot.add_object(get_node(slot).object)
			get_node(slot).add_object(temp_obj)
			object_changed.emit(_j, temp_obj, type)
	else:
		return
		
func _process(delta: float) -> void:
	super(delta)

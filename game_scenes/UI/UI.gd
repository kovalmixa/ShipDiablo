extends CanvasLayer

signal inventory_opened()
signal inventory_closed()

var children
var is_on_UI = false
@onready var Inventory = get_node("Inventory")
@onready var GameUI = get_node("Game_UI")

func _ready() -> void:
	children = get_children()

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed && event.keycode == KEY_I:
		if !Inventory.visible:
			inventory_opened.emit()
		else:
			inventory_closed.emit()
	if Inventory.visible && event is InputEventKey && event.pressed && event.keycode == KEY_ESCAPE:
		inventory_closed.emit()

func _is_on_UI() -> bool:
	for child in children:
		if child.is_on_UI:
			return true
	return false

func _process(delta) -> void:
	is_on_UI = _is_on_UI()

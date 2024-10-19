extends Sprite2D

var shader

func _ready():
	shader = load("res://base.gdshader")
	material = null

func enable_shader():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	material = shader_material
	
func disable_shader():
	material = null

extends Sprite2D

const shader = preload("res://game_scenes/object/base.gdshader")

func _ready():
	material = null

func enable_shader():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	material = shader_material
	
func disable_shader():
	material = null

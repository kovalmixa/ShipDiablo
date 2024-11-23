extends RigidBody2D

var target_position: Vector2
var speed: int
var life_time: int
var texture: String

func _ready() -> void:
	$Sprite2D.texture = ResourceLoader.load(texture)
	$CollisionShape2D.shape.radius = $Sprite2D.texture.get_width() / 2
	$Timer.wait_time = life_time
	$Timer.one_shot = true
	$Timer.start()
	var velocity = Vector2(speed, 0).rotated(rotation)
	linear_velocity = velocity

func _on_timer_timeout() -> void:
	queue_free()

func _process(delta: float) -> void:
	if position.distance_to(target_position) < 10:
		queue_free()

extends RigidBody2D

var target_position: Vector2
var object

func init_projectile(_textrue: String, _life_time: float, _speed: int) -> void:
	object = projectileObject.new(_textrue, _life_time, _speed)

func _ready() -> void:
	$Sprite2D.texture = ResourceLoader.load(object.texture)
	$CollisionShape2D.shape.radius = $Sprite2D.texture.get_width() / 2
	$Timer.wait_time = object.life_time
	$Timer.one_shot = true
	$Timer.start()
	var velocity = Vector2(object.speed, 0).rotated(rotation)
	linear_velocity = velocity

func _on_timer_timeout() -> void:
	queue_free()

func _process(delta: float) -> void:
	if position.distance_to(target_position) < 10:
		queue_free()

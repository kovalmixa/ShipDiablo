extends CharacterBody2D

class_name Ship

@export var max_speed = 300
@export var speed = 0.0
@export var speed_level = 0
@export var acceleration = 50.0
@export var rotation_speed = 1.025
@export var rotation_direction = 0

func movement(delta):
	var target_speed = speed_level * -max_speed / 3
	if speed < target_speed:
		speed = min(speed + acceleration * delta, target_speed)
	elif speed > target_speed:
		speed = max(speed - acceleration * delta, target_speed)
	rotation += rotation_direction * rotation_speed * delta
	velocity =  transform.y * speed
	move_and_slide()

func _physics_process(delta):
	movement(delta)

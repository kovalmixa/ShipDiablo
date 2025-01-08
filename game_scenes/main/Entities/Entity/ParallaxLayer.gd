extends ParallaxLayer

func _process(delta):
	if self.motion_offset.x == 1024:
		self.motion_offset = Vector2(0,0)
	self.motion_offset += Vector2(1,1)

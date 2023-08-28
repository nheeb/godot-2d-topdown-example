extends AnimatedSprite2D

func _on_range_area_entered(area):
	queue_free()

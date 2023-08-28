extends Area2D

func is_colliding():
	return self.get_overlapping_areas().size() > 0

func get_push_vector():
	return get_overlapping_areas()[0].global_position.direction_to(global_position)


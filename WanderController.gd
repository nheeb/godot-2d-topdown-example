extends Node2D

export var limit := 32

onready var start_position := global_position
onready var target_position := global_position

onready var timer := $Timer

func _on_Timer_timeout() -> void:
	update_target_position()

func update_target_position():
	var target_vector = Vector2(rand_range(-limit, limit), rand_range(-limit, limit))
	target_position = start_position + target_vector

func get_time_left():
	return timer.time_left

func start_timer(duration):
	timer.start(duration)

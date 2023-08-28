extends CharacterBody2D

const DeathEffect = preload("res://Effects/DeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

var state := IDLE

@onready var stats = $Stats

@export var knockback_speed = 120
@export var knockback_friction = 200
@export var fly_speed = 40
@export var acceleration = 300
@export var friction = 100

var _velocity := Vector2.ZERO
var knockback := Vector2.ZERO

@onready var player_detection := $PlayerDetection
@onready var sprite := $AnimatedSprite2D
@onready var hurtbox := $Hurtbox
@onready var soft_collision := $SoftCollision
@onready var wander_controller := $WanderController

# Jeden Frame
func _physics_process(delta: float) -> void:
	process_knockback(delta)
	process_statemachine(delta)
	process_soft_collision(delta)

func process_knockback(delta: float):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_friction * delta)
	set_velocity(knockback)
	move_and_slide()
	knockback = velocity

func process_statemachine(delta: float):
	match state:
		IDLE:
			_velocity = _velocity.move_toward(Vector2.ZERO, friction * delta)
			seek_player()
		
			if wander_controller.get_time_left() == 0:
				state = [IDLE, WANDER][randi() % 2]
				wander_controller.start_timer(randf_range(2, 3))
		WANDER:
			seek_player()
		
			if wander_controller.get_time_left() == 0:
				state = [IDLE, WANDER][randi() % 2]
				wander_controller.start_timer(randf_range(2, 3))
			
			var direction = (wander_controller.target_position - global_position).normalized()
			_velocity = _velocity.move_toward(direction * fly_speed, acceleration * delta)
			
			if global_position.distance_to(wander_controller.target_position) <= fly_speed * delta:
				state = IDLE
		
		CHASE:
			var player = player_detection.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				_velocity = _velocity.move_toward(direction * fly_speed, acceleration * delta)
			else:
				state = IDLE

func seek_player():
	if player_detection.can_see_player():
		state = CHASE

func process_soft_collision(delta: float):
	if soft_collision.is_colliding():
		_velocity += soft_collision.get_push_vector() * 5
	if _velocity.x < 0 :
		sprite.flip_h = true
	elif _velocity.x > 0 :
		sprite.flip_h = false
	set_velocity(_velocity)
	move_and_slide()
	_velocity = velocity

func _on_hurtbox_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	knockback = global_position - area.origin_position
	print(knockback)
	knockback = knockback.normalized() + area.hit_direction
	knockback = knockback.normalized() * knockback_speed
	print(knockback)
	hurtbox.create_hit_effect()

func _on_Stats_no_health() -> void:
	die()

func die():
	queue_free()
	var deathEffect = DeathEffect.instantiate()
	get_parent().add_child(deathEffect)
	deathEffect.global_position = global_position


func _on_hitbox_area_entered(area):
	area.emit_signal("area_entered", $Hitbox)

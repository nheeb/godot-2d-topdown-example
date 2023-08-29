extends CharacterBody2D

var _velocity := Vector2.ZERO
@export var walk_speed := 100
@export var roll_speed := 155
@export var acceleration := 500
@export var friction := 500
@export var invinc_time := 1.5

enum {
	WALK,
	ROLL,
	ATTACK
}

var state := WALK

var roll_vector := Vector2.LEFT

@onready var animation_player := $AnimationPlayer
@onready var animation_tree := $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var hitbox_pivot := $HitboxPivot
@onready var sword_hitbox := $HitboxPivot/SwordHitbox
@onready var hurtbox := $Hurtbox

var stats = PlayerStats

func _ready() -> void:
	stats.connect("no_health", Callable(self, "queue_free"))
	animation_tree.active = true

func _physics_process(delta: float) -> void:
	match state:
		WALK:
			walk_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
	sword_hitbox.origin_position = hitbox_pivot.global_position
	sword_hitbox.hit_direction = roll_vector

func attack_state() -> void:
	_velocity = Vector2.ZERO
	animation_state.travel("Attack")

func roll_state() -> void:
	_velocity = roll_vector * roll_speed
	animation_state.travel("Roll")
	move()

func walk_state(delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Walk/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		roll_vector = input_vector
		animation_state.travel("Walk")
		_velocity = _velocity.move_toward(input_vector * walk_speed, acceleration * delta)
	else:
		animation_state.travel("Idle")
		_velocity = _velocity.move_toward(Vector2.ZERO, friction * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func attack_move_finished():
	state = WALK

func roll_move_finished():
	state = WALK

func move():
	set_velocity(_velocity)
	move_and_slide()
	_velocity = velocity


func _on_Hurtbox_area_entered(_area: Area2D) -> void:
	stats.health -= 1
	hurtbox.start_invinc(invinc_time)
	hurtbox.create_hit_effect()


func _on_sword_hitbox_area_entered(area: Area2D):
	area.emit_signal("area_entered", sword_hitbox)

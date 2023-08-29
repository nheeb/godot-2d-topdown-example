extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

@export var show_hit := true
@export var hit_offset := Vector2.ZERO

var invincible := false: set = set_invincible
@onready var timer := $Timer

signal invinc_start
signal invinc_end

func _ready():
	set_invincible(false)

func set_invincible(value):
	invincible = value
	if value:
		emit_signal("invinc_start")
	else:
		emit_signal("invinc_end")

func start_invinc(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	if show_hit:
		var hitEffect = HitEffect.instantiate()
		var main = get_tree().current_scene
		main.add_child(hitEffect)
		hitEffect.global_position = global_position + hit_offset

func _on_Timer_timeout() -> void:
	#setter only activate with self
	self.invincible = false

func _on_Hurtbox_invinc_start() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

func _on_Hurtbox_invinc_end() -> void:
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)

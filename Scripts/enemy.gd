extends RigidBody2D

@onready var player = null
@export var movement_speed: float = 240.0
@export var xp = preload("res://Scripts/xp.tscn")
var health = 100
var is_stunned: bool = false

func _ready() -> void:
	player = get_node("/root/World/Player")
	gravity_scale = 0 
	lock_rotation = true 

func _physics_process(_delta: float) -> void:
	if player == null or player.current_player_status == 0:
		return

	# If stunned, stop here. 
	# We do NOT check for death here anymore.
	if is_stunned:
		return

	var direction = Vector2.ZERO
	if global_position.distance_to(player.global_position) > 100.0:
		direction = (player.global_position - global_position).normalized()
	
	linear_velocity = direction * movement_speed

func push_enemy_back():
	var knockback_direction = -(player.global_position - global_position).normalized()
	var knockback_strength = 800.0 
	
	apply_central_impulse(knockback_direction * knockback_strength)
	
	is_stunned = true
	get_tree().create_timer(0.2).timeout.connect(func(): is_stunned = false)

func take_damage(damage: int):
	health -= damage
	
	# FIX: Check for death IMMEDIATELY after taking damage
	if health <= 0:
		die()
	else:
		# Only apply knockback if the enemy survives the hit
		push_enemy_back()

func die():
	player.increase_xp(20)
	# queue_free() happens at the end of the current frame, 
	# so this is as instant as Godot allows.
	queue_free()

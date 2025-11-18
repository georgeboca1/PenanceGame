extends CharacterBody2D

## Drag your 'player_stats.tres' file here
@export var stats: PlayerStats 

@onready var augment_screen = $AugumentSelection # Or find it in your scene tree


# BASIC ATTACK
@export var attack_distance: float = 40.0
@export var attack_speed: float = 400.0
# Basic time between attacks
@export var attack_cooldown: float = 0.5
@export var attack_duration: float = 0.1

# PLAYER STATUS
enum P_STATE {
	DEAD,
	ALIVE
}
enum PLAYER_ACTIONS {
	IDLE,
	MOVING,
	ATTACKING,
	DASHING,
	DYING
}

@export var current_player_status: P_STATE = P_STATE.ALIVE
@export var current_player_action: PLAYER_ACTIONS = PLAYER_ACTIONS.IDLE

# FIRST ABILITY
@export var dash_force: float = 300
@export var dash_speed: float = 3500
@export var dash_cooldown: float = 1.7
@export var dash_duration: float = 0.3

# SECOND ABILITY
@export var second_ability_cooldown: float = 3

# THIRD ABILITY
@export var third_ability_cooldown: float = 3

# PLAYER STATS
# Current player health
@export var health = 100
# How much the health of the player can increase (from power-ups)
@export var max_health = 100
# How much damage a basic attack does
@export var damage: float = 10
# Gets multiplied with final damage
@export var damage_multiplier: float = 1.0
@export var dodge_chance: float = 0
@export var move_speed: float = 300
#This multiplies with the final speed of the player
@export var move_speed_multiplier: float = 1.0
#This is the xp of the player, level increases when
#xp gets to a certain number, then resets to 0
@export var xp_level: float = 0
@export var level: int = 1
@export var level_treshhold: int = 0

@export var knockback_vector: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 400.0 # How hard you get hit
@export var knockback_decay: float = 30.0 # How fast the sliding stops (Friction)

# MISC
var can_attack: bool = true
var can_take_damage: bool = true
var is_attacking: bool = false
var attack_timer: float = 0.0
var attack_direction: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
var is_dashing: float = false
var is_dash_ready: float = true
var enemy_near_player: bool = false
var enemy_position: Vector2 = Vector2.ZERO


#We use this multiplier to calculate the threshhold needed for the next level
# (e.g.) xp_needed = (level * level_threshold_multipler * 100)
@export var level_threshold_multiplier: float = 1.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var ui_health = $PlayerCamera/UI/Health
@onready var ui_level_bar = $PlayerCamera/UI/LevelBar

func _ready() -> void:
	disable_attack_hitbox()
	level_treshhold = calculate_level_threshold()
	
func _process(_delta: float) -> void:
	if not is_attacking:
		attack_hitbox.position = calculate_collider_position()
		attack_hitbox.rotation = calculate_collider_rotation()
	
	ui_health.value = health
	ui_level_bar.value = xp_level
	ui_level_bar.max_value = level_treshhold

func _physics_process(delta: float) -> void:
	match current_player_status:
		P_STATE.ALIVE:
			handle_alive_motion(delta)
			handle_player_animations()
			check_health_status()
		P_STATE.DEAD:
			death_screen()

func calculate_level_threshold():
	return level * level_threshold_multiplier * 100

func level_up():
	xp_level = 0
	level += 1
	print("LEVEL UP! Reached level %s" % level)
	
	# 1. Get choices from the manager
	var choices = AugumentManager.get_augment_choices()
	
	# 2. Tell the UI to show them
	augment_screen.show_selection(choices)

func death_screen():
	#var timer = Timer.new()
	var tween = create_tween()
	
	#timer.process_mode = Node.PROCESS_MODE_ALWAYS
	#add_child(timer)
	#
	#timer.start(0.75)
	#await timer.timeout
	#get_tree().paused = true
	
	tween.tween_property($PlayerCamera/UI/ColorRect, "color", Color(1,1,1,1), 0.5)
	
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")

func handle_player_animations():
	if velocity.x <= 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
	match current_player_action:
		PLAYER_ACTIONS.IDLE:
			sprite.speed_scale = 1.0
			sprite.play("IDLE")
		PLAYER_ACTIONS.DYING:
			sprite.speed_scale = 1.0
			sprite.play("DYING")
		PLAYER_ACTIONS.MOVING:
			sprite.speed_scale = 1.0
			sprite.play("RUNNING")
		PLAYER_ACTIONS.ATTACKING:
			var mouse_pos = get_global_mouse_position()
			attack_direction = (mouse_pos - global_position).normalized()
			if attack_direction.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			sprite.speed_scale = 5.0
			sprite.play("ATTACK")
		_:
			sprite.speed_scale = 1.0
			sprite.play("IDLE")

func check_health_status():
	if enemy_near_player and $DamageTimer.is_stopped() and can_take_damage:
		$DamageTimer.start()
		var direction = (global_position - enemy_position).normalized()
		knockback_vector = direction * knockback_strength
		health -= 10
	
	if health <= 0:
		current_player_status = P_STATE.DEAD

func handle_alive_motion(delta):
	var horizontal_direction := Input.get_axis("left", "right")
	var vertical_direction := Input.get_axis("up", "down")
	if horizontal_direction:
		velocity.x = horizontal_direction
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * move_speed_multiplier)
		
	if vertical_direction:
		velocity.y = vertical_direction
	else:
		velocity.y = move_toward(velocity.y, 0, move_speed * move_speed_multiplier)
		
	velocity = velocity.normalized() * move_speed * move_speed_multiplier
	
	if Input.is_action_just_pressed("first_ability") and is_dash_ready:
		start_dash()
	
	if Input.is_action_just_pressed("attack") and can_attack:
		start_attack()
	
	
	if is_dashing:
		dash_timer -= delta
		dash_ability(delta,	dash_timer)
		if dash_timer <= 0.0:
			end_dash()
	
	# inside _physics_process
	if is_attacking:
		current_player_action = PLAYER_ACTIONS.ATTACKING
		attack_timer -= delta
		if attack_timer <= 0.0:
			end_attack()
	
	if velocity != Vector2.ZERO and not is_attacking:
		current_player_action = PLAYER_ACTIONS.MOVING
	elif not is_attacking:
		current_player_action = PLAYER_ACTIONS.IDLE
	
	velocity += knockback_vector
	
	move_and_slide()
	
	if knockback_vector != Vector2.ZERO:
		knockback_vector = knockback_vector.move_toward(Vector2.ZERO, knockback_decay)

func end_dash():
	is_dashing = false
	velocity = Vector2.ZERO
	can_take_damage = true
	$Collider.disabled = false

func start_dash():
	$Collider.disabled = true
	is_dashing = true
	is_dash_ready = false
	can_take_damage = false
	dash_timer = dash_duration
	
	await get_tree().create_timer(dash_cooldown).timeout
	is_dash_ready = true
	

func dash_ability(delta, dash_t):
	var mouse_pos = get_global_mouse_position()
	attack_direction = (mouse_pos - global_position).normalized()
	var t = clamp(1.0 - (dash_t / dash_duration), 0.0, 1.0)
	var speed_factor = 1.0 - ease_out(t)                # 1 -> 0 (starts fast, ends slow)
	var distance = attack_direction.normalized() * dash_speed * speed_factor * delta
	move_and_collide(distance)
	velocity = Vector2.ZERO


func disable_attack_hitbox():
	attack_hitbox.monitoring = false
	attack_hitbox.visible = false
	$AttackHitbox/AnimatedSprite2D.stop()
	
func enable_attack_hitbox():
	attack_hitbox.monitoring = true
	attack_hitbox.visible = true
	$AttackHitbox/AnimatedSprite2D.animation = "attack_down"
	$AttackHitbox/AnimatedSprite2D.play()

func calculate_collider_position():
	var mouse_pos = get_global_mouse_position()
	var angle = (mouse_pos - position).angle()
	var distance = 50
	return Vector2(distance * cos(angle), distance * sin(angle))

func calculate_collider_rotation():
	var mouse_pos = get_global_mouse_position()
	var angle = (mouse_pos - position).angle()
	return angle + -PI/2
	
func start_attack():
	
	can_attack = false
	is_attacking = true
	attack_timer = attack_duration
	
	var mouse_pos = get_global_mouse_position()
	attack_direction = (mouse_pos - global_position).normalized()
	enable_attack_hitbox()
	# start cooldown async
	attack_cooldown_timer()

func end_attack():
	is_attacking = false
	attack_direction = Vector2.ZERO
	rotation = 0

func attack_cooldown_timer() -> void:
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	disable_attack_hitbox()

func _on_input_event() -> void:
	if is_attacking:
		velocity = Vector2.ZERO
		
func ease_in_out(x: float) -> float:
	# quadratic ease-in-out curve (0→1→0)
	if x < 0.5:
		return 2.0 * x * x
	else:
		return 1.0 - pow(-2.0 * x + 2.0, 2.0) / 2.0

func ease_out(t: float) -> float:
	return sin(t * PI * 0.5)

func increase_xp(xp: int):
	xp_level += xp
	$PlayerCamera/UI/LevelBar/Label.text = "Level: {level} - {xp_level}/{threshold}".format(
			{
				"level" : level,
 				"xp_level" : xp_level,
 				"threshold" : level_treshhold
			}
		)
	if xp_level > calculate_level_threshold():
		level_up()
		
func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.call("take_damage", 20)


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		enemy_position = body.position
		enemy_near_player = true

func _on_damage_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		enemy_near_player = false


func _on_damage_area_area_entered(area: Area2D) -> void:
		if area.is_in_group("XP"):
			xp_level += 10
			print(str(xp_level) + "/" + str(level_treshhold))
			area.queue_free()

func _on_dash_damage_area_body_entered(body: Node2D) -> void:
	if is_dashing and body.is_in_group("enemies"):
		body.take_damage(100)

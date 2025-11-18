# wave_manager.gd
# This script manages spawning enemies in waves around the player.
# It requires a child node named "SpawnTimer" to function.
class_name WaveManager
extends Node

## 🚀 Exports - Configure these in the Godot Inspector
# (Feature 1 & 8) An array of enemy scenes to spawn.
# Order matters: enemies at higher indices are considered "bigger" or "tougher".
@export var enemy_scenes: Array[PackedScene]

# (Feature 2) A reference to the player node.
@export var player_node: NodePath

# (Feature 4) The minimum distance from the player to spawn enemies.
# Set this to be just outside the player's view (e.g., screen diagonal).
@export var min_spawn_radius: float = 1000.0

# (Feature 4) The maximum distance from the player to spawn enemies.
@export var max_spawn_radius: float = 1500.0

# (Feature 6 & 7) The initial maximum number of enemies allowed at one time.
@export var initial_max_entities: int = 20

# A reference to the node where enemies will be added as children.
# If left empty, it will default to the WaveManager's parent (usually the main scene).
@export var enemy_container: NodePath

## ⚙️ Constants
# (Feature 5) The absolute world boundaries for spawning.
const WORLD_BOUNDARY_X: float = 20000.0
const WORLD_BOUNDARY_Y: float = 20000.0
# (Feature 8) How many seconds until the next "tier" of enemy starts spawning.
const TIME_PER_ENEMY_TIER: float = 30.0 # 30 seconds

## 📉 Internal Variables
var player: Node2D
var container_node: Node
var current_entities: int = 0
var max_entities: int = 0
var game_time: float = 0.0

# We need a reference to the timer node.
@onready var spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	# (Feature 6 & 7) Set the initial max entities.
	max_entities = initial_max_entities
	
	# (Feature 2) Get the player node from the exported path.
	if not player_node.is_empty():
		player = get_node_or_null(player_node)
	if not player:
		print("WaveManager: Player node not found! Disabling spawner.")
		set_process(false) # Stop processing if player is missing
		return

	# Get the container node.
	if not enemy_container.is_empty():
		container_node = get_node_or_null(enemy_container)
	if not container_node:
		# Default to parent if no container is set.
		container_node = get_parent() 
		print("WaveManager: Enemy container not set. Defaulting to parent node.")

	# (Feature 9) Connect the timer's timeout signal to our spawn function.
	# This is more performant than spawning in _process().
	if spawn_timer:
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	else:
		print("WaveManager: Child node 'SpawnTimer' not found! Spawning will not work.")


func _process(delta: float) -> void:
	# (Feature 8) Track total game time to scale difficulty.
	game_time += delta


# This function is called every time the SpawnTimer finishes.
func _on_spawn_timer_timeout() -> void:
	spawn_enemy()


func spawn_enemy() -> void:
	# (Feature 6) Don't spawn if we've hit the cap.
	if current_entities >= max_entities:
		print("Wave Manager: Max entities reached")
		return

	# (Feature 8) Select which enemy to spawn based on game time.
	var enemy_scene = _select_enemy_scene()
	if not enemy_scene:
		# This can happen if the enemy_scenes array is empty.
		return

	# (Feature 3 & 4) Calculate a random spawn position in a "ring" around the player.
	var random_angle: float = randf() * TAU # TAU = 2 * PI
	var random_radius: float = randf_range(min_spawn_radius, max_spawn_radius)
	
	# Start from player's position and offset by the random circle point.
	var spawn_position: Vector2 = player.global_position + Vector2.RIGHT.rotated(random_angle) * random_radius

	# (Feature 5) Check if the calculated position is outside the world bounds.
	if abs(spawn_position.x) > WORLD_BOUNDARY_X or abs(spawn_position.y) > WORLD_BOUNDARY_Y:
		# print_debug("Spawn location outside world bounds. Cancelling.")
		return # Cancel spawn

	# (Feature 1) We are clear to spawn!
	var enemy_instance: Node2D = enemy_scene.instantiate()
	enemy_instance.global_position = spawn_position
	
	# Add the enemy to the designated container node.
	container_node.add_child(enemy_instance)

	# (Feature 9 - Performance) Increment count and connect to the enemy's
	# 'tree_exited' signal. This is the most efficient way to track deaths/despawns.
	current_entities += 1
	enemy_instance.tree_exited.connect(_on_enemy_destroyed)


# This function is called automatically by the signal when an enemy is destroyed.
func _on_enemy_destroyed() -> void:
	# (Feature 9) Decrement the count.
	current_entities -= 1
	current_entities = max(0, current_entities) # Ensure it never goes below 0


# (Feature 8) Logic for picking an enemy based on game time.
func _select_enemy_scene() -> PackedScene:
	if enemy_scenes.is_empty():
		return null
	
	# Determine the "highest tier" of enemy unlocked so far.
	# Example: 
	# game_time = 0, max_index = 0
	# game_time = 35, max_index = 1
	# game_time = 70, max_index = 2
	var max_tier_index: int = int(game_time / TIME_PER_ENEMY_TIER)
	
	# Clamp the index to the size of our array.
	max_tier_index = clamp(max_tier_index, 0, enemy_scenes.size() - 1)
	
	# Spawn a random enemy from *any* unlocked tier (from 0 up to max_tier_index).
	# This keeps early-game enemies in the mix.
	var random_index = randi_range(0, max_tier_index)
	
	return enemy_scenes[random_index]


## 🏛️ Public API
# (Feature 7) Call this function from another script (e.g., a game manager)
# to increase the difficulty over time.
func set_max_entities(new_max: int) -> void:
	max_entities = new_max
	# print_debug("WaveManager: Max entities set to %s" % new_max)

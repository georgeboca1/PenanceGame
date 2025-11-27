# PlayerStats.gd
@tool
extends Resource
class_name PlayerStats

## Define all your player's stats here
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var speed: float = 100.0
@export var damage: float = 10.0
@export var attack_speed: float = 1.0 # (e.g., attacks per second)

# This is the magic function that applies the changes
func apply_augment(stat_name: StringName, type: Augment.ModType, value: float):
	# Check if the stat exists in this resource
	if not stat_name:
		print_debug("Error: Stat '%s' not found in PlayerStats!" % stat_name)
		return

	# Get the current value
	var current_value = get(stat_name)

	# Apply modification
	match type:
		Augment.ModType.ADDITIVE:
			set(stat_name, current_value + value)
		Augment.ModType.MULTIPLICATIVE:
			# A value of 15 (from a 15% boost) should be 1.15
			# We'll assume the 'value' passed in is a percentage (e.g., 15.0)
			set(stat_name, current_value * (1.0 + value / 100.0))
	
	print("Applied augment: %s %s %s. New value: %s" % [stat_name, type, value, get(stat_name)])

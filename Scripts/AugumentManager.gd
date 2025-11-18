# AugmentManager.gd
extends Node

## Drag all your .tres augment files here from the FileSystem dock
@export var augment_database: Array[Augment]

# Define the chances for each rarity (must add up to 1.0)
const COMMON_CHANCE = 0.60
const RARE_CHANCE = 0.30
const LEGENDARY_CHANCE = 0.10

var rng = RandomNumberGenerator.new()

# This is the main function the player will call
func get_augment_choices() -> Array:
	# 1. Roll for the rarity of this level-up
	var chosen_rarity = _roll_for_rarity()
	
	# 2. Get all augments of that rarity
	var available_augments = []
	for aug in augment_database:
		if aug.rarity == chosen_rarity:
			available_augments.append(aug)

	# 3. Pick 3 unique augments
	if available_augments.size() == 0:
		print_debug("No augments found for rarity: %s" % chosen_rarity)
		return []
		
	available_augments.shuffle()
	
	var choices = []
	for i in range(min(3, available_augments.size())):
		choices.append(available_augments[i])
		
	return choices

# Private helper function to roll for rarity
func _roll_for_rarity() -> Augment.Rarity:
	var roll = rng.randf() # Random float between 0.0 and 1.0
	
	if roll < LEGENDARY_CHANCE:
		return Augment.Rarity.LEGENDARY
	elif roll < LEGENDARY_CHANCE + RARE_CHANCE:
		return Augment.Rarity.RARE
	else:
		return Augment.Rarity.COMMON

# Augment.gd
extends Resource
class_name Augment

## Define the possible rarities and modification types
enum Rarity { COMMON, RARE, LEGENDARY }
enum ModType { ADDITIVE, MULTIPLICATIVE }

@export var augment_name: String
@export_multiline var description: String
@export var rarity: Rarity = Rarity.COMMON

## The stat we want to change (e.g., "damage", "speed")
@export var stat_to_modify: StringName 

## How we modify it (add or multiply)
@export var mod_type: ModType = ModType.ADDITIVE

## The random range for the modifier
@export var min_value: float = 1.0
@export var max_value: float = 2.0

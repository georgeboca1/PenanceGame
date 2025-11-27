# AugmentSelection.gd
extends CanvasLayer

## Signal to tell the player what was chosen
signal augment_selected(augment_resource, applied_value)

@onready var ui_root = $UI_Root
@onready var card1 = $UI_Root/HBoxContainer/Card1
@onready var card2 = $UI_Root/HBoxContainer/Card2
@onready var card3 = $UI_Root/HBoxContainer/Card3

# Store the augments and their ROLLED values
var current_choices: Array = []
var rolled_values: Array = []

func _ready():
	# Connect the button signals
	card1.pressed.connect(_on_card_pressed.bind(0))
	card2.pressed.connect(_on_card_pressed.bind(1))
	card3.pressed.connect(_on_card_pressed.bind(2))
	
	# Start hidden
	ui_root.visible = false

# This is the main function called by the Player
func show_selection(augment_choices: Array):
	if augment_choices.size() == 0:
		print_debug("No augment choices to show.")
		return

	current_choices = augment_choices
	rolled_values.clear()
	
	# We need 3 cards, even if fewer augments were found
	var cards = [card1, card2, card3]
	
	for i in range(cards.size()):
		if i < current_choices.size():
			var aug: Augment = current_choices[i]
			
			# 1. Roll the random value HERE
			var rolled_val = randf_range(aug.min_value, aug.max_value)
			rolled_values.append(rolled_val)
			
			# 2. Format the button text
			var mod_char = "%" if aug.mod_type == Augment.ModType.MULTIPLICATIVE else ""
			var text = "%s\n%s\n%s: +%.1f%s" % [aug.augment_name, aug.description, aug.stat_to_modify, rolled_val, mod_char]
			cards[i].text = text
			cards[i].visible = true
		else:
			cards[i].visible = false # Hide extra buttons

	# 3. Pause the game and show the UI
	get_tree().paused = true
	ui_root.visible = true

# Called when any card is pressed
func _on_card_pressed(card_index: int):
	if card_index >= current_choices.size():
		return # Should not happen

	var chosen_augment: Augment = current_choices[card_index]
	var chosen_value: float = rolled_values[card_index]
	
	# 1. Emit the signal with the chosen data
	augment_selected.emit(chosen_augment, chosen_value)
	#$...stats.apply_augument()
	
	# 2. Hide UI and unpause
	ui_root.visible = false
	get_tree().paused = false

extends Control

var death_messages = [
	"The debt remains unpaid.",
	"Your soul is still too heavy.",
	"Atonement is expensive. You cannot afford it yet.",
	"You have not bled enough to be forgiven.",
	"The scales have tipped against you.",
	"Your tithe was rejected."
]

@onready var message = $StartMessage

func _ready() -> void:
	get_tree().paused = false
	$AudioStreamPlayer.play()
	var tween = create_tween()
	var selected_text = death_messages[randi() % 6]
	message.text = selected_text
	
	tween.tween_property($ColorRect, "color", Color(0,0,0,1), 1)

	await tween.finished
	tween.stop()
	tween.play()
	
	message.visible = true
	tween.tween_property(message, "visible_characters", len(selected_text), 3)
	tween.tween_interval(2)
	
	await tween.finished
	tween.stop()
	tween.play() # As dumb as this looks, it needs to be done this way
	print("test")
	message.visible_characters = 0
	message.text = "The cycle continues"
	tween.tween_property(message, "visible_characters", len(selected_text), 3)
	
	await tween.finished
	message.visible = false
	$Retry.visible = true
	tween.stop()
	tween.play()


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level.tscn")

extends Node2D

@onready var _texture = $CanvasLayer/Control/BackgroundImage
@onready var fadescreen = $CanvasLayer/Control/FadeScreen
var rng = RandomNumberGenerator.new()

var backgrounds: Array = [
	"./Sprites/Background/background2.jpeg",
]

func _ready() -> void:
	fadescreen.visible = true
	var img = Image.load_from_file(backgrounds[0])
	_texture.texture = ImageTexture.create_from_image(img)
	
	var fade_in_tween = create_tween()
	fade_in_tween.set_trans(Tween.TRANS_SINE)
	fade_in_tween.tween_property($CanvasLayer/Control/FadeScreen/TextureRect, "modulate:a",1, 1.5)
	fade_in_tween.tween_property($CanvasLayer/Control/FadeScreen/TextureRect, "modulate:a",0, 1.5)
	
	await fade_in_tween.finished
	fade_in_tween.stop()
	
	fade_in_tween.tween_property(fadescreen, "color", Color(0, 0, 0, 0.4), 3)
	start_random_pulse()
	
func start_random_pulse():
	# PULSE VARIABLES
	var delay_time = rng.randf_range(0.1, 0.3)
	var target_alpha = rng.randf_range(0.4, 0.7)
	var pulse_in_duration = rng.randf_range(1, 1.5)
	var pulse_out_duration = rng.randf_range(1, 1.5)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE) # Makes the pulse feel more natural
	tween.tween_interval(delay_time)

	tween.tween_property(fadescreen, "color", Color(0, 0, 0, target_alpha), pulse_in_duration)
	tween.tween_property(fadescreen, "color", Color(0, 0, 0, 0.5), pulse_out_duration)
	tween.tween_callback(start_random_pulse)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

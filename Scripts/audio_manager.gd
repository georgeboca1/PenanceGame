extends Node2D

var background_music_list: Array = []
var current_song = 0
var check_limiter = 10
var current_limiter = 0
var audio_stream: AudioStreamMP3
@onready var player: AudioStreamPlayer = $BackgroundMusic

@export var base_dir: String = "res://Audio/BgMusic/"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background_music_list = scan_mp3()
	if len(background_music_list) == 0:
		return
	background_music_list.shuffle()
	audio_stream = AudioStreamMP3.new()
	player.stream = audio_stream
	
	load_mp3(background_music_list[current_song])
	player.play()

func scan_mp3():
	var files = DirAccess.get_files_at(base_dir);
	var scanned_files = []
	for i in files:
		if i.ends_with(".mp3"):
			scanned_files.append(i)
	return scanned_files
	
func load_mp3(file):
	var _file = FileAccess.open(base_dir + file,FileAccess.READ)
	if _file == null:
		print("error loading mp3")
		return
	audio_stream.data = _file.get_buffer(_file.get_length())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if len(background_music_list) == 0:
		return

	current_limiter += 1
	if check_limiter == current_limiter:
		current_limiter = 0
		if not player.playing:
			current_song += 1
			load_mp3(background_music_list[current_song])
			player.play()

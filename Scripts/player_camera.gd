extends Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
@export var stiffness := 10.0
@export var damping := 0.8
var velocity := Vector2.ZERO
@onready var player := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta):
	var target = player.global_position
	var diff = target - global_position
	var force = diff * stiffness
	velocity += force * delta
	velocity *= damping
	global_position += velocity * delta

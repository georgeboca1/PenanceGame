extends StaticBody2D

var textures = [
	preload("res://Sprites/Environment/tree.png"),
	preload("res://Sprites/Environment/tree2.png"),
	preload("res://Sprites/Environment/tree3.png")
]
@export var collider_info = [
	[10,160,2.9,0.65],
	[0,160,2.9,0.65],
	[10,160,2.9,0.65]
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var sprite_id = randi() % textures.size()
	$Sprite2D.texture = textures[sprite_id]
	$Collider.position = Vector2(collider_info[sprite_id][0],collider_info[sprite_id][1])
	$Collider.scale = Vector2(collider_info[sprite_id][2],collider_info[sprite_id][3])

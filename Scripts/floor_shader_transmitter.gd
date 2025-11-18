@tool
extends Sprite2D

# This creates a "Tile Size" field in the Inspector for this script.
# Set your tile size here (e.g., 128, 128)
@export var tile_size: Vector2 = Vector2(64.0, 64.0)

# _ready() runs once when the game starts
func _ready():
	# Make sure the material is unique for this node
	material = material.duplicate()
	
	# Set the tile size in the shader one time
	if material:
		material.set_shader_parameter("tile_size_in_world_units", tile_size)

# _process() continues to run every frame
func _process(_delta):
	# This part is the same as before
	if material:
		material.set_shader_parameter("world_matrix", global_transform)

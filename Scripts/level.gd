extends Node2D



@onready var number_of_obstacles = 950
@export var obstacle = preload("res://Scenes/obstacle.tscn")
@export var map_min = Vector2(-20000,-20000)
@export var map_max = Vector2(20000, 20000)

@export var textures: Array[Texture2D]
@export var scatter_count := 80000
@export var map_size := Vector2(-20000, 20000)

func _ready():
	var rng = RandomNumberGenerator.new()
	
	for texture in textures:
		var mmi = MultiMeshInstance2D.new()
		var mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_2D
		mm.instance_count = scatter_count

		# QuadMesh with texture assigned directly
		var mesh = QuadMesh.new()
		mesh.size = texture.get_size()
		#mesh.texture = texture
		mm.mesh = mesh

		for i in range(scatter_count):
			var pos = Vector2(rng.randf_range(map_size.x, map_size.y), rng.randf_range(map_size.x, map_size.y))
			var _scale = rng.randf_range(-4, -6)
			mm.set_instance_transform_2d(i, Transform2D(0, pos).scaled(Vector2(_scale, _scale)))

		mmi.multimesh = mm
		mmi.texture = texture
		add_child(mmi)
		#
	#for i in range(number_of_obstacles):
		#var obj = obstacle.instantiate()
		#obj.position = Vector2(rng.randf_range(map_min.x, map_max.x), rng.randf_range(map_min.y, map_max.y))
		#add_child(obj)

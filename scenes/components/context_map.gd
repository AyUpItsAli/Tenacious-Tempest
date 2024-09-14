class_name ContextMap extends Node

@export var vector_count: int = 12
@export var ray_length: float = 64
@export_flags_2d_physics var collision_mask: int
@export var collide_with_areas: bool

var directions: Array[Vector2]
var rays: Array[RayCast2D]
var interest_map: Array[float]

func _ready():
	for i in range(vector_count):
		var angle = i * 2 * (PI / vector_count)
		var direction = Vector2.UP.rotated(angle)
		directions.append(direction)
		var ray = RayCast2D.new()
		ray.target_position = direction * ray_length
		ray.collision_mask = collision_mask
		ray.collide_with_areas = collide_with_areas
		add_child(ray)
		rays.append(ray)
	interest_map.resize(vector_count)

func set_interests(target_vectors: Array[Vector2]):
	for i in range(vector_count):
		var interest = 0
		for vector in target_vectors:
			interest += directions[i].dot(vector)
		interest_map[i] = max(0, interest)

func get_desired_vector() -> Vector2:
	var desired_vector = Vector2.ZERO
	for i in range(vector_count):
		var interest = interest_map[i]
		if rays[i].is_colliding():
			interest = 0
		desired_vector += directions[i] * interest
	return desired_vector.normalized()

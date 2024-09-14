class_name PlayerCamera extends Camera2D

@export var target: Node2D
@export var smooth_weight: float = 1

func _physics_process(_delta: float) -> void:
	if not target or target.is_queued_for_deletion(): return
	position = position.lerp(target.position, smooth_weight)

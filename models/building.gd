class_name Building extends Resource

@export var scene: PackedScene
@export var name: String
@export_range(1, 1, 1, "or_greater") var cost: int = 5

func create_object() -> BuildingObject:
	var object: BuildingObject = scene.instantiate()
	object.building = self
	return object

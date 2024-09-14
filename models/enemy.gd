class_name Enemy extends Resource

@export var scene: PackedScene
@export_range(0, 1, 1, "or_greater", "suffix:money") var reward: int = 10

func create_actor() -> EnemyActor:
	var actor: EnemyActor = scene.instantiate()
	actor.enemy = self
	return actor

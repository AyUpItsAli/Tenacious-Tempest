class_name Health extends Node

@export var max_health: int = 10

@onready var health: float = max_health

signal depleted

func damage(amount: float) -> void:
	health = max(health - amount, 0)
	if is_depleted():
		depleted.emit()

func is_depleted() -> bool:
	return health <= 0

func recover_all():
	recover(max_health)

func recover(amount: float):
	health = min(health + amount, max_health)

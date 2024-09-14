class_name EnemySpawn extends Resource

@export var enemy: Enemy = preload("res://data/enemies/tornado.tres")
@export_range(1, 1, 1, "or_greater") var count: int = 1

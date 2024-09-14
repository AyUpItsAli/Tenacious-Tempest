class_name Storm extends Resource

@export_range(1, 1, 1, "or_greater") var number: int = 1
@export_range(1, 1, 1, "or_greater", "suffix:s") var calm_duration: float = 20
@export_range(1, 1, 1, "or_greater", "suffix:s") var duration: float = 30
@export_range(0, 1, 1, "or_greater", "suffix:money") var reward: int = 100
@export_group("Spawns")
@export var left_spawns: Array[EnemySpawn]
@export var right_spawns: Array[EnemySpawn]
@export var top_spawns: Array[EnemySpawn]
@export var bottom_spawns: Array[EnemySpawn]

func spawn_enemies(world: World, tent: Tent) -> void:
	var left_enemies: Array[Enemy] = get_enemies(left_spawns)
	var right_enemies: Array[Enemy] = get_enemies(right_spawns)
	var top_enemies: Array[Enemy] = get_enemies(top_spawns)
	var bottom_enemies: Array[Enemy] = get_enemies(bottom_spawns)
	for i in range(max(left_enemies.size(), right_enemies.size(), top_enemies.size(), bottom_enemies.size())):
		spawn_enemy(i, left_enemies, world.left_spawn_line, tent, world.tile_map)
		spawn_enemy(i, right_enemies, world.right_spawn_line, tent, world.tile_map)
		spawn_enemy(i, top_enemies, world.top_spawn_line, tent, world.tile_map)
		spawn_enemy(i, bottom_enemies, world.bottom_spawn_line, tent, world.tile_map)
		await world.get_tree().create_timer(randf_range(0.2, 0.5)).timeout

func get_enemies(enemy_spawns: Array[EnemySpawn]) -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	for enemy_spawn: EnemySpawn in enemy_spawns:
		for n in range(enemy_spawn.count):
			enemies.append(enemy_spawn.enemy)
	enemies.shuffle()
	return enemies

func spawn_enemy(i: int, enemies: Array[Enemy], spawn_line: Line2D, target: Node2D, parent: Node2D):
	if i >= enemies.size(): return
	if spawn_line.get_point_count() < 2: return
	var enemy: EnemyActor = enemies[i].create_enemy()
	enemy.position = get_random_spawn_pos(spawn_line)
	enemy.target = target
	parent.add_child(enemy)

func get_random_spawn_pos(spawn_line: Line2D) -> Vector2:
	var pos: Vector2 = spawn_line.position
	if spawn_line.points[0].x == spawn_line.points[1].x:
		pos.y = randf_range(spawn_line.points[0].y, spawn_line.points[1].y)
	elif spawn_line.points[0].y == spawn_line.points[1].y:
		pos.x = randf_range(spawn_line.points[0].x, spawn_line.points[1].x)
	return pos

static func enemy_count(spawns: Array[EnemySpawn]) -> int:
	var count: int = 0
	for enemy_spawn: EnemySpawn in spawns:
		count += enemy_spawn.count
	return count

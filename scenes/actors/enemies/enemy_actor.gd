class_name EnemyActor extends CharacterBody2D

@export var target: Node2D
@export var max_speed: float = 100
@export var acceleration: float = 6

@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D
@onready var context_map: ContextMap = %ContextMap
@onready var state_chart: StateChart = %StateChart

var enemy: Enemy

func target_exists() -> bool:
	if not target: return false
	return not target.is_queued_for_deletion()

func get_target_position() -> Vector2:
	if not target_exists(): return Vector2.ZERO
	var pos: Vector2 = target.position
	if target is BuildingObject:
		if target.target_points:
			pos = target.target_points.get_child(0).global_position
			for point: Node2D in target.target_points.get_children():
				if position.distance_to(point.global_position) >= position.distance_to(pos): continue
				pos = point.global_position
	return pos

func _on_idling_state_physics_processing(_delta):
	if target_exists() and nav_agent.distance_to_target() > nav_agent.target_desired_distance:
		state_chart.send_event("target_spotted")

func _on_chasing_state_physics_processing(_delta):
	if not target_exists():
		state_chart.send_event("target_lost")
		return
	nav_agent.target_position = get_target_position()
	var target_vector: Vector2 = to_local(nav_agent.get_next_path_position()).normalized()
	#context_map.set_interests([target_vector])
	#nav_agent.velocity = context_map.get_desired_vector() * max_speed
	nav_agent.velocity = target_vector * max_speed
	nav_agent.max_speed = max_speed

func _on_navigation_agent_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, acceleration)
	move_and_slide()

func _on_navigation_agent_target_reached():
	state_chart.send_event("target_reached")

func _on_chasing_state_exited():
	nav_agent.velocity = Vector2.ZERO

func _on_health_depleted():
	Player.gain_money(enemy.reward)
	destroy()

func destroy():
	queue_free()

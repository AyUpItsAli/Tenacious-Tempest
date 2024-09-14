class_name PlayerActor extends CharacterBody2D

@export var max_speed: float = 300
@export var acceleration: float = 50

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var leaf_blower: Node2D = %LeafBlower
@onready var state_chart: StateChart = %StateChart

signal died

func _on_alive_state_physics_processing(_delta):
	# Determine input directions
	var move_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var look_direction: Vector2 = leaf_blower.position.direction_to(get_local_mouse_position())
	# Move
	velocity = velocity.move_toward(move_direction * max_speed, acceleration)
	move_and_slide()
	# Update animation parameters
	set_moving(move_direction != Vector2.ZERO)
	set_facing(look_direction)
	# Rotate leaf blower
	leaf_blower.rotation = look_direction.angle()

func set_moving(moving: bool) -> void:
	animation_tree["parameters/conditions/moving"] = moving
	animation_tree["parameters/conditions/idling"] = not moving

func set_facing(direction: Vector2) -> void:
	animation_tree["parameters/idle/blend_position"] = direction
	animation_tree["parameters/run/blend_position"] = direction
	animation_tree["parameters/hit/blend_position"] = direction

func _on_hurtbox_hit():
	Sounds.play("hurt")
	animation_state_machine.travel("hit")

func _on_health_depleted():
	state_chart.send_event("died")
	died.emit()

func _on_dead_state_entered():
	Sounds.play("player_death")
	animation_state_machine.travel("death") # Calls queue_free() at end of animation

class_name Hurtbox extends Area2D

@export var health: Health
@export var immunity_time: float = 0.5

@onready var immunity_timer: Timer = %ImmunityTimer

signal hit
signal immunity_ended

func hurt(damage: float) -> bool:
	if not immunity_timer.is_stopped():
		return false
	if health:
		if health.is_depleted():
			return false
		health.damage(damage)
		if health.is_depleted():
			return true
	if immunity_time > 0:
		immunity_timer.wait_time = immunity_time
		immunity_timer.start()
	hit.emit()
	return true

func _on_immunity_timer_timeout() -> void:
	immunity_ended.emit()

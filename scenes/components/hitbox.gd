class_name Hitbox extends Area2D

@export var damage: float = 1

signal hit

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		if area.hurt(damage):
			hit.emit()

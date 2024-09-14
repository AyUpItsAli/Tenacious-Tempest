class_name PlaceableBuildingObject extends BuildingObject

@export var collision_shape: CollisionShape2D
@export var hurtbox: Hurtbox
@export var state_chart: StateChart

signal created
signal destroyed

func _on_created_state_entered():
	collision_shape.disabled = true
	hurtbox.monitorable = false
	modulate.a = 0.6
	created.emit()

func _on_placed_state_entered():
	collision_shape.disabled = false
	hurtbox.monitorable = true
	modulate.a = 1

func destroy():
	queue_free()
	destroyed.emit()

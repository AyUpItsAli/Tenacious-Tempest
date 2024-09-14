class_name Barricade extends PlaceableBuildingObject

func _on_created_state_entered():
	super._on_created_state_entered()

func _on_placed_state_entered():
	super._on_placed_state_entered()

func _on_hurtbox_hit():
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

func _on_health_depleted():
	destroy()

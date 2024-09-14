class_name Tent extends BuildingObject

signal destroyed

@onready var health: Health = %Health
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var flames: Node2D = %Flames

func _ready():
	reset()

func reset():
	health.recover_all()
	flames.hide()

func _on_hurtbox_hit():
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

func _on_health_depleted():
	flames.show()
	destroyed.emit()

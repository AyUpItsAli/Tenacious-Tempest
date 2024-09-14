extends Node2D

const YELLOW_CHARGE_Y = 394
const RED_CHARGE_Y = 490

@export var power: float = 400
@export var acceleration: float = 40
@export var max_charge: float = 500
@export var charge_usage: float = 3
@export var charge_regen: float = 1

@onready var hitbox: Area2D = %Hitbox
@onready var particles: GPUParticles2D = %Particles
@onready var charge_bar: Node2D = %ChargeBar
@onready var charge_sprite: Sprite2D = %ChargeSprite

@onready var charge: float = max_charge:
	set(new_charge):
		charge = min(max(new_charge, 0), max_charge)
		charge_sprite.scale.x = charge / max_charge

var active: bool
var overheated: bool

func _ready():
	charge_bar.hide()

func _unhandled_input(event):
	if event.is_action_pressed("leaf_blower") and not overheated:
		active = true
	elif event.is_action_released("leaf_blower"):
		active = false

func _on_alive_state_physics_processing(_delta):
	if not Globals.input_mode == Globals.InputMode.PLAYER:
		active = false
	# Logic
	if active:
		push_enemies()
		charge -= charge_usage
		charge_bar.show()
		if charge == 0:
			active = false
			overheated = true
	elif charge < max_charge:
		charge += charge_regen
		if charge == max_charge:
			charge_bar.hide()
			overheated = false
	# Visuals
	particles.emitting = active
	var texture: AtlasTexture = charge_sprite.texture
	texture.region.position.y = RED_CHARGE_Y if overheated else YELLOW_CHARGE_Y

func push_enemies():
	for body: Node2D in hitbox.get_overlapping_bodies():
		if body is EnemyActor:
			body.velocity = body.velocity.move_toward(Vector2.from_angle(rotation) * power, acceleration)

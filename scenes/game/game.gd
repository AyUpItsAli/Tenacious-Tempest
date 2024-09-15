extends Node2D

const PLAYER_SCENE = preload("res://scenes/actors/player/player.tscn")

const STORMY_WEATHER_LIGHT = 0.65
const WEATHER_CHANGE_DURATION = 1
const POST_STORM_DELAY = 2 # Seconds after a storm before starting the next calm period
const MUSIC_DELAY = 0.5 # Seconds before playing music after starting the game

@onready var timer: Timer = %Timer
@onready var player_camera: PlayerCamera = %PlayerCamera
@onready var world: World = %World
@onready var player_spawn_point: Marker2D = %PlayerSpawnPoint
@onready var tent: Tent = %Tent
@onready var rain: GPUParticles2D = %Rain

# Timer Display
@onready var timer_display: Control = %TimerDisplay
@onready var timer_info: Label = %TimerDisplay/InfoLabel
@onready var timer_seconds: Label = %TimerDisplay/SecondsLabel
# Hints
@onready var tutorial_hint: Label = %TutorialHint
@onready var building_hint: Label = %BuildingHint
@onready var destroy_hint: Label = %DestroyHint
@onready var win_hint: Label = %WinHint
@onready var start_hint: Label = %StartHint
@onready var restart_hint: Label = %RestartHint

# Spawn Labels
@onready var left_spawns_label: Label = %LeftSpawnsLabel
@onready var top_spawns_label: Label = %TopSpawnsLabel
@onready var bottom_spawns_label: Label = %BottomSpawnsLabel
@onready var right_spawns_label: Label = %RightSpawnsLabel
# Money
@onready var money_label: Label = %MoneyLabel

enum Weather {
	CALM,
	STORMY
}

var storms: Array[Storm]
var current_storm: Storm
var current_weather: Weather:
	set(new_weather):
		current_weather = new_weather
		match current_weather:
			Weather.CALM:
				Sounds.stop("rain")
				rain.emitting = false
				create_tween().tween_property(world.tile_map, "modulate:r", 1, WEATHER_CHANGE_DURATION)
				create_tween().tween_property(world.tile_map, "modulate:g", 1, WEATHER_CHANGE_DURATION)
				create_tween().tween_property(world.tile_map, "modulate:b", 1, WEATHER_CHANGE_DURATION)
			Weather.STORMY:
				Sounds.play("rain")
				rain.emitting = true
				create_tween().tween_property(world.tile_map, "modulate:r", STORMY_WEATHER_LIGHT, WEATHER_CHANGE_DURATION)
				create_tween().tween_property(world.tile_map, "modulate:g", STORMY_WEATHER_LIGHT, WEATHER_CHANGE_DURATION)
				create_tween().tween_property(world.tile_map, "modulate:b", STORMY_WEATHER_LIGHT, WEATHER_CHANGE_DURATION)

var tutorial: bool:
	set(new_value):
		tutorial = new_value
		tutorial_hint.visible = tutorial
		destroy_hint.visible = false
var player: PlayerActor

func _ready():
	Globals.input_mode_changed.connect(_on_input_mode_changed)
	Player.money_changed.connect(_on_money_changed)
	start_hint.show()
	tutorial = true
	initialise_game()

func _unhandled_input(event):
	if start_hint.visible and event.is_action_pressed("start"):
		Sounds.play("select")
		start_hint.hide()
		tutorial = false
		start_game()
	elif restart_hint.visible and event.is_action_pressed("start"):
		Sounds.play("select")
		initialise_game()
		start_game()
	if event.is_action_pressed("build"):
		Globals.toggle_building_mode()

func _on_input_mode_changed():
	building_hint.visible = Globals.input_mode == Globals.InputMode.BUILDING
	if tutorial:
		tutorial_hint.visible = not building_hint.visible
		destroy_hint.visible = building_hint.visible

func _on_money_changed():
	money_label.text = "%sg" % Player.money

func initialise_game():
	Globals.input_mode = Globals.InputMode.PLAYER
	Player.reset()
	win_hint.hide()
	restart_hint.hide()
	current_weather = Weather.CALM
	timer_display.hide()
	clear_spawns_labels()
	destroy_enemies()
	world.clear_placed_buildings()
	storms = Data.load_storms()
	tent.reset()
	if is_instance_valid(player):
		player.queue_free()
	player = PLAYER_SCENE.instantiate()
	player.position = player_spawn_point.position
	player_camera.target = player
	player.died.connect(_on_player_died)
	world.tile_map.add_child(player)

func start_game():
	Player.reset()
	world.clear_placed_buildings()
	next_storm()
	await get_tree().create_timer(MUSIC_DELAY).timeout
	Sounds.play("music")

func clear_spawns_labels():
	left_spawns_label.text = ""
	right_spawns_label.text = ""
	top_spawns_label.text = ""
	bottom_spawns_label.text = ""

func setup_spawns_label(spawns_label: Label, spawns: Array[EnemySpawn]):
	var count: int = Storm.enemy_count(spawns)
	spawns_label.text = str(count) if count > 0 else ""

func next_storm():
	current_storm = storms.pop_front()
	if not current_storm: return win()
	timer_info.text = "Next Storm in"
	setup_spawns_label(left_spawns_label, current_storm.left_spawns)
	setup_spawns_label(right_spawns_label, current_storm.right_spawns)
	setup_spawns_label(top_spawns_label, current_storm.top_spawns)
	setup_spawns_label(bottom_spawns_label, current_storm.bottom_spawns)
	timer.start(current_storm.calm_duration)

func _process(_delta):
	if not timer.is_stopped():
		timer_seconds.text = str(timer.time_left + 1).pad_decimals(0)
		timer_display.show()

func _on_timer_timeout():
	if current_weather == Weather.CALM:
		start_storm()
	else:
		end_storm()

func start_storm():
	current_weather = Weather.STORMY
	timer_info.text = "Storm " + str(current_storm.number)
	clear_spawns_labels()
	timer.start(current_storm.duration)
	current_storm.spawn_enemies(world, tent)

func end_storm():
	Sounds.play("storm_end")
	current_weather = Weather.CALM
	timer_display.hide()
	destroy_enemies()
	Player.gain_money(current_storm.reward)
	await get_tree().create_timer(POST_STORM_DELAY).timeout
	next_storm()

func destroy_enemies():
	for child in world.tile_map.get_children():
		if child is EnemyActor:
			child.destroy()

func _on_tent_destroyed():
	game_over()

func _on_player_died():
	game_over()

func game_over():
	timer.stop()
	timer_display.hide()
	restart_hint.show()

func win():
	Sounds.play("victory")
	game_over()
	win_hint.show()

class_name World extends Node2D

@export var decorations_layer: int = 2

@onready var left_spawn_line: Line2D = %LeftSpawnLine
@onready var right_spawn_line: Line2D = %RightSpawnLine
@onready var top_spawn_line: Line2D = %TopSpawnLine
@onready var bottom_spawn_line: Line2D = %BottomSpawnLine
@onready var tile_map: TileMap = %TileMap
@onready var mouse_label_1: Label = %MouseLabel1
@onready var mouse_label_2: Label = %MouseLabel2

var buildings: Array[Building]
var selected_index: int:
	set(new_index):
		selected_index = min(max(new_index, 0), buildings.size()-1)
		update_selected_building()
var selected_building: Building:
	set(new_building):
		if selected_building == new_building: return
		selected_building = new_building
		if selected_building:
			building_display = selected_building.scene.instantiate()
			mouse_label_1.text = selected_building.name
			mouse_label_2.text = "%sg" % selected_building.cost
		else:
			building_display = null
			mouse_label_1.text = ""
			mouse_label_2.text = ""
var building_display: PlaceableBuildingObject:
	set(new_display):
		if building_display == new_display: return
		if is_instance_valid(building_display):
			building_display.queue_free()
		building_display = new_display
		if building_display:
			tile_map.add_child(building_display)
var occupied_tiles: Array[Vector2i]

func _ready():
	Globals.input_mode_changed.connect(update_selected_building)
	buildings = Data.load_buildings()

func _unhandled_input(event):
	if not Globals.input_mode == Globals.InputMode.BUILDING: return
	if event.is_action_pressed("next_building"):
		next_building(1)
	elif event.is_action_pressed("previous_building"):
		next_building(-1)

func next_building(step: int):
	selected_index += step

func update_selected_building():
	match Globals.input_mode:
		Globals.InputMode.BUILDING:
			selected_building = buildings[selected_index]
		_:
			selected_building = null

func _process(_delta):
	if not Globals.input_mode == Globals.InputMode.BUILDING: return
	var tile_pos: Vector2i = tile_map.local_to_map(tile_map.get_local_mouse_position())
	if is_instance_valid(building_display):
		building_display.position = tile_map.map_to_local(tile_pos)
	if selected_building and Input.is_action_pressed("place_building"):
		if not is_valid_pos(tile_pos): return
		if Player.spend_money(selected_building.cost):
			place_building(selected_building, tile_pos)
		else:
			mouse_label_2.modulate = Color.RED
			await get_tree().create_timer(0.1).timeout
			mouse_label_2.modulate = Color.WHITE

func place_building(building: Building, tile_pos: Vector2i):
	if not is_valid_pos(tile_pos): return
	var building_object: PlaceableBuildingObject = building.scene.instantiate()
	building_object.position = tile_map.map_to_local(tile_pos)
	building_object.created.connect(_on_building_created.bind(building_object))
	building_object.destroyed.connect(_on_building_destroyed.bind(building_object))
	tile_map.add_child(building_object)
	tile_map.set_cell(decorations_layer, tile_pos, -1)
	occupied_tiles.append(tile_pos)

func is_valid_pos(tile_pos: Vector2i) -> bool:
	return not occupied_tiles.has(tile_pos)

func _on_building_created(building_object: PlaceableBuildingObject):
	if building_object.state_chart:
		building_object.state_chart.send_event("place")

func _on_building_destroyed(building_object: PlaceableBuildingObject):
	occupied_tiles.erase(tile_map.local_to_map(building_object.position))

func clear_placed_buildings():
	for child in tile_map.get_children():
		if child is PlaceableBuildingObject and child != building_display:
			child.queue_free()
	occupied_tiles.clear()

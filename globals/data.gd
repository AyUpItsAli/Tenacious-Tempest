extends Node

const BUILDINGS: ResourceGroup = preload("res://data/buildings.tres")
const ENEMIES: ResourceGroup = preload("res://data/enemies.tres")
const STORMS: ResourceGroup = preload("res://data/storms.tres")

func load_storms() -> Array[Storm]:
	var storms: Array[Storm] = []
	for path in STORMS.paths:
		var storm: Storm = load(path)
		storms.append(storm)
	storms.sort_custom(sort_storms)
	return storms

func sort_storms(storm_a: Storm, storm_b: Storm) -> bool:
	return storm_a.number < storm_b.number

func load_buildings() -> Array[Building]:
	var buildings: Array[Building] = []
	for path in BUILDINGS.paths:
		var building: Building = load(path)
		buildings.append(building)
	buildings.sort_custom(sort_buildings)
	return buildings

func sort_buildings(building_a: Building, building_b: Building) -> bool:
	return building_a.cost < building_b.cost

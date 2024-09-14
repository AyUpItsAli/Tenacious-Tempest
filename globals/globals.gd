extends Node

enum InputMode {
	PLAYER,
	BUILDING
}

signal input_mode_changed

var input_mode: InputMode:
	set(new_mode):
		input_mode = new_mode
		input_mode_changed.emit()

func toggle_building_mode():
	input_mode = InputMode.BUILDING if input_mode == InputMode.PLAYER else InputMode.PLAYER

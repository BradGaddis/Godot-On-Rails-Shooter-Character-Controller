class_name PlayerManagerState extends Node

signal transitioned

var _input_dir: Vector2
var _look_dir: Vector2

func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


## Called in [method _input]. Handles shooting inputs
func _handle_shooting_input_events(event: InputEvent, input_string):
	if event.is_action_pressed(input_string) && PlayerManager.character.shooting_component:
		PlayerManager.character.shooting_component.start_shot()
		return
	elif event.is_action_released(input_string) && PlayerManager.character.shooting_component:
		PlayerManager.character.shooting_component.complete_shot()


func get_input_dir():
	return _input_dir


func set_input_dir(new_dir: Vector2):
	_input_dir = new_dir


func get_look_dir():
	return _look_dir


func set_look_dir(new_dir: Vector2):
	_look_dir = new_dir

class_name State extends Node
## Base state class for states in a state machine

## Emited when a state will transition from on state to another. Picked up by the parent state machine class
@warning_ignore("unused_signal") signal transitioned

## The time a state will be active
@export var _duration_time: float = 3:
	get: print(self.name + " is working for  " + str(_duration_time) + " sec(s)"); return _duration_time
## The time a state will be in cooldown
@export var _cool_down_time: float = 2:
	get: print(self.name + " is cooling for  " + str(_cool_down_time)); return _cool_down_time
## Whether or not the state is presently in cooldown mode
var is_in_cooldown : bool = false:
	set(val): if val: print([self.name, " just went into cooldown"])

## resets any variables required by this state
## @experimental
func reset() -> void:
	pass

## Called when a state transitions and becomes the current state
func enter(_previous_state: String) -> void:
	pass
	
## Called when a state transitions and stops being the current state
func exit(_next_state: String) -> void:
	pass

## Effectively the [method Node._process] method for an individual state. Handled by the state machine itself
func state_process(_delta) -> void:
	pass
	
## Effectively the [method Node._physics_process] method for an individual state. Handled by the state machine itself
func state_physics_process(_delta) -> void:
	pass

## Transition from the current state to some other state directly via input argument regardless if it is pressed
func change_to_state(state_name):
		transitioned.emit(self, state_name)

## Transition from the current state to some other state via input argument if input argument is pressed
func change_input_state(input: String):
	if Input.is_action_just_pressed(input):
		transitioned.emit(self, input)

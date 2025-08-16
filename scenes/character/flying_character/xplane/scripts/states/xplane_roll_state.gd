class_name XplaneRollState extends FlyingVehicleState
## The Xplane roll state logic
## 
## Defines the logic for entering and exiting the roll state, as well as how the roll works in general

## The amount of times a roll will occure when entering this state
@export var _num_rolls : int = 2

## The tween that governs rolling the visible body mesh
@onready var _tween: Tween

## Used to cache the initial reticle speed
var _initial_move_in_frame_speed : float

## The speed the reticle will be reduced to while in roll as a percentage
var _reticle_movement_reduction : float = .25

## The angle calculated from the number of rolls
var _roll_angle : float

## Just calls the super
func _ready() -> void:
	super._ready()

## On entering this state, sets up inital caches, prevents tilting, and calls [method _roll]
func enter(_ls):
	if PlayerManager.character.vehicle_component.bank_tilt_component:
		PlayerManager.character.vehicle_component.bank_tilt_component.can_tilt = false
	_initial_move_in_frame_speed =PlayerManager.character.move_in_frame_speed
	PlayerManager.character.move_in_frame_speed *= _reticle_movement_reduction
	_roll(_num_rolls)

## On exiting, returns tilting and reticle movement speed
func exit(_next_state):
	if PlayerManager.character.vehicle_component.bank_tilt_component:
		PlayerManager.character.vehicle_component.bank_tilt_component.can_tilt = true
	PlayerManager.character.move_in_frame_speed = _initial_move_in_frame_speed
#
## Sets the roll and angle and tweens the visible body. After finished, switches to the flight state
func _roll(times: int = _num_rolls):
	_roll_angle = -PlayerManager.character.last_x_dir * TAU * times
	_tween = create_tween()
	_tween.tween_property(PlayerManager.character.visible_body, "rotation:z", _roll_angle, _duration_time)
	await _tween.finished
	PlayerManager.character.visible_body.rotation.z = wrapf(PlayerManager.character.visible_body.rotation.z, 0, TAU)
	switch_to_flight_state()

class_name XplaneLoopState extends FlyingVehicleState
## Handles the looping state logic 

## The time that will elapse before the actual loop starts when entering this state
@export var _delay_time: float = 1

## The tween that will loop the Xplane
var _tween: Tween

## The tween that flushes the xplane rotation
var _vehicle_rotation_tween: Tween

## The Tween that restores the initial speed of the xplane
var _out_tween: Tween

## Flush the vehicle rotation
func _realign_rotation() -> Signal:
	_vehicle_rotation_tween = CharacterUtils.kill_and_create_tween(_vehicle_rotation_tween)
	_vehicle_rotation_tween.tween_property(PlayerManager.character.vehicle_component, "rotation", Vector3.ZERO, .1)
	return _vehicle_rotation_tween.finished
	
## The looping logic. Rotated around a pivot point on the x-axis
func _loop() -> Signal:
	_tween = CharacterUtils.kill_and_create_tween(_tween)
	_tween.tween_property(PlayerManager.character.vehicle_component.pivot_point, "rotation:x", TAU, 3)
	return _tween.finished

## Creates a timer to delay the loop
func _set_delay() -> Signal:
	var timer = get_tree().create_timer(_delay_time)
	return timer.timeout

## Sets up inital variables on entering this state. Disables player and tilting
func _player_entry_set_up() -> void:
	PlayerManager.enabled = false
	_initial_flight_speed =PlayerManager.character.get_rail_speed()
	PlayerManager.character.vehicle_component.bank_tilt_component.can_tilt = false

## Restores speed via tweening 
## @experimental: Will refactor this to tween a method instead of a private property 
func _resume_rail_speed_on_exit():
	_out_tween = CharacterUtils.kill_and_create_tween(_out_tween)
	_out_tween.parallel().tween_property(PlayerManager.character, "_rail_speed", _initial_flight_speed, 1)

## Aligns rotation and delays before starting the loop on entering
func enter(last_state: String):
	_player_entry_set_up()
	await _realign_rotation()
	await _set_delay()
	PlayerManager.character.set_rail_speed(0)
	await _loop()
	change_to_state(last_state)

## Returns player control and tilting before restarting movement on exiting
func exit(_next_state):
	PlayerManager.enabled = true
	PlayerManager.character.vehicle_component.bank_tilt_component.can_tilt = true
	PlayerManager.character.vehicle_component.pivot_point.rotation = Vector3.ZERO
	_resume_rail_speed_on_exit()
	

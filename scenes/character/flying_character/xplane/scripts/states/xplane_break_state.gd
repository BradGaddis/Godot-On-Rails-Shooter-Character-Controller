class_name xplane_break_state extends FlyingVehicleState
## The break state logic for xPlane
##
## Handles states that the break state can travel to or enter from

## The speed at which the xplane will boost turn while in this state as a percentage
#@export var _boost_speed_factor: float = 2
@export var _enter_break_speed_curve: Curve
@export var _exit_break_speed_curve: Curve
## The maximum speed for this (regular speed * [member _boost_speed_factor])
var _break_enter_timer: SceneTreeTimer
var _break_exit_timer: SceneTreeTimer
var _active: bool = false


## Essentially exists just to call the super
func _ready():
	super._ready()

## Sets the thrustes' state and timer, sets the initial speed and transitions in.
func enter(_last_state):
	_start_thrusters(_enter_break_speed_curve.max_domain)
	_break_enter_timer = get_tree().create_timer(_enter_break_speed_curve.max_domain)
	_initial_flight_speed = _player.character.get_speed()
	_active = true;
	await _break_enter_timer.timeout
	_break_enter_timer = null
	
## Sets the thrustes' state to cooling and starts cooldown timer.[br]
## Transitions out of this state to the next
func exit(_next_state):
	_stop_thrusters()
	_exit_flight_speed = _player.character.get_speed()
	await _break_exit_timer.timeout
	_break_exit_timer = null
	_break_enter_timer = null

## Handles state change when active
func _physics_process(_delta) -> void:
	if _player.character.state_machine_component.energy_thrusters == ActorEnums.thrust.cooling && _active:
		_active = false;
		start_exit_timer()
		switch_to_flight_state()
		
	if _break_enter_timer:
		var _entry_time_left: float = _enter_break_speed_curve.max_domain - _break_enter_timer.time_left
		var sampled_speed: float = _enter_break_speed_curve.sample(_entry_time_left)
		_player.character.set_speed(sampled_speed * _initial_flight_speed)
	if _break_exit_timer:
		var _exit_time_left: float = _enter_break_speed_curve.max_domain - _break_exit_timer.time_left
		var sampled_speed: float = _exit_break_speed_curve.sample(_exit_time_left)
		_player.character.set_speed(_exit_flight_speed + (_initial_flight_speed - _exit_flight_speed) * sampled_speed)
	_cancel_break_with_boost_to_flight_state()

	print(_player.character.get_speed())

## Exits the break state by pressing boosting action
func _cancel_break_with_boost_to_flight_state():
	if Input.is_action_just_pressed("boost") && _active:
		_active = false;
		start_exit_timer()
		switch_to_flight_state()
		
func start_exit_timer():
	if _break_exit_timer:
		_break_exit_timer = get_tree().create_timer(_exit_break_speed_curve.max_domain - _break_enter_timer.time_left)
		_break_exit_timer.time_left = 0
		return
	_break_exit_timer = get_tree().create_timer(_exit_break_speed_curve.max_domain)
	

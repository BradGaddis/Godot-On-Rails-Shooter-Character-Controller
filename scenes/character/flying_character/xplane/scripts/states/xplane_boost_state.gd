class_name XplaneBoostState extends FlyingVehicleState
## The boost state logic for xPlane
##
## Handles states that the boost state can travel to or enter from

## The speed at which the xplane will boost turn while in this state as a percentage
#@export var _boost_speed_factor: float = 2
@export var _enter_boost_speed_curve: Curve
@export var _exit_boost_speed_curve: Curve
## The maximum speed for this (regular speed * [member _boost_speed_factor])
@export var _boosted_fov : float = 150.0
var _boost_enter_timer: SceneTreeTimer
var _boost_exit_timer: SceneTreeTimer
var _active: bool = false
## The initial Field of View when entering this state
var _initial_fov: float

func _ready() -> void:
	super._ready()

## Sets energy thruster enum to active, captures initial flight, chaches initial FOV and tweens FOV
func enter(_last_state: String = ""):
	_start_thrusters(_enter_boost_speed_curve.max_domain)
	_boost_enter_timer = get_tree().create_timer(_enter_boost_speed_curve.max_domain)
	_initial_fov = PlayerManager.character.camera_component.camera.fov
	_initial_flight_speed = PlayerManager.character.get_speed()
	PlayerManager.character.camera_component.tween_fov(_boosted_fov, _duration_time * 5)
	_active = true;
	await _boost_enter_timer.timeout
	_boost_enter_timer = null
	
## Exits this state and returns speed. Sets thrusters to cooling, and starts cooldown.[br]
## Roll exit time is different than the standard exit time
func exit(_next_state = ""):
	_stop_thrusters()
	_exit_flight_speed = PlayerManager.character.get_speed()
	PlayerManager.character.camera_component.tween_fov(_initial_fov, 1)
	await _boost_exit_timer.timeout
	_boost_exit_timer = null
	_boost_enter_timer = null

## Switches to either flight state or roll state depending on thruster cooling 
func _physics_process(_delta) -> void:
	if PlayerManager.character.state_machine_component.energy_thrusters == ActorEnums.thrust.cooling && _active:
		_active = false;
		start_exit_timer()
		switch_to_flight_state()
		
	if _boost_enter_timer:
		var _entry_time_left: float = _enter_boost_speed_curve.max_domain - _boost_enter_timer.time_left
		var sampled_speed: float = _enter_boost_speed_curve.sample(_entry_time_left)
		PlayerManager.character.set_speed(sampled_speed * _initial_flight_speed)
	if _boost_exit_timer:
		var _exit_time_left: float = _enter_boost_speed_curve.max_domain - _boost_exit_timer.time_left
		var sampled_speed: float = _exit_boost_speed_curve.sample(_exit_time_left)
		PlayerManager.character.set_speed(_initial_flight_speed + (_exit_flight_speed - _initial_flight_speed) * sampled_speed)
		
	_cancel_boost_with_break_to_flight_state()
	print(PlayerManager.character.get_speed())

## Exits the boost state by pressing breaking action
func _cancel_boost_with_break_to_flight_state():
	if Input.is_action_just_pressed("break") && _active:
		_active = false;
		start_exit_timer()
		switch_to_flight_state()

func start_exit_timer():
		if _boost_enter_timer:
			_boost_exit_timer = get_tree().create_timer(_exit_boost_speed_curve.max_domain - _boost_enter_timer.time_left)
			_boost_enter_timer.time_left = 0
			return
		_boost_exit_timer = get_tree().create_timer(_exit_boost_speed_curve.max_domain)
	

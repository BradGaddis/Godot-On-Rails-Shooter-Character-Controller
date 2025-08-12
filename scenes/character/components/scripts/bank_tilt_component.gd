class_name BankTiltComponent extends Node


#region Properties

## The maximum amount the vehicle can tilt
@export var _max_tilt: float = 90
	

## The time between button presses that will allow for a tilt/bank
@export var _tilt_double_tap_time: float = .25

## The speed at which the vehilcle can bank at.
@export var _tilt_speed: float = 4

##@experimental
@export var _tilt_move_speed_curve: Curve

## The rotation threshold for animations to happen while tilting
@export var _z_rot_threshold: float = PI / 2


## The parent component for this component. It should always be a vehicle component.
var vehicle: VehicleComponent

## Whether or not the vehicle is allowed to tilt when action is pressed
var can_tilt: bool = true

var _tilt_timer: SceneTreeTimer

var _cached_player_speed: float
#endregion

func _ready() -> void:
	vehicle = get_parent()
	assert(vehicle, "This node is either not attached to a vehicle component, or we just couldn't find it.")

func physics_process(delta: float) -> void:
	_handle_tilt(delta)

func tilt_time_left() -> bool:
	return is_instance_valid(_tilt_timer) and _tilt_timer  != null and _tilt_timer.time_left > 0  

## Tilts the vehicle if tilt actions are pressed.
## Also will tilt if roll action is semi-pressed
## @experimental: I think this deserves some refactoring. It might not work like I think it does

func _check_vehicle_damage_state():
	# TODO
	pass

func _check_wing_state():
	# TODO
	pass

func _open_wings_on_bank():
	pass
	
func _play_sfx():
	# TODO
	pass


## @experimental
func _handle_flushing(delta: float):
	if vehicle.get_current_action() == ActorEnums.bank_tilt_actions.no_action:
		return
	if PlayerManager.character.visible_body.rotation.z != 0:
		vehicle.set_action(ActorEnums.bank_tilt_actions.flushing_rotation)
		PlayerManager.character.character.visible_body.rotation.z = move_toward(PlayerManager.character.character.visible_body.rotation.z, 0, _tilt_speed * delta) 
		_update_player_speed(abs(PlayerManager.character.visible_body.rotation.z) / deg_to_rad(_max_tilt))
	else:
		vehicle.set_action(ActorEnums.bank_tilt_actions.no_action)

func _handle_tilt(delta: float):
	if !(Input.is_action_pressed("tilt") or (Input.is_action_pressed("roll") and Input.get_action_raw_strength("roll") < 0.75)):
		_handle_flushing(delta)
		return
	if !can_tilt:
		return
	if Input.is_action_just_pressed("tilt"): # start double tap timer 
		_tilt_timer = get_tree().create_timer(_tilt_double_tap_time)
	match vehicle.get_current_action():
		ActorEnums.bank_tilt_actions.tilting:
			PlayerManager.character.last_x_dir =PlayerManager.character.locked_dir
			PlayerManager.character.visible_body.rotation.z = move_toward(PlayerManager.character.visible_body.rotation.z, -PlayerManager.character.locked_dir  *  deg_to_rad(_max_tilt), _tilt_speed * delta) 	
			_update_player_speed(abs(PlayerManager.character.visible_body.rotation.z) / deg_to_rad(_max_tilt))
			_open_wings_on_bank()
		_: # Any state that isn't tilting / banking
			_cached_player_speed =PlayerManager.character.move_in_frame_speed
			PlayerManager.character.locked_dir = PlayerManager.character.last_x_dir
			vehicle.set_action(ActorEnums.bank_tilt_actions.tilting)

func _update_player_speed(x_val: float):
	if PlayerManager.character.character is VehicleCharacter:
		PlayerManager.character.set_move_in_frame_speed(_tilt_move_speed_curve.sample(x_val) * _cached_player_speed )
	

@tool
class_name BankTiltComponent extends Node


#region Properties
## The maximum amount the vehicle can tilt
@export var _max_tilt: float = 90

## The time between button presses that will allow for a tilt/bank
@export var _tilt_double_tap_time: float = .12

## The linear rotation speed at which the vehilcle can bank at.
@export var _tilt_rotaiton_speed: float = 4

##@experimental
@export var _tilt_move_speed_curve: Curve

## The rotation threshold for animations to happen while tilting
@export var _z_rot_threshold: float = PI / 2

## The parent component for this component. It should always be a vehicle component.
@export var vehicle_component: VehicleComponent

## Whether or not the vehicle is allowed to tilt when action is pressed
var can_tilt: bool = true

var _tilt_timer: SceneTreeTimer

var _cached_player_speed: float

@export var flushed_rotation_epsilon: float = .12
#endregion


func _init() -> void:
	if !_tilt_move_speed_curve:
		_tilt_move_speed_curve = Curve.new()
		_tilt_move_speed_curve.max_value = 1.5
		_tilt_move_speed_curve.min_value = 1
		_tilt_move_speed_curve.add_point(Vector2.ZERO)
		_tilt_move_speed_curve.add_point(Vector2(_tilt_move_speed_curve.max_domain, _tilt_move_speed_curve.max_value))


func _get_configuration_warnings() -> PackedStringArray:
	var output: PackedStringArray = []
	if not owner is VehicleCharacter:
		output.append("This component only works when on type VehicleCharacter")
	if not _tilt_move_speed_curve:
		output.append("No tilt speed curve set")
	return output


func _ready() -> void:
	if not vehicle_component:
		vehicle_component = owner.find_children("*","VehicleComponent")[0]
	assert(vehicle_component, "This node is either not attached to a vehicle component, or we just couldn't find it.")
	vehicle_component.bank_tilt_component = self
	


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_handle_tilt(delta)


func tilt_time_left() -> bool:
	return is_instance_valid(_tilt_timer) and _tilt_timer  != null and _tilt_timer.time_left > 0


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


## Tilts the vehicle if tilt actions are pressed. Also will tilt if roll action is semi-pressed
## @experimental Haven't tested whether or not can_tilt will properly disable this or not
func _handle_tilt(delta: float):
	match vehicle_component.get_current_action():
		ActorEnums.bank_tilt_actions.no_action:
			PlayerManager.character.locked_dir = PlayerManager.character.last_x_dir
		ActorEnums.bank_tilt_actions.tilting:
			PlayerManager.character.last_x_dir =PlayerManager.character.locked_dir
			PlayerManager.character.visible_body.rotation.z = move_toward(PlayerManager.character.visible_body.rotation.z, -PlayerManager.character.locked_dir  *  deg_to_rad(_max_tilt), _tilt_rotaiton_speed * delta)
			_update_player_speed(abs(PlayerManager.character.visible_body.rotation.z) / deg_to_rad(_max_tilt))
			_open_wings_on_bank()
		ActorEnums.bank_tilt_actions.flushing_rotation:
			PlayerManager.character.visible_body.rotation.z = move_toward(PlayerManager.character.visible_body.rotation.z, 0, _tilt_rotaiton_speed * delta)
			_update_player_speed(abs(PlayerManager.character.visible_body.rotation.z) / deg_to_rad(_max_tilt))
		_:
			assert(false, "Entered a state that should not exist.")


func _update_player_speed(x_val: float):
	if PlayerManager.character is VehicleCharacter:
		PlayerManager.character.set_move_in_frame_speed(_tilt_move_speed_curve.sample(x_val) * PlayerManager.character.cached_player_speed)


func set_tilt_timer():
	_tilt_timer = get_tree().create_timer(_tilt_double_tap_time)

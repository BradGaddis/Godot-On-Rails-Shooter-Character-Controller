class_name Player extends Node
## Manages input and player-related actions

#region Properties
## Emmited when a character is added to this class
signal character_added

## Reference to the character that this class is controlling
@export var character : Character:
	set(val):if val != character: character = val; character_added.emit()

## A target to look at when locked on
var _target: Node3D

## The directon that player is moving in
var _input_dir: Vector2

## The direction that the player is rotating in
var _look_dir: Vector2

## Which controller type the player is using
var active_controls: ActorEnums.active_controller_type

var _player_state: ActorEnums.player_state = ActorEnums.player_state.STATE_ACTIVE

var y_axis_flipped: bool

var mouse_sensitivity: float

var inverted_camera: bool

## Whether or not the player is allowed to do anything
var enabled: bool = true:
	set(val):
		enabled = val
		if not val:
			print("Player disabled")
			_input_dir = Vector2.ZERO
		else:
			print("Player enabled")

var player_cam_mode: ActorEnums.cam_mode_view = ActorEnums.cam_mode_view.rails

#endregion


## Handles input movement, camera movement, and actions (shooting, etc.)
func _input(event: InputEvent) -> void:
	if not character: return
	if event is InputEventMouse or event is InputEventKey:
		active_controls = ActorEnums.active_controller_type.m_k
	if event is InputEventJoypadButton or InputEventJoypadMotion:
		active_controls = ActorEnums.active_controller_type.game_pad
	if get_tree().paused || !enabled:
		return
	if character is OnFootCharacter:
		_on_foot_input(event)
	_handle_tilt_input_events(event)
	_handle_shooting_input_events(event)


func _handle_tilt_input_events(event: InputEvent):
	if character is not VehicleCharacter: return
	if !character.vehicle_component.bank_tilt_component: return
	if (Input.is_action_pressed("tilt") or (Input.is_action_pressed("roll") and Input.get_action_raw_strength("roll") < 0.75) and character.vehicle_component.can_tilt):
		if character.vehicle_component.get_action() == ActorEnums.bank_tilt_actions.flushing_rotation and \
		abs(character.visible_body.rotation.z) > character.vehicle_component.bank_tilt_component.flushed_rotation_epsilon:
			return
		character.vehicle_component.set_action(ActorEnums.bank_tilt_actions.tilting)
	else:
		if !is_zero_approx(character.visible_body.rotation.z):
			character.vehicle_component.set_action(ActorEnums.bank_tilt_actions.flushing_rotation)
			return
		character.vehicle_component.set_action(ActorEnums.bank_tilt_actions.no_action)
		return
	if Input.is_action_just_pressed("tilt"): # start double tap timer. Handled in roll state for now
		character.vehicle_component.bank_tilt_component.set_tilt_timer()


func _handle_running():
	if character is OnFootCharacter:
		if Input.is_action_pressed("run"):
			character.update_speed(character.run_speed)
			return
		character.update_speed(character.walk_speed)


func _handle_camera_input_and_controls(event: InputEvent):
	if event is InputEventMouseMotion:
		character.camera_component.mouse_look_at_reticle(event)


## Called in [method _input]. Handles shooting inputs
func _handle_shooting_input_events(event: InputEvent):
	var input: String
	if character is VehicleCharacter:
			input = "vehicle_shoot"
	if character is OnFootCharacter:
			input = "on_foot_shoot"

	if event.is_action_pressed(input) && character.shooting_component:
		character.shooting_component.start_shot()
		return
	elif event.is_action_released(input) && character.shooting_component:
		character.shooting_component.complete_shot()


## Processes states processes if enabled
func _process(_delta:float):
	if not enabled or get_tree().paused or not character:
		return
	_target = character.shooting_component.get_current_target()


## Processes states physics processes if enabled, as well as gets input directions
func _physics_process(delta: float) -> void:
	if not enabled or get_tree().paused or not character:
		return
	_input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	_look_dir = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	_flight_character_vehicle_process(delta)
	_grounded_character_vehicle_process(delta)
	_foot_character_process(delta)
	character.camera_component.handle_camera_base_actions(delta, player_cam_mode, _target)
	character.move(_input_dir)


func _flight_character_vehicle_process(delta: float):
	if not character is FlyingVehicleCharacter:
		return

	if character.reticle_component:
		character.reticle_component.move(delta, _input_dir)


func _grounded_character_vehicle_process(_delta: float):
	if not character is GroundedVehicleCharacter:
		return


func _foot_character_process(delta: float):
	if not character is OnFootCharacter:
		return
	_handle_running()
	character.reticle_component.move(delta, _look_dir)
	#character.camera_component.handle_foot_camera(delta, player_cam_mode, _target)


func get_input_dir() -> Vector2:
	return _input_dir


func get_player_state():
	return _player_state


func set_player_state(state: ActorEnums.player_state):
	_player_state = state


func _on_foot_input(event: InputEvent):
	_handle_camera_input_and_controls(event)


func toggle_inverted_y_axis():
	y_axis_flipped = !y_axis_flipped

class_name Player extends Node
## Manages input and player-related actions

## Emmited when a character is added to this class
signal character_added

#region Properties
## Reference to the character that this class is controlling
@export var character : Character:
	set(val):if val != character: character = val; character_added.emit()

## A target to look at when locked on
var _target: Node3D

## The directon that player is moving in
var _input_dir: Vector2:
	get:
		return current_state.get_input_dir()

## The direction that the player is rotating in
var _look_dir: Vector2:
	get:
		return current_state.get_look_dir()

## Which controller type the player is using
var active_controls: ActorEnums.active_controller_type

var _player_state: ActorEnums.player_state = ActorEnums.player_state.STATE_ACTIVE

var y_axis_flipped: bool = true

var mouse_sensitivity: float

var inverted_camera: bool

var current_state: PlayerManagerState:
	set(val):
		if val == null and states.size() > 0:
			current_state = states[states.keys()[0]]
			push_error("Invalid state, defaulting")
		else:
			current_state = val

var previous_state: PlayerManagerState

var states: Dictionary[String, PlayerManagerState]

## Whether or not the player is allowed to do anything
var enabled: bool = true:
	set(val):
		enabled = val
		if not val:
			print("Player disabled")
			current_state.set_input_dir(Vector2.ZERO)
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
	#if get_tree().paused || !enabled:
		#return


func _ready():
	_setup_states()


func _check_state():
	if character is FlyingVehicleCharacter:
		current_state = states.get("FlyingPlayer")
	if character is OnFootCharacter:
		current_state = states.get("FootPlayer")

## Processes states processes if enabled
func _process(delta:float):
	if not enabled or get_tree().paused or not character:
		return
	current_state.update(delta)
	_target = character.shooting_component.get_current_target()
	_check_state()


## Processes states physics processes if enabled, as well as gets input directions
func _physics_process(delta: float) -> void:
	if not enabled or get_tree().paused or not character:
		return
	current_state.physics_update(delta)
	character.camera_component.handle_camera_base_actions(delta, player_cam_mode, _target)
	character.move(_input_dir)
	_check_state()


func get_input_dir() -> Vector2:
	return _input_dir


func get_player_state():
	return _player_state


func set_player_state(state: ActorEnums.player_state):
	_player_state = state


func toggle_inverted_y_axis():
	y_axis_flipped = !y_axis_flipped


func _on_state_transitioned(new_state: PlayerManagerState) -> void:
	print("PlayerManager state was changed from %s to %s", [current_state.name, new_state.name])
	current_state = new_state


func _setup_states() -> void:
	for child in get_children():
		if child is PlayerManagerState:
			states[child.name] = child
			child.transitioned.connect(_on_state_transitioned)
	current_state = states[states.keys()[0]]

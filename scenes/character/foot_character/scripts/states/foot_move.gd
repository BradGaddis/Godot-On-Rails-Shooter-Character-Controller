class_name FootMoveState extends State
#TODO Clean this class up. The code is getting a little sloppy


var _direction: Vector2:
	get:
		return PlayerManager.character.get_input_dir()

## The direction the character is turning in
var _character_direction: Vector3

## How fast the character will accelerate on moving
@export var _acceleration : float = 5

var _speed: float = 20

## The x and z velocity
var _planer_velocity_xz: Vector3

## How fast the character will deccelerate on slowing down
@export var _deceleration : float = 5

@export var _transition_epsilon: float = .1

func update_speed(new_speed: float):
	_speed = new_speed


func enter(previous_state: State) -> void:
	_update_animation("running", true)
	if previous_state.name == "idle":
		_planer_velocity_xz = Vector3.ZERO


func exit(previous_state: State) -> void:
	_update_animation("running", false)
	#while(_actor.velocity != Vector3.ZERO):
		#_actor.velocity = _actor.velocity.move_toward(Vector3.ZERO, get_physics_process_delta_time() * 5)
		


## Assigns directions in line with the camera, moves in the planer
func handle_character_movement(delta):
	_character_direction = (PlayerManager.character.camera_component.camera.global_basis.x * Vector3(1,0,1)).normalized() * _direction.x
	_character_direction -= (PlayerManager.character.camera_component.camera.global_basis.z * Vector3(1,0,1)).normalized() * _direction.y
	if _direction:
		_planer_velocity_xz = _planer_velocity_xz.move_toward(_character_direction * _speed, _acceleration * delta)
	else:
		_planer_velocity_xz = _planer_velocity_xz.move_toward(Vector3.ZERO, _deceleration * delta * _planer_velocity_xz.length())
		_try_stop_moving()
	PlayerManager.character.velocity.x =_planer_velocity_xz.x
	PlayerManager.character.velocity.z =_planer_velocity_xz.z


#TODO fix this. It can get stuck in this state under the right conditions
func _try_stop_moving() -> void:
	if _planer_velocity_xz.length() <= _transition_epsilon:
		_planer_velocity_xz = Vector3.ZERO
		PlayerManager.character.velocity = Vector3.ZERO
		PlayerManager.character.state_machine_component.current_state.change_to_state("idle")
		return


func state_physics_process(delta) -> void:
	#TODO handle sub-states
	#current_state = _states.get("walk")
	#if current_state:
		#current_state.handle_character_movement(delta)
		#return
	#change_to_state("idle")
	if Input.is_action_pressed("jump"):
		change_to_state("jump")
		return
	handle_character_movement(delta)

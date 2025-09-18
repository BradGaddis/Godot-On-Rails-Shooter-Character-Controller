class_name FootMoveState extends State

var _direction: Vector2:
	get:
		return PlayerManager.character.get_input_dir()

## The direction the character is turning in
var _character_direction: Vector3

## How fast the character will accelerate on moving
@export var _acceleration : float = .5

var _speed: float = 20
## The x and z velocity
var _planer_velocity_xz: Vector3

## How fast the character will deccelerate on slowing down
@export var _deceleration : float = 5

@export var _transition_epsilon: float = .1

func update_speed(new_speed: float):
	_speed = new_speed


## Assigns directions in line with the camera, moves in the planer
func _handle_character_movement(delta):
	_character_direction = (PlayerManager.character.camera_component.camera.global_basis.x * Vector3(1,0,1)).normalized() * _direction.x
	_character_direction -= (PlayerManager.character.camera_component.camera.global_basis.z * Vector3(1,0,1)).normalized() * _direction.y
	if _direction:
		_planer_velocity_xz = _planer_velocity_xz.move_toward(_character_direction * _speed, _acceleration * delta)
	else:
		_planer_velocity_xz = _planer_velocity_xz.move_toward(Vector3.ZERO, _deceleration * delta * _planer_velocity_xz.length())
		if _planer_velocity_xz.length() <= _transition_epsilon:
			_planer_velocity_xz = Vector3.ZERO
	PlayerManager.character.velocity.x =_planer_velocity_xz.x
	PlayerManager.character.velocity.z =_planer_velocity_xz.z
	
	if _planer_velocity_xz == Vector3.ZERO:
		change_to_state("idle")

func state_physics_process(delta) -> void:
	if Input.is_action_pressed("jump"):
		change_to_state("jump")
		return
	_handle_character_movement(delta)

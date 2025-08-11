class_name OnFootCharacter extends Character
## The base class for being on-foot

## Reference to the camrera component
@onready var _camera_component : CameraComponent = %CameraComponent
## How fast the character will accelerate on moving
@export var _acceleration : float = .5
## How fast the character will deccelerate on slowing down
@export var _deceleration : float = 5
## The amount of velocity to gain before fall damage taken
@export var _fall_damage_threshold: float = -5
## Previous frame y velocity
var _last_y_velocity: float
## The speed of movement
var _speed: float
## The speed the character will walk at
@export var walk_speed: float = 5
## The speed the character will run at
@export var run_speed: float = 50
## The direction the character is turning in
var _character_direction: Vector3
## The x and z velocity
var _planer_velocity_xz: Vector3
## Force of jumping
const JUMP_VELOCITY = 4.5

## Super and lock mouse
func _ready() -> void:
	super._ready()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _detect_fall_damage():
	if is_on_floor() and _last_y_velocity < _fall_damage_threshold and is_on_floor():
		_hurt_box.take_damage(abs(_last_y_velocity))
	_last_y_velocity = velocity.y

## Assigns directions in line with the camera, moves in the planer 
func _handle_character_movement(delta):
	_character_direction = (_camera_component.camera.global_basis.x * Vector3(1,0,1)).normalized() * _direction.x
	_character_direction -= (_camera_component.camera.global_basis.z * Vector3(1,0,1)).normalized() * _direction.y
	if _direction:
		_planer_velocity_xz = _planer_velocity_xz.move_toward(_character_direction * _speed, _acceleration * delta)
	else:
		_planer_velocity_xz = _planer_velocity_xz.move_toward(Vector3.ZERO, _deceleration * delta * _planer_velocity_xz.length())
	velocity.x =_planer_velocity_xz.x
	velocity.z =_planer_velocity_xz.z

func update_speed(new_speed: float):
	_speed = new_speed

## Moves the character via the reticle and handles jumping
func _physics_process(delta: float) -> void:
	_handle_character_movement(delta)
	if not is_on_floor():
		velocity.y -= _gravity * delta * _mass
	_detect_fall_damage()
	jump()
	move_and_slide()
	if _mode == ActorEnums.mode.free:
		_rotate_character_toward_reticle(delta)

## Handles jumping
func jump():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

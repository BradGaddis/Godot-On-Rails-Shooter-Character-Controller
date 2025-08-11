class_name VehicleComponent extends CharacterBody3D

#region Parameters
@export var _player: Player
## Reference to the reticle component
@onready var _reticle_component: ReticleComponent = %ReticleComponent
## Enum actions the vehicle can take
@onready var _current_action: ActorEnums.bank_tilt_actions = ActorEnums.bank_tilt_actions.no_action
## The point that the loop state will pivot around
@onready var pivot_point: Marker3D = $"Pivot Point"
@export_group("Movement")
## Handles how the vehilce will rotate while moving
@export var _rotation_speed: float = 2

## How fast the vehicle will accelerate when following the reticle
@export var _acceleration: float = 5
## The speed maximum speed the vehicle will follow the reticle at
@export var _move_speed: float = 25

## The bounds on the screen that the body of the vehicle will not exit from.
## Typically within the camera view
@export var _lock_bounds: Vector2 = Vector2(20, 10)

#@onready var ray_cast_3d: RayCast3D = %RayCast3D
@onready var bank_tilt_component: BankTiltComponent 

#region Damage States
var left_wing_state: ActorEnums.vehicle_wing_state = ActorEnums.vehicle_wing_state.INTACT
var right_wing_state: ActorEnums.vehicle_wing_state = ActorEnums.vehicle_wing_state.INTACT
#endregion

#endregion

func _ready() -> void:
	assert(owner is VehicleCharacter)
	owner.vehicle_component = self
	bank_tilt_component = get_node_or_null("%BankTiltComponent")

## Handles how the vehicle will rotate while in motion
func _handle_rotation(delta: float):
	if _current_action == ActorEnums.bank_tilt_actions.tilting:
		return
	rotation.x = move_toward(rotation.x, velocity.y, _rotation_speed * delta)
	rotation.y = move_toward(rotation.y, -velocity.x, _rotation_speed * delta)
	#rotation.z = move_toward(rotation.z, -velocity.x * 2, _rotation_speed * delta  * _tilt_speed)
	
## Moves in time with the reticle
func _follow_reticle(delta: float, _dead_zone: float = 2):
	if !_player.enabled:
		return
	var direction : Vector3 = (_reticle_component.reticle_object.global_position - global_position).normalized()
	velocity.x = move_toward(velocity.x, direction.x * _move_speed * delta, _acceleration)
	velocity.y = move_toward(velocity.y, direction.y * _move_speed * delta, _acceleration)
	position.z = 0
	move_and_collide(velocity)
	_lock_to_bounds()


	
## handles the movement of the vehicle
func move(delta: float) -> void:
	_handle_rotation(delta)
	_follow_reticle(delta)

## Locks the component to the screen
func _lock_to_bounds():
	transform.origin.x = clamp(transform.origin.x,
		-_lock_bounds.x, _lock_bounds.x
	)
	transform.origin.y = clamp(transform.origin.y,
		-_lock_bounds.y, _lock_bounds.y
	)

func get_current_action() -> ActorEnums.bank_tilt_actions:
	return _current_action

func set_action(action: ActorEnums.bank_tilt_actions) :
	_current_action = action
	

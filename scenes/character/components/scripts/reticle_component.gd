class_name ReticleComponent extends Node3D
## Handles moving a reticle around the screen
## 
## @experimental: Not fully completed, Missing the ACTUAL reticle asset.
## Presently using a CSG box.


## Bounds to keep reticle within screen view
@export var _lock_bounds: Vector2 = Vector2(60, 35)
## Radius that moving the reticle will do nothing in
@export var _rail_dead_zone_radius: float  = 1
## The speed that the reticle will return to center when no player input is present
@export var _reticle_pull_speed: float = 1
## The position in space that the reticle will remain in front at
@export var _z_locked_pos: float = -30
## The coordinates of the reticle in screen-space
var retical_screen_position: Vector2 
## The tween the returns the retile to the center of the screen
var _pull_tween: Tween
## @deprecated
var tolerated_screen_bounds: Vector4
@onready var reticle_object: Marker3D = %ReticleObject

## Sets z-lock so the reticle always stays in front of the player
func _ready() -> void:
	reticle_object.position.z = _z_locked_pos

## Keeps z-position locked and manages locking on mode
func physics_process(_delta: float) -> void:
	reticle_object.position.z = _z_locked_pos
	if PlayerManager.get_mode() == ActorEnums.mode.on_rails:
		_lock_to_camera_bounds()
	

## Moves reticle horizontally
func _handle_horizontal_reticle_movement(delta: float, direction: Vector2):
	if direction.x:
		position.x += direction.x * PlayerManager.character.move_in_frame_speed * delta
	return

## @deprecated
func _hit_vertical_screen_bound(_bound: float = _lock_bounds.y) -> bool:
	return abs(position.y) == _bound

## @deprecated
func _hit_horizontal_screen_bound(_bound: float  = _lock_bounds.x) -> bool:
	return abs(position.x) >= abs(_bound)

## Moves reticle vertically
func _handle_vertical_reticle_movement(delta: float, direction: Vector2) -> void:
	if direction.y:
		position.y += direction.y * PlayerManager.character.move_in_frame_speed * delta * (-1 if File.settings.inverted_flight_control else 1)
	return

## Pulls reticle back to the center of the screen
func _pull_reticle(_delta: float, direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		CharacterUtils.kill_tween(_pull_tween)
		return
	var flatted_reticle_plane = Vector2(position.x,position.y)
	var dist_from_center: float = flatted_reticle_plane.distance_squared_to(Vector2.ZERO)
	if abs(dist_from_center) < abs(_rail_dead_zone_radius):
		CharacterUtils.kill_tween(_pull_tween)
		return 
	_pull_tween = CharacterUtils.kill_and_create_tween(_pull_tween)
	_pull_tween.tween_property(self, "position:x", 0,_reticle_pull_speed)
	_pull_tween.parallel().tween_property(self, "position:y", 0,_reticle_pull_speed)

## Locks the to be in what the camera can see
func _lock_to_camera_bounds() -> void:
	transform.origin.x = clamp(transform.origin.x,
		-_lock_bounds.x, _lock_bounds.x
	)
	transform.origin.y = clamp(transform.origin.y,
		-_lock_bounds.y, _lock_bounds.y
	)

func _rotate_around_player(direction: Vector2, delta: float, rotation_speed: float = 5, limit_y = PI, limit_x = PI / 3):
	rotation.y += -direction.x * rotation_speed * delta
	rotation.x += -direction.y * rotation_speed * delta
	if limit_y == PI:
		rotation.y = wrapf(rotation.y, -limit_y, limit_y)
	else:
		rotation.y = clampf(rotation.y, -limit_y, limit_y)
	rotation.x = clampf(rotation.x, -limit_x, limit_x)
	

## Handles general movement such as pulling
## and moving the reticle via [method _handle_horizontal_reticle_movement]
## and [method _handle_vertical_reticle_movement] 
func move(delta: float, direction: Vector2) -> void:
	match PlayerManager.character.get_mode():
		ActorEnums.mode.on_rails:
			_pull_reticle(delta, direction)
			_handle_horizontal_reticle_movement(delta, direction)
			_handle_vertical_reticle_movement(delta, direction)
			rotation = Vector3.ZERO
		ActorEnums.mode.free:
			position.x = 0
			position.y = 0
			_rotate_around_player(direction,delta)

	return

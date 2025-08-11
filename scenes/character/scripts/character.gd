class_name Character extends Actor
## The character that the player plays as
##
## The speed at which the reticle will move in frame
@export var move_in_frame_speed : float = 50
## How far the camera can deviate from the rails
@export var rail_bounds_tolerances: Vector4 = Vector4.ZERO
## Reference to the reticle component
var reticle_component: ReticleComponent
## Reference to the camera component
var camera_component: CameraComponent
## Player input direction
var _direction : Vector2
## The cached input direction for locking it during certain actions
var locked_dir: float
## The last x direction stored away for some actions
## @experimental: I will likely change this, as I don't like how much space it takes up and feel it can be optimized
var last_x_dir: float = -1:
	set(val): 
		if val == 0:
			return;
		last_x_dir = sign(val);
	get: return sign(last_x_dir)
	
func _ready() -> void:
	super._ready()
	if !PlayerManager.character: # TODO Remove in later version. Here for testing
		PlayerManager.character = self
	reticle_component = get_node_or_null("%ReticleComponent")
	camera_component = get_node_or_null("%CameraComponent")
	if shooting_component:
		shooting_component.update_projectile_collision_layer(2**3 + 1)
		shooting_component.update_projectile_collision_mask(2**3 + 1)

## Handles inputs
func move(direction: Vector2):
	_direction = direction
	last_x_dir = direction.x
	if !reticle_component:
		print("no reticle component")
		return
	
## Handles rail movement while mode is on_rails
func _handle_rail_movement():
	if _mode != ActorEnums.mode.on_rails:
		return
	clamp_position_by_tolerance() 

## Clamps how far the player is allowed to push the camera
func clamp_position_by_tolerance():
	position.y = clamp(position.y, -rail_bounds_tolerances.z, rail_bounds_tolerances.w)
	position.x = clamp(position.x, -rail_bounds_tolerances.x, rail_bounds_tolerances.y)

## Rotates the Visible Body toward the reticle
func _rotate_character_toward_reticle(delta: float, yaw_speed: float =  3, pitch_speed: float =  2.0, exclude_pitch: bool = true):
	var direction = visible_body_dir_to_reticle()
	var current_rot = visible_body.rotation
	var target_yaw = atan2(direction.x, direction.z)
	current_rot.y = lerp_angle(current_rot.y, target_yaw, yaw_speed * delta)

	if not exclude_pitch:
		var target_pitch = asin(-direction.y)
		current_rot.x = lerp_angle(current_rot.x, target_pitch, pitch_speed * delta)

	visible_body.rotation = current_rot


## Checks character status (ex. Dead/Alive), disables
#func physics_process(_delta: float) -> void:
	#if status == ActorEnums.status.dead:
		#_gm.player.enabled = false

func visible_body_dir_to_reticle() -> Vector3:
	return (visible_body.global_transform.origin - reticle_component.reticle_object.global_transform.origin).normalized()

func dir_to_reticle() -> Vector3:
	return (reticle_component.reticle_object.global_transform.origin - global_transform.origin).normalized()

#func toggle_enabled():
	#_gm.player.enabled = !_gm.player.enabled

func get_speed() -> float:
	match _mode:
		ActorEnums.mode.on_rails:
			return get_rail_speed()
		ActorEnums.mode.free:
			return get_forward_speed()
		_:
			assert(false, "Either function doesn't cover mode you have chosen, or you royally messed something up.")
			return -1
	
func set_speed(val: float) -> void:
	match _mode:
		ActorEnums.mode.on_rails:
			set_rail_speed(val)
		ActorEnums.mode.free:
			set_forward_speed(val)
		_:
			assert(false, "Either function doesn't cover mode you have chosen, or you royally messed something up.")

func set_move_in_frame_speed(val: float):
	move_in_frame_speed = val

class_name CameraComponent extends SpringArm3D
## Handles collisions and rotations when targeting a node

#region Properties
## The child (actual) camera component of this spring arm
@onready var camera : PlayerCamera = $Camera3D
## The target rotation of this object when locked on.
## Used to cache a rotation when looking at a target
@onready var _target_rotation: Vector3 = Vector3(camera.rotation.x, 0 ,0)
## The tween that moves the field of view
@onready var _fov_tweener: Tween


## The maximium that the camera is allowd to rotate positively
@export var _max_x_rotation : float = PI/3
## The maximium that the camera is allowd to rotate negatively
@export var _min_x_rotation : float = -PI/3
## The duration in seconds that the camera will take to rotate
@export var _duration: float = .25
## @experimental: Not implemeted for the on-foot characters yet
@warning_ignore("unused_private_class_variable")
@export var _line_of_sight_range: float 
## Tween used to rotate the camera
var _tween: Tween
@export var v_offset: float
@export var h_offset: float
#endregion

## Used to tween the field of view in or out
## @experimental TODO add curve for "smooth_step"
func tween_fov(amount : float, time : float, type = Tween.EASE_OUT) -> void:
	_fov_tweener = CharacterUtils.kill_and_create_tween(_fov_tweener)
	_fov_tweener.set_ease(type).tween_property(self.camera, "fov", amount, time)

## Rotates the camera to look in the direction that the player intends to see in
func mouse_look_at_reticle(event: InputEventMouseMotion) -> void:
	var delta: float = get_physics_process_delta_time()
	PlayerManager.character.reticle_component.rotation.y += event.relative.x * delta * File.settings.mouse_sensitivity * (-1 if File.settings.inverted_camera else 1)
	PlayerManager.character.reticle_component.rotation.y = wrapf(PlayerManager.character.reticle_component.rotation.y, -PI, PI)
	PlayerManager.character.reticle_component.rotation.x += event.relative.y * delta * -1
	PlayerManager.character.reticle_component.rotation.x = clamp(PlayerManager.character.reticle_component.rotation.x, _min_x_rotation, _max_x_rotation)

## Looks at the reticle
## @experimental: Might use lerp or quaternions
func look_at_reticle(_delta: float, _rotation_speed: float):
	look_at(PlayerManager.character.reticle_component.reticle_object.global_position)


## Smoothly looks at a target
## @experimental: Experimental because I don't understand it. At all...
func look_at_target(target: Node3D,\
delta: float,\
return_duration: float = _duration,\
rotation_speed: float = 20.0,\
):
	if !target: position_camera_behind_player(return_duration); return
	var weight: float = 1.0 - pow(0.5, delta * rotation_speed)
	var dir : Vector3 = target.global_position - global_position
	rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), weight)
	rotation.y = clamp(rotation.y, -PI/6, PI/6)
	
## Repositions the camera to be behind the player[br]
## Really only useful for when the player is in standby and there's an event
func position_camera_behind_player(duration: float = _duration) -> void:
	if PlayerManager.character.get_mode() == ActorEnums.mode.on_rails:
		_tween_rotation_component(PlayerManager.character.visible_body.rotation.y, duration)
	if PlayerManager.character.get_mode() == ActorEnums.mode.free:
		if PlayerManager.state_machine_component.current_state.name == "roll":
			_tween_rotation_component(PlayerManager.character.visible_body.rotation.y, duration)
			return
		return

func _tween_rotation(target_rotation: Vector3, duration: float = _duration) -> Tween:
	_tween = CharacterUtils.kill_and_create_tween(_tween)
	_tween.tween_property(self, "rotation", target_rotation, duration)
	return _tween

## Unlike the look rotation, this method is handled in script to look at a target
func _tween_rotation_component(target_y_rotation: float, duration: float = _duration) -> Tween:
	_target_rotation.y = wrapf(target_y_rotation, rotation.y - PI, rotation.y + PI)
	_tween = CharacterUtils.kill_and_create_tween(_tween)
	_tween.tween_property(self, "rotation", _target_rotation, duration)
	return _tween

func handle_on_foot_camera_free(_target: Node3D, delta: float):
	if _target:
		# TODO
		pass
	PlayerManager.character.camera_component.look_at_reticle(delta, 20)

func handle_flight_camera_on_rails(mode: ActorEnums.cam_mode_view):
	match mode:
		ActorEnums.cam_mode_view.rails:
			handle_flight_camera_rail_state_cam(PlayerManager.character.state_machine_component.current_state.name)

func handle_flight_camera_rail_state_cam(state: String):
	match state:
		"fly":
			var input_dir: Vector2 = PlayerManager.get_input_dir() if PlayerManager.get_player_state() == ActorEnums.player_state.STATE_ACTIVE else Vector2.ZERO
			rotation.y = CharacterUtils.math_smooth_step_to_f(rotation.y, deg_to_rad(-input_dir.x * 10), deg_to_rad(1), deg_to_rad(.5), deg_to_rad(.01))
			rotation.x = CharacterUtils.math_smooth_step_to_f(rotation.y, deg_to_rad(input_dir.y * 10), deg_to_rad(1), deg_to_rad(.5), deg_to_rad(.01))
			position.x = CharacterUtils.math_smooth_step_to_f(position.x, (input_dir.x * 5) * PlayerManager.character.position.x , 1, .5, .05)
			position.y = CharacterUtils.math_smooth_step_to_f(position.x, (input_dir.y * 5) * PlayerManager.character.position.x, 1, .5, .05)
		"u-turn":
			pass

func handle_flight_camera(target: Node3D, delta: float, mode: ActorEnums.cam_mode_view):
	if target:
		look_at_target(target, delta)
		return
	match PlayerManager.character.get_mode():
		ActorEnums.mode.on_rails:
			handle_flight_camera_on_rails(mode)
		ActorEnums.mode.free:
			position_camera_behind_player(.25)

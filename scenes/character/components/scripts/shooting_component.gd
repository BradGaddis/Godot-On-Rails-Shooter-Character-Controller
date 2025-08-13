class_name ShootingComponent extends Node3D
## Handles shooting related logic
## 
## Handles spawning a projectile and setting up the parameters for launching it.

#region Parameters
## Emited when fully charged
signal finshed_charging

## Emitted when a projectile was launched
signal shot_fired

## Reference to the time that controls charging length
var _charge_hold : Timer

## The layer of the hitbox on the projectile
var _projectile_collision_layer: int = 0

## The layer of the hurtbox on the projectile
var _projectile_collision_mask: int = 0

## A temporary variable that is only used while charging
var _temp_charging_shot : Projectile

## Reference to the projectile scene
@onready var _projectile_packed_scene: PackedScene = preload("uid://ulc2i5sibkjk")

## Reference to the projectile component
@onready var _reticle_component: ReticleComponent = get_node_or_null("%ReticleComponent")


@export_group("Shooting")
## Speed a projectile will launch at
@export var _shot_speed: float = 100
## @experimental: Not implemented
@export var _tapered_velocity: bool # TODO

## @experimental: Not implemented
@export var shot_fall_off: float # TODO

## The damage the projectile will dole to the hurtbox that it collides with
@export var _damage: float = 5

@export_range(0, 10, 1, "hide_slider") var max_num_guns: int

## Effectively childen that function as seperate shooting components, disbling this shooting comp
var _extra_guns: Array[ExtraGuns]

@export_group("Charging")

## The time from zero a charge will take
@export var _charge_time: float = 1

## The amount of damage a shot will do relative to its size
@export var _charge_strength_factor: float = 1

## The amount of time that has to elapse before a shot will start charging / update its damage
## @experimental Might just deal with this with the curve itself instead in the future
@export var _min_charge_time_thresholds : float = 0.25

@export var _charge_curve: Curve

## @experimental: TODO swap charging booleans
var _charging_status: ActorEnums.charging

var _was_locked_on: bool

@export_group("Other")
## Reference to the camera component
@onready var _camera_component: CameraComponent = get_node_or_null("%CameraComponent")
## A target to lock on to when charging is complete
var _target: Node3D
#endregion

## Calls [method _set_up_timer]
func _ready() -> void:
	_set_up_charging_timer()
	for child in get_children():
		if child is ExtraGuns:
			_extra_guns.append(child)
	
## Creates and sets up a timer at [member _charge_hold] for charging based on properties for charging time
func _set_up_charging_timer() -> void:
	_charge_hold = Timer.new()
	_charge_hold.one_shot = true
	_charge_hold.wait_time = _charge_time
	_charge_hold.timeout.connect(_on_charge_hold_timeout)
	add_child(_charge_hold)

## Get a launch direction for a shot form a target. Default target is the reticle
func _get_shot_launch_direction(target: Node3D = _reticle_component.reticle_object) -> Vector3:
	return (target.global_position - global_position).normalized()
	
## Updates the [memeber _target] via [method CameraComponent.get_nearest_visible_target]
## @experimental: TODO add functionality for changing a target
func _lock_on() -> void:
	_target = _camera_component.camera.get_nearest_visible_target(_target)
	if not _target and _was_locked_on:
		_camera_component.position_camera_behind_player()

## Force a lock off. Optional boolean argument. Sets [memeber _target] to null
func _force_lock_off(off: bool = true) -> void:
	if off:
		_was_locked_on = false
		_target = null

## The logic for charging. Handles size and damage and charge timer things
func _handle_charging(delta) -> void:
	if not _charging_status == ActorEnums.charging.is_charging or not _temp_charging_shot:
		return
	if 1 - _charge_hold.time_left < _min_charge_time_thresholds:
		return
	var size: float = _charge_curve.sample(1 - _charge_hold.time_left / _charge_time) * delta
	_temp_charging_shot.scale = Vector3(
		_temp_charging_shot.scale.x + size,
		_temp_charging_shot.scale.y + size,
		_temp_charging_shot.scale.z + size,
	)
	_damage = _charge_strength_factor * size

## Updates shot speed according to character mode
func _update_shot_speed() -> float:
	match owner.get_mode():
		ActorEnums.mode.on_rails:
			return _shot_speed + PlayerManager.character.get_rail_speed()
		_:
			return _shot_speed

## Updates the charging status on [member _charge_hold] timeout[br]
## Emits [member finshed_charging]
func _on_charge_hold_timeout():
	_charging_status = ActorEnums.charging.charged
	finshed_charging.emit()

## Sets up projectile, emits [member shot_fired] returns it
func _setup_shot() -> Projectile:
	var shot: Projectile = _temp_charging_shot
	if not _temp_charging_shot:
		return
	shot.top_level = true
	if _reticle_component:
		shot.set_launch_direction(_get_shot_launch_direction())
	shot.set_initial_position(global_position)
	shot.set_shot_speed(_update_shot_speed())
	shot.set_tapered_velocity(_tapered_velocity)
	shot.set_damage(_damage)
	shot.update_collision_layer(_projectile_collision_layer)
	shot.update_collision_mask(_projectile_collision_mask)
	shot.launch_projectile()
	return shot

## Launches already charging/charged shot if knocked back
## @experimental: Might do something or another with the _direction argument at some point
func _on_hurt_box_component_knocked_back(_direction: Vector3) -> void:
	if !_charging_status == ActorEnums.charging.not_charging:
		complete_shot()

## Updates what the projectile can hit
## @experimental: I think I need to change this such that it updates the hitbox
func update_projectile_collision_layer(layer: int) -> int:
	_projectile_collision_layer = layer
	return _projectile_collision_layer

## Updates what can hit the projectile
## @experimental: I think I need to change this such that it updates the hurtbox
func update_projectile_collision_mask(layer: int) -> int:
	_projectile_collision_mask = layer
	return _projectile_collision_mask

func _handle_discharge() -> bool:
	var input_str: String = "vehicle_shoot" if PlayerManager.character is VehicleCharacter else "on_foot_shoot"
	if not Input.is_action_pressed(input_str):
		complete_shot()
		_force_lock_off(true)
		return true
	return false

## Only runs when a shot is charging/charged
func _process(delta: float) -> void:
	if not is_instance_valid(_target):
		_target = null
	if _handle_discharge():
		return
	if _charging_status == ActorEnums.charging.charged and not _target:
		_lock_on()
	elif !_charging_status == ActorEnums.charging.charged:
		_force_lock_off(true)
	_handle_charging(delta)

## Launches a shot, repleacing the temporary charging shot with a new active one
func complete_shot() -> Projectile:
	if not _temp_charging_shot:
		start_shot()
	#else:
		#Utils.print("temporary shot object already existed")
	var shot = _setup_shot()
	_charge_hold.paused = true
	_temp_charging_shot = null
	_charging_status = ActorEnums.charging.not_charging
	shot_fired.emit()
	set_process(false)
	return shot

## Starts the charging sequence
func start_shot() -> void:
	set_process(true)
	_charge_hold.start(_charge_time)
	_charging_status = ActorEnums.charging.is_charging
	_charge_hold.paused = false
	_temp_charging_shot = _projectile_packed_scene.instantiate()
	add_child(_temp_charging_shot)

func shoot_smart_bomb(): # TODO
	if PlayerManager.character is FlyingVehicleCharacter:
		pass # do one thing
	elif PlayerManager.character is GroundedVehicleCharacter:
		pass # do some other thing
	elif PlayerManager.character is OnFootCharacter:
		pass # do another thing still
	else:
		assert(false, "Nothing other than the playable characters should be shooting bombs")
	
## Returns the current target locked on to
func get_current_target() -> Node3D:
	if is_instance_valid(_target):
		_was_locked_on = true
		return _target
	else: return null

func get_charging_status():
	return _charging_status

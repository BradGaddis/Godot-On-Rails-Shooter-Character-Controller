class_name Projectile extends RigidBody3D
## The "Projectile" class 
## 
## This projectile class handles whether or not it it hit a target, and what the target it hit was. It handles the meshes and collision info. You need only instantiate it and point it in a direction

## Referecne to the hitbox component
@onready var _hitbox: HitBoxComponent = get_node_or_null("%HitBoxComponent")

@export var _damage_curve: Curve
## How far the projectile can travel before dieing 
var _shot_range: float = 50
## The speed the projectile will move at
var _shot_speed: float = 100
## The direction to launch at
var _launch_direction: Vector3 = Vector3.FORWARD
## Cached initial position
var _initial_position: Vector3 = Vector3.ZERO
## The velocity at which the pojectile should fall off at
var _tapered_velocity: bool
## The amount of damage this projectile wil do
var _base_damage: float = 5:
	set(val):
		_base_damage = max(0, val)
		
var _damage: float = _base_damage
## Typically used when charging
var launch: bool 
## Emited when died
signal died

## Registers process and starts audio
#func _ready():
	#AudioManager.create_3d_audio_at_location(Enums.SFX_TYPE.SHOT_FIRED, self)

## Handles logic when hitting something. Prints it out
func _on_hit_something(something: Node):
	print("Dying because I hit %s" % something)
	died.emit()
	queue_free()
		
## Updates the colliision layer
func update_collision_layer(layer: int):
	_hitbox.collision_layer = layer

## Updates the collision mask
func update_collision_mask(layer: int):
	_hitbox.collision_mask = layer
		
## Handles launching and collisions
func _physics_process(delta: float) -> void:
	if not launch: return;
	_damage = _base_damage * _damage_curve.sample(_distance_traveled()/_shot_range)
	var collision = move_and_collide(_launch_direction * delta * (_shot_speed if not _tapered_velocity else _shot_speed * delta))
	if collision:
		queue_free()
	_kill_self_on_distance()

## Toggles the launch flag
func launch_projectile():
	launch = true

## Sets the initial position
func set_initial_position(pos: Vector3):
	_initial_position = pos

## Updates the speed of the projectile
func set_shot_speed(amount: float) -> void:
	_shot_speed = amount

## Updates the range of how far the projectile can travel before dying
func set_shot_range(amount: float) -> void:
	_shot_range = amount

## Sets the amount of damage the projectile can dole
func set_damage(amount: float):
	_base_damage = amount
	
## Returns the amount of damage that the projectile can dole out
func get_damage():
	return _damage

## Updates the direction that the projectile will launch in
func set_launch_direction(dir: Vector3 = Vector3.FORWARD) -> void:
	_launch_direction = dir
	
## Updates the velocity taper
func set_tapered_velocity(tapered: bool):
	_tapered_velocity = tapered

func _distance_traveled() -> float:
	return abs(_initial_position.distance_to(global_position))

## Handles the logic for dying after traveling a certain distance
func _kill_self_on_distance():
	var distance = _initial_position.distance_to(position)
	if distance >= _shot_range:
		queue_free()
		died.emit()
		

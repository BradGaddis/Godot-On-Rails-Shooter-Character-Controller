@abstract
class_name Actor extends CharacterBody3D
## The base Actor class (ex. enemies and playable characters)

#region Properties
## Emited when the mode of this Actor is changed

	#region signal properties
signal mode_changed(current_mode: ActorEnums.mode, next_mode: ActorEnums.mode)
## Emited when status of the Actor is changed

signal status_changed(type: ActorEnums.status)
## The effective movement speed while the Actor is on rails
	#endregion

@export var _rail_speed: float = 40.0

@export var _forward_speed: float = 40.0

## The current mode the Actor is in
@export var _mode : ActorEnums.mode = ActorEnums.mode.on_rails:
	set(val):
		if val == _mode:
				return
		mode_changed.emit(_mode, val)
		_mode = val
		update_parent(_mode)
		return _mode

## How "heavy" this character is
@export var _mass: float = 1

## Flag determines if the actor should be propelled on rails of freely in the forward motion
@export var move_flag = false

## The current status of the enemy (ex. Alive/Dead)
var status: ActorEnums.status = ActorEnums.status.neutral:
	set(val): status = val; status_changed.emit(status)

## The gravity which the character can fall at. Typically only used for rail mode on death
var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _cached_parent: Node

@export_group("Additional Components")
	#region component properties
## Reference to the rails path components
@export var _rails_component: RailComponent

## The visible mesh
## @experimental: I have also have this defined in the vehicle component. May remove
var visible_body : Node3D 

## Reference to the shooting component
var shooting_component: ShootingComponent

## Reference to the state machine component
var state_machine_component: StateMachineComponent

## Reference to the health component
var health_component: HealthComponent

## Reference to the death component
var death_component: DeathComponent

## Reference to the hurt box component
var _hurt_box: HurtBoxComponent

## Reference to the hit box component
var _hit_box: HitBoxComponent

## Reference to the animation component
var animation_component: AnimationPlayer

	#endregion
#endregion

## Assigns component variables and registeres processes
func _ready() -> void:
	shooting_component = get_node_or_null("%ShootingComponent")
	state_machine_component = get_node_or_null("%StateMachine")
	health_component = get_node_or_null("%HealthComponent")
	death_component = get_node_or_null("%DeathComponent")
	_hit_box = get_node_or_null("%HitBoxComponent")
	_hurt_box = get_node_or_null("%HurtBoxComponent")
	visible_body = get_node_or_null("%VisibleBody")
	animation_component = get_node_or_null("AnimationPlayer")
	_cached_parent = self.get_parent()
	call_deferred("update_parent", _mode)

## Returns _rail_speed
func get_rail_speed() -> float:
	return _rail_speed

## Updates _rail_speed
func set_rail_speed(speed: float) -> void:
	_rail_speed = speed

func get_forward_speed() -> float:
	return _forward_speed

func set_forward_speed(speed: float) -> void:
	_forward_speed = speed
	
func update_mode(new_mode: ActorEnums.mode) -> void:
	_mode = new_mode

func get_mode() -> ActorEnums.mode:
	return _mode

func update_parent(mode: ActorEnums.mode):
	match mode:
		ActorEnums.mode.free:
			reparent(_cached_parent, true)
		ActorEnums.mode.on_rails:
			reparent(_rails_component.player_active_path_follow, true)

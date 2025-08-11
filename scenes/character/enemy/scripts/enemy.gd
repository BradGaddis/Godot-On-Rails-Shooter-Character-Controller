class_name Enemy extends Actor
## The Base Enemy Class

#region Parameters
## The speed at which this enemy moves
@export
var speed: float = 30

## How many points this enemy is worth
var points_worth_on_kill: float = 5

## A flag to determine if should move or not
var _is_moving : bool

## The rail path this Actor is following
var _rail_path: PathFollow3D
#endregion

## Sets up and assgings components, registers processes with the process manager
func _ready():
	super._ready()
	if death_component:
		death_component.died.connect(_on_died)
	if shooting_component:
		shooting_component.update_projectile_collision_layer(2**4 + 1)
		shooting_component.update_projectile_collision_mask(2**4 + 1)
	if _hurt_box:
		_hurt_box.collision_layer = 2**3
	set_rail_path(get_parent() as PathFollow3D)
	disabled_collison()
	collision_layer = 2**11

## Assigns to a different rail that the one currently assigned (Default is its child rail)
## @experimental
func assign_to_new_rail(rail_path: PathFollow3D, progress: float = 0):
	rail_path.add_child(self)
	self.set_rail_path(rail_path)
	print(self.name, " assigned to rail ", rail_path.name)
	_rail_path.progress_ratio = progress

## Disables collisions
func disabled_collison():
	collision_layer = 0

## Assigns a rail to follow
func set_rail_path(rail_path: PathFollow3D):
	_rail_path = rail_path

## Handles moving in modes
func physics_process(delta: float) -> void:
	#if _mode == ActorEnums.mode.free:
		#push_warning("We haven't implemented free mode yet")
	#if _mode == ActorEnums.mode.on_rails:
	if _is_moving:
		_move_on_rails(delta)

## Called when enemy dies
## @experimental: I don't think I have set this up
func _on_died():
	pass
	
## Moves along the path follow member
func _move_on_rails(delta):
	if not _rail_path:
		push_error("We can't move on rails if no rail path found")
		return
	_rail_path.progress += _rail_speed * delta

func set_moving(moving: bool):
	_is_moving = moving

class_name FlyingVehicleCharacter extends VehicleCharacter

var cached_collision_layers: int 

var cached_vehicle_collision_layers: int

func _ready() -> void:
	super._ready()
	cached_collision_layers = collision_layer
	cached_vehicle_collision_layers = vehicle_component.collision_layer
	mode_changed.connect(_on_mode_changed)
	if get_mode() == ActorEnums.mode.on_rails:
		vehicle_component.collision_layer = 0
	if get_mode() == ActorEnums.mode.free:
		collision_layer = 0
		
func get_dist_from_ground():
	# placeholder method
	pass
	
## @experimental 
## Handles moving while free-ranged and off-rails.
func _handle_rails_movement(delta: float):
	if _mode != ActorEnums.mode.on_rails:
		return
	
	vehicle_component.move(delta)
	if move_flag:
		_rails_component.player_active_path_follow.progress += delta * get_speed()
	
## @experimental 
## Handles moving while free-ranged and off-rails.
func _handle_free_movement(delta: float): 	
	if _mode != ActorEnums.mode.free:
		return
	_fly_forward(delta)
	
func _fly_forward(delta):
	if !reticle_component: return
	velocity = (Vector3.ONE * _forward_speed) * dir_to_reticle().rotated(Vector3.UP, rotation.y)
	_rotate_character_toward_reticle(delta, 5, 4, false)
	move_and_slide()

## The actions / events to take place when switch modes
func _on_mode_changed(prev_mode: ActorEnums.mode, next_mode: ActorEnums.mode):
	if next_mode == ActorEnums.mode.free:
		PlayerManager.enabled = false
		await vehicle_component.return_to_center(.05)
		PlayerManager.enabled = true
		collision_layer = 0
		cached_vehicle_collision_layers = vehicle_component.collision_layer
	if next_mode == ActorEnums.mode.on_rails:
		vehicle_component.collision_layer = 0
		collision_layer = cached_collision_layers

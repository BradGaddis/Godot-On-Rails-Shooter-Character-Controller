class_name FlyingVehicleCharacter extends VehicleCharacter



func _ready() -> void:
	super._ready()
	mode_changed.connect(_on_mode_changed)

func get_dist_from_ground():
	# placeholder method
	pass
	
## @experimental 
## Handles moving while free-ranged and off-rails.
func _free_movement(delta: float): 	
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

class_name FlyingVehicleCharacter extends VehicleCharacter

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

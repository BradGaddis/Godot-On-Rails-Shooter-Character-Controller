extends PlayerManagerState
## The flying vehicle state for the PlayerManager


func _input(event: InputEvent) -> void:
	if get_tree().paused || !PlayerManager.enabled:
		return
	if !PlayerManager.character or PlayerManager.character is not FlyingVehicleCharacter: return
	_handle_tilt_input_events(event)
	_handle_shooting_input_events(event, "vehicle_shoot")


func physics_update(delta: float):
	if not PlayerManager.character is FlyingVehicleCharacter:
		return
	_input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	_look_dir = Input.get_vector("look_left", "look_right", "look_down", "look_up")

	if PlayerManager.character.reticle_component:
		PlayerManager.character.reticle_component.move(delta, PlayerManager._input_dir) #TODO fix this private variable


func _handle_tilt_input_events(event: InputEvent):
	if PlayerManager.character is not VehicleCharacter: return
	if !PlayerManager.character.vehicle_component.bank_tilt_component: return
	if (Input.is_action_pressed("tilt") or (Input.is_action_pressed("roll") and Input.get_action_raw_strength("roll") < 0.75) and PlayerManager.character.vehicle_component.can_tilt):
		if PlayerManager.character.vehicle_component.get_action() == ActorEnums.bank_tilt_actions.flushing_rotation and \
		abs(PlayerManager.character.visible_body.rotation.z) > PlayerManager.character.vehicle_component.bank_tilt_component.flushed_rotation_epsilon:
			return
		PlayerManager.character.vehicle_component.set_action(ActorEnums.bank_tilt_actions.tilting)
	else:
		if !is_zero_approx(PlayerManager.character.visible_body.rotation.z):
			PlayerManager.character.vehicle_component.set_action(ActorEnums.bank_tilt_actions.flushing_rotation)
			return
		PlayerManager.character.vehicle_component.set_action(ActorEnums.bank_tilt_actions.no_action)
		return
	if Input.is_action_just_pressed("tilt"): # start double tap timer. Handled in roll state for now
		PlayerManager.character.vehicle_component.bank_tilt_component.set_tilt_timer()

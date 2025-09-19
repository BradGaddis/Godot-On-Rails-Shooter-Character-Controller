extends PlayerManagerState
## The on-foot state for the PlayerManager.


func _input(event: InputEvent) -> void:
	if !PlayerManager.character or PlayerManager.character is not OnFootCharacter: return
	if get_tree().paused || !PlayerManager.enabled:
		return
	_handle_camera_input_and_controls(event)
	_handle_shooting_input_events(event, "on_foot_shoot")


func _handle_jump_input(event: InputEvent):
	if event.is_action_pressed("jump") and PlayerManager.character.state_machine_component.current_state.name != "jump":
		PlayerManager.character.state_machine_component.current_state.change_to_state("jump")
	

func _handle_camera_input_and_controls(event: InputEvent):
	if event is InputEventMouseMotion:
		PlayerManager.character.camera_component.mouse_look_at_reticle(event)


func physics_update(delta: float):
	if not PlayerManager.character is OnFootCharacter:
		return
	_input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	_look_dir = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	PlayerManager.character.reticle_component.move(delta, _look_dir)
	PlayerManager.character.move(_input_dir)
	#character.camera_component.handle_foot_camera(delta, player_cam_mode, _target)

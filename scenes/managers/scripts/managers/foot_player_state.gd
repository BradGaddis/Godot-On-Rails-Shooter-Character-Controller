extends PlayerManagerState
## The on-foot state for the PlayerManager.
##
## TODO Check if works


func _input(event: InputEvent) -> void:
	if get_tree().paused || !PlayerManager.enabled:
		return
	if !PlayerManager.character or PlayerManager.character is not OnFootCharacter: return
	_handle_camera_input_and_controls(event)
	_handle_shooting_input_events(event, "on_foot_shoot")


func _handle_camera_input_and_controls(event: InputEvent):
	if event is InputEventMouseMotion:
		PlayerManager.character.camera_component.mouse_look_at_reticle(event)


func _handle_running():
	if PlayerManager.character is OnFootCharacter:
		if Input.is_action_pressed("run"):
			PlayerManager.character.update_speed(PlayerManager.character.run_speed)
			return
		PlayerManager.character.update_speed(PlayerManager.character.walk_speed)


func physics_update(delta: float):
	if not PlayerManager.character is OnFootCharacter:
		return
	_input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	_look_dir = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	_handle_running()
	PlayerManager.character.reticle_component.move(delta, PlayerManager._look_dir)
	#character.camera_component.handle_foot_camera(delta, player_cam_mode, _target)

extends State

#region Properties
## Force of jumping
const JUMP_VELOCITY = 4.5
#endregion


func state_process(delta) -> void:
	_handle_jump()


func _check_velocity():
	if PlayerManager.character.velocity.y >= 0:
		return
	change_to_state("fall")


func _handle_jump():
	if PlayerManager.character.is_on_floor():
		PlayerManager.character.velocity.y = JUMP_VELOCITY
		return
	_check_velocity()

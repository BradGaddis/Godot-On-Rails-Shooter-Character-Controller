extends State

#region Properties
## Force of jumping
const JUMP_VELOCITY = 4.5
var jumping: bool
#endregion


func enter(previous_state: String) -> void:
	_update_animation("jumping", true)


func exit(previous_state: String) -> void:
	_update_animation("jumping", false)


# TODO(brad) find a way to delay the jump until some frames have passed that works with this workflow
# short of just making it local and adding a method track, I don't know how I would do it.
func state_process(delta) -> void:
	_handle_jump()


func _check_velocity():
	if PlayerManager.get_velocity().y >= 0:
		return
	change_to_state("fall")


func _handle_jump():
	if PlayerManager.character.is_on_floor():
		PlayerManager.character.velocity.y = JUMP_VELOCITY
		return
	_check_velocity()

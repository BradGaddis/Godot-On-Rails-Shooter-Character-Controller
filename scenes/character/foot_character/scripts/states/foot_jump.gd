extends State

## Force of jumping
const JUMP_VELOCITY = 4.5

## Handles jumping #TODO refactor input into player manager
func jump():
	if Input.is_action_just_pressed("ui_accept") and PlayerManager.characgter.is_on_floor():
		PlayerManager.character.velocity.y = JUMP_VELOCITY

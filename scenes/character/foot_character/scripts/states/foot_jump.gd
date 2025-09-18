extends State

## Force of jumping
const JUMP_VELOCITY = 4.5

## Handles jumping #TODO refactor input into player manager
func jump():
	if Input.is_action_just_pressed("jump") and PlayerManager.character.is_on_floor():
		PlayerManager.character.velocity.y = JUMP_VELOCITY

func state_process(delta) -> void:
	jump()

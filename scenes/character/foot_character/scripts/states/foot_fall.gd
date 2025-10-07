extends State

## Force of jumping
const JUMP_VELOCITY = 4.5

func state_process(delta) -> void:
	_handle_fall()
	
	
func _handle_fall():
	if !PlayerManager.character.is_on_floor():
		return
	if PlayerManager.get_input_dir():
		change_to_state("move")
		return
	change_to_state("idle")
	

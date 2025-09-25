extends State


func enter(previous_state: String) -> void:
	_update_animation("idling", true)


func exit(previous_state: String) -> void:
	_update_animation("idling", false)


func state_physics_process(_delta) -> void:
	if PlayerManager.get_input_dir() != Vector2.ZERO or PlayerManager.get_velocity() != Vector3.ZERO:
		PlayerManager.character.state_machine_component.current_state.change_to_state("move")
		return

	if !PlayerManager.character.is_on_floor():
		change_to_state("fall")
	
	if Input.is_action_pressed("jump") and PlayerManager.character.is_on_floor():
		change_to_state("jump")
		return

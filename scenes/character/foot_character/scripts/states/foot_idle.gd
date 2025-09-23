extends State


func enter(previous_state: String) -> void:
	_update_animation("idling", true)


func exit(previous_state: String) -> void:
	_update_animation("idling", false)


func state_physics_process(_delta) -> void:
	if Input.is_action_pressed("jump"):
		change_to_state("jump")

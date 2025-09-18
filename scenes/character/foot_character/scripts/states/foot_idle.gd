extends State

func state_physics_process(_delta) -> void:
	if Input.is_action_pressed("jump"):
		change_to_state("jump")

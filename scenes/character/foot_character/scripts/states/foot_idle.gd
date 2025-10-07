class_name CharacterFootIdleState extends State

@export var _speed_degredation: float = 10;

func enter(_previous_state: State) -> void:
	_update_animation("idling", true)


func exit(_previous_state: State) -> void:
	_update_animation("idling", false)


func state_physics_process(delta) -> void:
	_decrement_velocity_to_zero(_actor.velocity, delta * _speed_degredation)
	if \
	_actor.is_on_floor() and\
	(PlayerManager.get_input_dir() != Vector2.ZERO):
		_actor.state_machine_component.current_state.change_to_state("move")
		return

	if !_actor.is_on_floor():
		change_to_state("fall")
		return
	
	if Input.is_action_pressed("jump") and _actor.is_on_floor():
		change_to_state("jump")
		return

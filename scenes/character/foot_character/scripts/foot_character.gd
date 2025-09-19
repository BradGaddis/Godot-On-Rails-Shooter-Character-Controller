class_name OnFootCharacter extends Character
## The base class for being on-foot

#region Properties
## Reference to the camrera component
@onready var _camera_component : CameraComponent = %CameraComponent


## The amount of velocity to gain before fall damage taken
@export var _fall_damage_threshold: float = -5

## Previous frame y velocity
var _last_y_velocity: float
#endregion


## Super and lock mouse
func _ready() -> void:
	super._ready()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _detect_fall_damage():
	if is_on_floor() and _last_y_velocity < _fall_damage_threshold and is_on_floor():
		_hurt_box.take_damage(abs(_last_y_velocity))
	_last_y_velocity = velocity.y


#TODO refactor this to handle other states
func move(direction: Vector2):
	super.move(direction)
	if !is_on_floor() or state_machine_component.current_state.name == "move":
		return
	if direction != Vector2.ZERO or velocity != Vector3.ZERO:
		PlayerManager.character.state_machine_component.current_state.change_to_state("move")
		return


## Moves the character via the reticle and handles jumping
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta * _mass
	_detect_fall_damage()
	move_and_slide()
	if _mode == ActorEnums.mode.free:
		_rotate_character_toward_reticle(delta)

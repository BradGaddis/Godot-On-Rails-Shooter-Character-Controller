extends State

#region Properties
## Force of jumping
const JUMP_VELOCITY = 4.5
var jumping: bool
var _sound_was_played: bool

## the time in the animation that we expect to leave the ground
@export var _launch_percent : float = 0.5;
#endregion


func enter(previous_state: State) -> void:
	_update_animation("jumping", true)


func exit(previous_state: State) -> void:
	_update_animation("jumping", false)
	_sound_was_played = false;


# TODO(brad): rework the language here and find the exact frame I want to do this on
func state_process(delta) -> void:
	var anspb: AnimationNodeStateMachinePlayback = PlayerManager.character.animation_component["parameters/playback"]
	var c = anspb.get_current_play_position()
	if c < _launch_percent:
		return
	
	#TODO play the sound resource
	if (!_sound_was_played):
		AudioManager.create_3d_audio_at_location(Enums.SFX_TYPE.DEFAULT_PLAYER_JUMP, _actor)
		_sound_was_played = true
	_handle_jump()


func _check_velocity():
	if _actor.velocity.y >= 0:
		return
	change_to_state("fall")


func _handle_jump():
	if PlayerManager.character.is_on_floor():
		PlayerManager.character.velocity.y = JUMP_VELOCITY
		return
	_check_velocity()

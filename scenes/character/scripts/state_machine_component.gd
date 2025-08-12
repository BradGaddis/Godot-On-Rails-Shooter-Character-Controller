class_name StateMachineComponent extends Node
## Manages the current state, facitates logic between states
## 
## Collects child states and manages the logic that should happen when a state enters being active or inactive (enter and exit)

@export var _player: Character

## The active state
@export var current_state: State:
	set(val):
		@warning_ignore("incompatible_ternary")
		print("State was updated from %s to %s" % [current_state.name if current_state != null else "", val.name])
		current_state = val;
## A reference to the previous state we were in.
var previous_state: String
## Set when the energy thrusters active timer exits early or times out
var _cool_time: float
## The time on the active time (as in when the timer is running out)
var _active_time: float
## Stores the states that are of the children of this node
var _states : Dictionary[String, State] = {} # not sure if this will be necessary as I have it currently written. Maybe for someone referrencing me
## Timer for GUI progress meter for active thrusters
var energy_timer_active: Timer 
## Timer for GUI progress meter for cooling thrusters
var energy_timer_cooldown: Timer
## Represents the enegy remaining on come states (such as boost and breaks)
var energy_thrusters: ActorEnums.thrust = ActorEnums.thrust.full

## Sets up states from children and connects their signals.[br]
## Assigns timers and cooldown time
func _ready() -> void:
	for child in get_children():
		if child is State:
			_states[child.name] = child
			print("Adding %s to states" % child.name)
			_set_signal(child)
	energy_timer_active = get_node_or_null("EnergyTimerActive")
	energy_timer_cooldown = get_node_or_null("EnergyTimerCooldown")

## Process the current states update
func _process(delta: float) -> void:
	current_state.state_process(delta)

## Process the current states physics update
func _physics_process(delta: float) -> void:
	current_state.state_physics_process(delta)
	
## Called when a state has transitioned on a per-state basis
func _on_state_transitioned(incoming_state: State, next_state: String):
	assert(incoming_state != _states[next_state], "Looks like you are trying to transition from a state to the same state")
	current_state.exit(next_state)
	previous_state = current_state.name
	current_state = _states[next_state]
	current_state.enter(previous_state)
	
## Connects the transition signal of a state
func _set_signal(child: State):
	child.connect("transitioned", _on_state_transitioned)

## Returns how full the energy gauge should be at any given time
func get_energy_guage_amount() -> float:
	if PlayerManager.character.state_machine_component.energy_thrusters == ActorEnums.thrust.full:
		return 1
	_active_time = energy_timer_active.time_left / energy_timer_active.wait_time
	_cool_time = 1 - (energy_timer_cooldown.time_left / energy_timer_cooldown.wait_time)
	_cool_time = 0.0 if _cool_time == 1.0 else _cool_time
	return max(_active_time, _cool_time)

#region shared functionality: 
func _on_energy_timer_cooldown_timeout() -> void:
	_player.character.state_machine_component.energy_thrusters = ActorEnums.thrust.full
	energy_timer_active.stop()
	
func _on_energy_timer_active_timeout() -> void:
	_player.character.state_machine_component.energy_thrusters = ActorEnums.thrust.cooling
	if energy_timer_cooldown.is_stopped():
		energy_timer_cooldown.start()
#endregion

class_name FlyingVehicleState extends State
## parent class for flying vehicle states
##
## Contains the basic needs for all flying vehicles


## Reference to the vehcile component of the vehicle character node
@onready var _vehicle_component: VehicleComponent

## A tween to transition properties between states
@onready var transition_tweener: Tween

## The time it will take to tween transitions between states
@warning_ignore("unused_private_class_variable") @export var _transition_time = .25

## A timer for how long a state can stay active
@onready var _duration_timer: Timer

## A timer to how long it will be before a state can be entered
@onready var cooldown_timer: Timer
## The initial speed cached when entering a new state
@warning_ignore("unused_private_class_variable") var _initial_flight_speed: float 
@warning_ignore("unused_private_class_variable") var _exit_flight_speed: float 

## Cached value for wether or not the xplane actually did roll or not
var _did_roll: bool = false

## Assigns values to component and timer members 
func _ready() -> void:
	super._ready()
	_vehicle_component = get_node_or_null("%VehicleComponent")
	_duration_timer = get_node_or_null("DurationTimer")
	cooldown_timer = get_node_or_null("CooldownTimer")
	

## Transition from the current state to the fly state
func switch_to_flight_state():
	transitioned.emit(self, "fly")

## Transition from the current state to the boost state
func switch_to_boost_state():
	change_input_state("boost")

## Transition from the current state to the break state
func switch_to_break_state():
	change_input_state("break")

## Transition from the current state to the roll state
func switch_to_roll_state():
	var roll: String = "roll";
	if not Input.is_action_pressed("roll"):
		_did_roll = false
		return
	if _did_roll: return
	if Input.get_action_raw_strength(roll) < .9:
		return
	if Input.is_action_pressed("roll"):
		_did_roll = true
		transitioned.emit(self, roll)
		return

## Transition from the current state to the loop state
func switch_to_somersault_state():
	change_input_state("somersault")

## Tweens a property on entering or exiting via arguments
func _tween_transition(node: Node, property: String, amount: float, time: float, type = Tween.EASE_OUT) -> Signal:
	transition_tweener = CharacterUtils.kill_and_create_tween(transition_tweener)
	transition_tweener.set_ease(type).tween_property(node, property, amount, time)
	return transition_tweener.finished
	
## Starts Active Timer and switch enum
func _start_thrusters(start_time: float = 2):
	PlayerManager.character.state_machine_component.energy_thrusters = ActorEnums.thrust.active
	PlayerManager.character.state_machine_component.energy_timer_active.wait_time = start_time
	PlayerManager.character.state_machine_component.energy_timer_active.start()

## Starts Cooldown Timer and switch enum
func _stop_thrusters():
	PlayerManager.character.state_machine_component.energy_thrusters = ActorEnums.thrust.cooling
	PlayerManager.character.state_machine_component.energy_timer_cooldown.start()

class_name HealthComponent extends Node
## Gives health functionality to a node
##
## This class exists purely to facity how health is handled.
## This node might not work as expected unless it is a direct child of the intended node.

## Emited when the value of health (as a percentage) has changed
signal health_changed(percent_health: float)

#region Properties
## Reference to death component[br]
## This class might not be particularly useful if death component is not a assigned.
## Assigned a value in _ready()

## The parent of this class in which it is assigned
@onready var _actor := owner as Actor

#TODO(Brad) Make this into a resource that can be reference from a dictionary by type?
## The maximum amount of health this component can have
@export var max_health: float = 5
#endregion


func _get_configuration_warnings() -> PackedStringArray:
	var output: PackedStringArray
	if _actor is not Actor:
		output.append("The parent of this node must be an Actor")
	return output


## The current value of health this node has
var _current_health: float = max_health:
	set(val):
		if !_actor:
			return
		var current_state: State = _actor.get_current_state();
			 #NOTE: Don't do anything. You're already dead.
		if current_state and current_state.name == "death": return;
		if val != _current_health:
			_current_health = clamp(val, 0, max_health)
			health_changed.emit(clamp(_current_health/max_health, 0, 1))
			#TODO(brad) Think about how this might not be the case if you need to postpone death for a little bit?
			# Maybe it can be handled in the death state itself
		if _current_health <= 0:
			_actor.update_current_state("death")

#TODO account for defense
## Reduces this node's [member _current_health]
func reduce_health(amount:float):
	_current_health -= amount


## Increases this node's [member _current_health]
func increase_health(amount:float):
	_current_health += amount


## Sets [member _current_health] to [member max_health].
## @experimental: This will later load the health from the file system
## Finds and sets the death component
func _ready() -> void:
	#TODO(brad) change this to be a loaded value later
	_current_health = max_health
	#assert(_death_component)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

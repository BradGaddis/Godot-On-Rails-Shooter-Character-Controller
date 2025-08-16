@tool
class_name HealthComponent extends Node
## Gives health functionality to a node
##
## This class exists purely to facity how health is handled.
## This node might not work as expected unless it is a direct child of the intended node.

## Emited when the value of health (as a percentage) has changed
signal health_changed(percent_health: float)

## Reference to death component[br]
## This class might not be particularly useful if death component is not a assigned.
## Assigned a value in _ready()
@onready var _death_component: DeathComponent = get_node_or_null("%DeathComponent")

## The parent of this class in which it is assigned
@onready var _parent: Actor = owner

## The maximum amount of health this component can have
@export var max_health: float = 5


func _get_configuration_warnings() -> PackedStringArray:
	var output: PackedStringArray
	if owner is not Actor:
		output.append("The owner of this scene must be an Actor")
	return output

## The current value of health this node has
var _current_health: float = max_health:
	set(val):
		if val != _current_health:
			_current_health = val
			_current_health = clamp(_current_health, 0, max_health)
			health_changed.emit(clamp(_current_health/max_health, 0, 1))
		if _current_health <= 0:
			_death_component.start_death_sequence(_parent)

## Sets [member _current_health] to [member max_health].
## @experimental: This will later load the health from the file system
## Finds and sets the death component
func _ready() -> void:
	_current_health = max_health
	assert(_death_component)
	
## Reduces this node's [member _current_health]
func reduce_health(amount:float):
	_current_health -= amount

## Increases this node's [member _current_health]
func increase_health(amount:float):
	_current_health += amount

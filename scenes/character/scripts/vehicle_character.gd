class_name VehicleCharacter extends Character
## The Character logic if the character is vehicle

## Reference to child vehicle component. Set in [method _ready] because this is picked up by child classes
var vehicle_component: VehicleComponent

## Sets inherited visible body and vehicle component[br]
## Reminder to Self: Don't register processes here
func _ready() -> void:
	super._ready()
	vehicle_component = get_node_or_null("%VehicleComponent")

## Tracks the status of this vehicile component
## and processes the statemachine physics_process Method
func _physics_process(delta: float) -> void:
	if status == ActorEnums.status.dead:
		vehicle_component.position.y -= _gravity * delta * _mass
		return
	_free_movement(delta)
	_rails_movement(delta)
	
## @experimental 
## Handles moving while free-ranged and off-rails.
func _free_movement(delta: float):
	pass

## @experimental 
## Handles moving while free-ranged and off-rails.
func _rails_movement(delta: float):
	if _mode != ActorEnums.mode.on_rails:
		return
	vehicle_component.move(delta)

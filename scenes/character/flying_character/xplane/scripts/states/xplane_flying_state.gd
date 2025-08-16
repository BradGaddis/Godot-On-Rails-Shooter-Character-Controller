class_name XplaneFlyingState extends FlyingVehicleState
## Handles the flying state logic
##
## @experimental: Wobbling to be added while in flight state

## Just calls the super
func _ready() -> void:
	super._ready()

## Checks if thrusters are full and switches to break/boost, or roll, or loop states
func state_physics_process(_delta) -> void:
	if PlayerManager.character.state_machine_component.energy_thrusters == ActorEnums.thrust.full:
		switch_to_boost_state()
		switch_to_break_state()
		
	if PlayerManager.character.vehicle_component.bank_tilt_component and Input.is_action_just_released("tilt") and PlayerManager.character.vehicle_component.bank_tilt_component.tilt_time_left():
		transitioned.emit(self, "roll")
	
	switch_to_roll_state()
	switch_to_somersault_state()

## @experimental: Not implemented yet. Might remove entirely TODO
func _on_wobble_timer_timeout() -> void:
	await get_tree().create_timer(.1).timeout

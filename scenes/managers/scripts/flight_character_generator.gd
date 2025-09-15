@tool
class_name RaigonFlightCharacterGenerator extends RaigonCharacterGenerator

func _new_character():
	_character = FlyingVehicleCharacter.new()
	super._new_character()
	add_state_machine(_character)

func _add_custom_component(component):
	var new_comp = super._add_custom_component(component)
	handle_add_vehicle_component(new_comp)


func handle_add_vehicle_component(component):
	if not component is VehicleComponent:
		return
	var pivot_point: Marker3D = Marker3D.new()
	component.add_child(pivot_point, true)
	pivot_point.name = "PivotPoint"
	pivot_point.owner = component.owner
	var visible_body = load("uid://t6w85w1vlrrv").instantiate()
	visible_body.name = "VisibleBody"
	pivot_point.add_child(visible_body)
	visible_body.set_unique_name_in_owner(true)
	visible_body.owner = component.owner

func add_state_machine(_character):
	var state_machine_component: StateMachineComponent = load("uid://c7q83nsp2wsbn").instantiate()
	state_machine_component.name = "StateMachine"
	_character.add_child(state_machine_component)
	state_machine_component.owner = _character
	state_machine_component.set_unique_name_in_owner(true)
	
	

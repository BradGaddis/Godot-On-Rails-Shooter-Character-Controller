@tool
class_name RaigonGroundCharacterGenerator extends RaigonVehicleCharacterGenerator

func _new_character():
	_character = GroundedVehicleCharacter.new()
	super._new_character()

func _add_custom_component(component):
	var new_comp = super._add_custom_component(component)
	handle_add_vehicle_component(new_comp)


func handle_add_vehicle_component(component):
	if not component is VehicleComponent:
		return
	pass

	
	

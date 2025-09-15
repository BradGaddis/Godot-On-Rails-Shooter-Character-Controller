extends PlayerManagerState
## The default state for the player Manager

var _did_warn: bool 

func update(delta: float):
	if not PlayerManager.character is FlyingVehicleCharacter:
		return

	if PlayerManager.character.reticle_component:
		PlayerManager.character.reticle_component.move(delta, PlayerManager._input_dir) #TODO fix this private variable

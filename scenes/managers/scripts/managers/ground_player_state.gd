extends PlayerManagerState
## The ground vehicle state for the player Manager


func physics_update(_delta: float):
	if get_tree().paused || !PlayerManager.enabled:
		return
	if not PlayerManager.character is GroundedVehicleCharacter:
		return

extends PlayerManagerState
## The default state for the player Manager

var _did_warn: bool 

func update(_delta: float):
	if !_did_warn:
		push_error("No state assigned. Please add some to the children of the PlayerManager scene")
		_did_warn = true

class_name CharacterHelperFunctionUtils extends Node
## An autoloaded script that I just have do that I don't have to keep typing the same methods over and over again

## Destroys a tween and returns a new one
func kill_and_create_tween(tween: Tween) -> Tween:
	kill_tween(tween)
	return create_tween()

## Kills a tween
func kill_tween(tween: Tween) -> void:
	if tween and tween.is_running():
		tween.kill()

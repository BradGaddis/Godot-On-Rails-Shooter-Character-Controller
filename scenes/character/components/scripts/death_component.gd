class_name DeathComponent extends Node
## Gives death functionality to a parent node
## 
## @experimental
## This node might not work as intended when not a direct child of a node
## This component fits squarly in the experimental stage of things. It's far from complete

## The parent of this object
@onready var parent = get_parent()

## Emits when the parent node has died
signal died


## Handles the sequences of steps that need to be taken when the parent node dies
## @experimental: Not complete
func die() -> Signal:
	died.emit()
	if parent is Character:
		pass
	else:
		parent.queue_free()
	return died

## @experimental: Not complete
func disable_parent() -> void:
	printerr(str(get_stack()[0]["function"]) + " Not implemented")

## @experimental: Not complete
## Kicks off the chain of events that need to happen when the parent node dies
func start_death_sequence(node: Actor = parent) -> void:
	node.status = ActorEnums.status.dead
	match node.get_mode():
		ActorEnums.mode.on_rails:
			await _on_rails_death_sequence()
		ActorEnums.mode.free:
			printerr(str(get_stack()[0]["function"]) + " Not implemented")
			die()
		_:
			die()

## @experimental: Not complete
func _on_rails_death_sequence() -> void:
	if not parent is Actor:
		return
	parent.update_mode(ActorEnums.mode.free)
	var animation_node: AnimationPlayer = get_node_or_null("AnimationNode") 
	if animation_node:
		animation_node.play("rail_falling_death")
		await animation_node.animation_finished
	else:
		printerr(str(get_stack()[0]["function"]) + " Not complete")
		# fall with velocity in-tact
		# explode on collision
		die()

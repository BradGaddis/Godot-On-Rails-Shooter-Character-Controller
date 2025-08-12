class_name HurtBoxComponent extends Area3D
## An area for taking damage
## 
## Exists for the purpose of taking damage from a hitbox and changing health values at [member HealthComponent._current_health].

## Emitted when the owner/parent node takes damage
signal took_damage(damage_amount)
## Emitted when the owner/parent node was knocked back
signal knocked_back(direction: Vector3)

## A body to be knocked around
@export var _knockable_body: Node3D

## Reference to the heath component
@onready var _health_component: HealthComponent = get_node_or_null("%HealthComponent")
## Reference to the reticle component
@onready var _reticle_component: ReticleComponent = get_node_or_null("%ReticleComponent")
## Time a node can be stunned in while being knocked around
@export var _knock_back_time: float = .5

## Used to change collision layers when decided that some other hitbox can hurt us
func update_collsiion_layer(new_val: int) -> void:
	collision_layer = new_val

## Recudes health and knocks back node (if playable character)
func take_damage(amount: float= 5, other: Node3D = null, does_knock_back: bool = false) -> Signal:
	_health_component.reduce_health(amount)
	if does_knock_back:
		_knock_back(_knockable_body, other)
	took_damage.emit(amount)
	return took_damage
	
## When knocked back, moves reticle back to the center of the screen
func _align_recticle_on_knock_back() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(_reticle_component, "position:x", 0, _knock_back_time)
	tween.parallel().tween_property(_reticle_component, "position:y", 0, _knock_back_time)
	
## Take a body to knock around, and a body to knock away from, and time to do it in.
## Aligns reticle to center of screen via [method _align_recticle_on_knock_back]
func _knock_back(knockee: Node3D = null, other: Node3D = null, amount: float = 3)  -> void:
	if not knockee or not other:
		return
	var direction: Vector3 = (other.global_position - knockee.global_position).normalized()
	knocked_back.emit(direction)
	var _vec2 = Vector2(direction.x, direction.y)
	PlayerManager.enabled = false
	var tween: Tween = get_tree().create_tween()
	_align_recticle_on_knock_back()
	await tween.parallel().tween_property(knockee, "position", knockee.position * direction * amount, _knock_back_time).finished
	PlayerManager.enabled = true

## Checks if area should take damage, print logs relevant info
func _on_area_entered(area: Area3D) -> void:
	if area.collision_layer == 1:
		take_damage(5, area, owner is Character)
		return

## Checks if body should take damage, print logs relevant info
func _on_body_entered(body: Node3D) -> void:
	if body.collision_layer == 1:
		take_damage(5, body, owner is Character)
		return

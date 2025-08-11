class_name HitBoxComponent extends Area3D
## An area for dealing damage
## 
## Exists for the purpose of dealing damage to a hurtbox

## The default damage this hitbox can dole out
@export var _damage_amount: float = 5

## Prints who's area this hit box hit, checks if they can take damage and gives it
func _on_area_entered(area: Area3D) -> void:
	print(owner.name, " area hit something: ", area.name, " from ", area.owner.name)
	if area.has_method("take_damage"):
		area.take_damage(_damage_amount, area)

## Prints who's body this hit box hit, checks if they can take damage and gives it
func _on_body_entered(body: Node3D) -> void:
	print(owner.name, " body hit ", body.name, " from ", body.owner.name)
	if body.has_method("take_damage"):
		body.take_damage(_damage_amount, body)

## Updates the collision layer that this object can deal damage to
func update_collision_layer(new_val: int) -> void:
	collision_layer = new_val

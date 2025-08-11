class_name PlayerCamera extends Camera3D

signal locked_on(target: Node3D)

## Should theoritically always be the parent of this object
@onready var _camera_component: CameraComponent = $".."
## Area 3D to look for a target to lock on to in
@onready var _target_area: Area3D = $"../TargetArea"
## Used when looping over targets in the [member _visible_targets] array
var _current_target_distance: float
## Used when looping over targets in the [member _visible_targets] array
var _nearest_distance: float
## Used when looping over targets in the [member _visible_targets] array
var _nearest_target_index: float

## And array of visible targets
var _visible_targets: Array[Node3D] = []

var _shake_intensity: float

var _max_shake_amount: float

var _shake_timer: Timer


## Updates collision shape to be new shape if default isn't good enough
func _ready() -> void:
	#_camera_component = get_parent()
	var collision_shape : CollisionShape3D = _target_area.get_child(0)
	var c_shape : ConvexPolygonShape3D = _target_area.get_child(0).shape
	if _camera_component._line_of_sight_range:
		var new_c_shape: ConvexPolygonShape3D = ConvexPolygonShape3D.new()
		var updated_points : PackedVector3Array
		for point : Vector3 in c_shape.points:
			updated_points.append(
			 Vector3(point.x,point.y,_camera_component._line_of_sight_range)
			)
		new_c_shape.points = updated_points
		collision_shape.shape = new_c_shape

func _process(_delta: float) -> void:
	h_offset = _camera_component.h_offset
	v_offset = _camera_component.v_offset


## Returns the nearest target from the [member _visible_targets] array
func get_nearest_visible_target(current_target : Node3D = null, poximity_reference: Node3D = null):
	poximity_reference = self if !poximity_reference else poximity_reference
	if _visible_targets.size() == 0:
		return null
	_nearest_distance = INF
	_nearest_target_index = -1
	for i in _visible_targets.size():
		if _visible_targets[i] == current_target:
			continue
		_current_target_distance = poximity_reference.global_position.distance_squared_to(_visible_targets[i].global_position)
		if _current_target_distance < _nearest_distance:
			_nearest_distance = _current_target_distance
			_nearest_target_index = i
	if _nearest_target_index == -1:
		return null
	var target = _visible_targets[_nearest_target_index]
	locked_on.emit(target)
	return target

## Detects if a visible body should be added to the array
func _on_target_area_body_entered(body: Node3D) -> void:
	print(body, " entered visible range")
	_visible_targets.append(body)

## Detects if a visible body should be removed from the array
func _on_target_area_body_exited(body: Node3D) -> void:
	print(body, " exited visible range")
	_visible_targets.erase(body)

func shake(_delta) -> bool:
	if !_shake_timer.time_left > 0:
		return false
	var x = randf() * _shake_intensity
	var y = randf() * _shake_intensity
	position = Vector3(x, y, position.z)
	return true
	
func set_shake_factor(amount: float):
	_shake_intensity = amount

func get_max_shake_amount(amount: float):
	_max_shake_amount = amount

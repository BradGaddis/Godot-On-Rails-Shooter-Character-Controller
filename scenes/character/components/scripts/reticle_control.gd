extends Control


@onready var reticle_object: Marker3D = %ReticleObject
@onready var current_camera: Camera3D = get_tree().root.get_camera_3d()
@onready var _reticle_icon: Sprite2D = $ReticleIcon
var unprojected_reticle: Vector2
var screen_size: Vector2


func _physics_process(_delta: float) -> void:
	unprojected_reticle = current_camera.unproject_position(reticle_object.global_transform.origin)
	screen_size = get_viewport_rect().size
	#_reticle_icon.centered
	_reticle_icon.position = Vector2(
		screen_size.x / 2,
		screen_size.y / 2,
	)
	position.x = unprojected_reticle.x - screen_size.x / 2
	position.y = unprojected_reticle.y - screen_size.y / 2

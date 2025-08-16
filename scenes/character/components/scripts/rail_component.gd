class_name RailComponent extends Path3D

## Must be assigned for the player to move
@export var player_active_path_follow: PathFollow3D:
	get:
		assert(player_active_path_follow, "Must be assigned for the player to move if the player is on rails")
		return player_active_path_follow

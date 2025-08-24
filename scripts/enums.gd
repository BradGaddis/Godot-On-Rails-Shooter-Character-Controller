class_name ActorEnums extends Node
## Handles typing and simple states

## The mode that a vehicle can be in.
## This includes the player vehicle and enemy vehciles.
enum mode {
	on_rails,
	free
}

## Actions a Vehicle can take.
## This includes the player vehicle and enemy vehciles.
enum bank_tilt_actions { 
	no_action,
	tilting,
	flushing_rotation
}

## Wether or not a player or enemy is charging.
enum charging {
	not_charging,
	is_charging,
	fully_charged
}

enum max_gun_power {
	single,
	double,
	triple,
}

## A flag for what type of input the player is using.
enum active_controller_type {
	m_k,
	game_pad
}

## A flag for the current "living" status of a player or enemy.
enum status  {
	neutral, # nothing's happening with the player or vehicle is unmanned 
	flying,
	stopped,
	dead,
}

## The active state of player thrusters
enum thrust {
	active,
	cooling,
	full
}

## The type of the SFX (referes to a resource).
enum SFX_TYPE {
	DEFAULT,
	SHOT_FIRED
}

enum fov_mode {
	narrow,
	mid,
	widest,
	full,
	extended
}

enum game_state {
	STATE_STARTING,
	STATE_TITLE,
	STATE_PLAY,
	STATE_VERSUS,
	STATE_PAUSED,
	STATE_STANDBY,
	STATE_CLEAR_SCREEN,
	STATE_GAME_OVER,
	STATE_MAP,
}

enum player_state {
	STATE_ACTIVE,
	STATE_STANDBY,
}

enum lasers {
	single,
	twin,
	hyper,
}

enum planet_id {
	VEER
}

enum level_type {
	empty, # Only here so I can use it to assert that there's a type
	space,
	planet,
	water,
	land,
	under_water,
}

enum vehicle_wing_state {
	INTACT,
	BROKEN
}

enum cam_mode_view {
	rails,
	third_person,
	cockpit,
}

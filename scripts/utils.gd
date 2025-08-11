class_name CharacterHelperFunctionUtils extends Node
## An autoloaded script that I just have do that I don't have to keep typing the same methods over and over again

#TODO add GUI for this
var default_keyboard_input_map: Dictionary[String, Array] = {
	"move_forward"      :  [[KEY_W,     "key"], [JoyAxis.JOY_AXIS_LEFT_Y,       -1,  "JoyMotion"]],
	"move_right"        :  [[KEY_A,     "key"], [JoyAxis.JOY_AXIS_LEFT_X,       -1,  "JoyMotion"]],
	"move_left"         :  [[KEY_S,     "key"], [JoyAxis.JOY_AXIS_LEFT_X,        1,  "JoyMotion"]],
	"move_down"         :  [[KEY_D,     "key"], [JoyAxis.JOY_AXIS_LEFT_Y,        1,  "JoyMotion"]],
	"look_up"           :  [[KEY_UP,    "key"], [JoyAxis.JOY_AXIS_RIGHT_Y,      -1,  "JoyMotion"]],
	"look_right"        :  [[KEY_RIGHT, "key"], [JoyAxis.JOY_AXIS_RIGHT_X,      -1,  "JoyMotion"]],
	"look_left"         :  [[KEY_LEFT,  "key"], [JoyAxis.JOY_AXIS_RIGHT_X,       1,  "JoyMotion"]],
	"look_down"         :  [[KEY_DOWN,  "key"], [JoyAxis.JOY_AXIS_RIGHT_Y,       1,  "JoyMotion"]],
	"break"             :  [[KEY_Q,     "key"], [JOY_BUTTON_LEFT_SHOULDER,           "JoyButton"]],
	"boost"             :  [[KEY_E,     "key"], [JOY_BUTTON_RIGHT_SHOULDER,          "JoyButton"]],
	"tilt"              :  [[KEY_UP,    "key"], [JOY_BUTTON_LEFT_SHOULDER,           "JoyButton"]],
	"roll"              :  [[KEY_UP,    "key"], ],
	"somersault"        :  [[KEY_UP,    "key"], ],
	"uturn"             :  [[KEY_UP,    "key"], ],
	"vehicle_shoot"     :  [[KEY_UP,    "key"], ],
	"on_foot_shoot"     :  [[KEY_UP,    "key"], ],
	"run"               :  [[KEY_SHIFT, "key"], ],
	#"jump"             : [[KEY_UP, "key"]],
	}

## Destroys a tween and returns a new one
func kill_and_create_tween(tween: Tween) -> Tween:
	kill_tween(tween)
	return create_tween()

## Kills a tween
func kill_tween(tween: Tween) -> void:
	if tween and tween.is_running():
		tween.kill()

func update_default_inputs():
	for action_name in default_keyboard_input_map:
		if ProjectSettings.has_setting("input/" + action_name):
			continue
		var events: Array
		for key in default_keyboard_input_map[action_name]:
			var ev
			match key[-1].to_lower():
				"key":
					ev = InputEventKey.new()
					ev.physical_keycode = key[0]
			match key[-1].to_lower():
				"joymotion":
					ev = InputEventJoypadMotion.new()
					ev.axis = key[0]
					ev.axis_value = key[1]
			match key[-1].to_lower():
				"joybutton":
					ev = InputEventJoypadButton.new()
					ev.button_index = key[0]
			events.append(ev)
		ProjectSettings.set_setting("input/" + action_name, {"deadzone" : 0.5, "events" : events})
	
func erase_default_inputs(): #TODO
	#return 
	for action_name in default_keyboard_input_map:
		print(ProjectSettings.get_setting("input/" + action_name))
		#break	
		ProjectSettings.clear("input/" + action_name)

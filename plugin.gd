@tool
class_name RailCharacterController extends EditorPlugin

const UTILS_UID: String = "uid://3y2b13k824kj"

const PLAYER_MANAGER_UID: String = "uid://blm6rewq1r0ot"

const CHARACTER_UTILS_AUTOLOAD_NAME: String = "CharacterUtils"

const PLAYER_MANAGER_AUTOLOAD_NAME: String = "PlayerManager"

const PLUGIN_NAME: String = "rails_character_controller"



var DEPENDENT_PLUGINS: Array =\
# The order does matter
[
	SaveAndLoadPlugin, 
]


func _enable_plugin() -> void:
	for plugin in DEPENDENT_PLUGINS:
		var path = PLUGIN_NAME + "/" + plugin.PLUGIN_NAME + "/"
		if !EditorInterface.is_plugin_enabled(path):
			EditorInterface.set_plugin_enabled(path, true)
	add_autoload_singleton(CHARACTER_UTILS_AUTOLOAD_NAME, ResourceUID.uid_to_path(UTILS_UID))
	add_autoload_singleton(PLAYER_MANAGER_AUTOLOAD_NAME, ResourceUID.uid_to_path(PLAYER_MANAGER_UID))
	var temp_helper = CharacterHelperFunctionUtils.new()
	temp_helper.update_default_inputs()

func _disable_plugin() -> void:
	remove_autoload_singleton(CHARACTER_UTILS_AUTOLOAD_NAME)
	remove_autoload_singleton(PLAYER_MANAGER_AUTOLOAD_NAME)
	for plugin in DEPENDENT_PLUGINS:
		var path = PLUGIN_NAME + "/" + plugin.PLUGIN_NAME + "/"
		if EditorInterface.is_plugin_enabled(path):
			EditorInterface.set_plugin_enabled(path, false)
	var temp_helper = CharacterHelperFunctionUtils.new()
	temp_helper.erase_default_inputs()

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

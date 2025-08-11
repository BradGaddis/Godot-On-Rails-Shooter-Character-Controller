@tool
class_name RailCharacterController extends EditorPlugin

const UTILS_UID: String = "uid://3y2b13k824kj"
const AUTOLOAD_NAME: String = "CharacterUtils"
const PLUGIN_NAME: String = "rails_player.character_controller"
var DEPENDENT_PLUGINS: Array =\
# The order does matter
[
	SaveAndLoadPlugin, 
]

func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, ResourceUID.uid_to_path(UTILS_UID))
	for plugin in DEPENDENT_PLUGINS:
		var path = PLUGIN_NAME + "/" + plugin.PLUGIN_NAME + "/"
		if !EditorInterface.is_plugin_enabled(path):
			EditorInterface.set_plugin_enabled(path, true)

func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	for plugin in DEPENDENT_PLUGINS:
		var path = PLUGIN_NAME + "/" + plugin.PLUGIN_NAME + "/"
		if EditorInterface.is_plugin_enabled(path):
			EditorInterface.set_plugin_enabled(path, false)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

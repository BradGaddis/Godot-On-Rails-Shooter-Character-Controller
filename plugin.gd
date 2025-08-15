@tool
class_name RailCharacterController extends EditorPlugin

var DEPENDENT_PLUGINS: Array =\
# The order does matter
[
	SaveAndLoadPlugin, 
]

const MAIN_PANEL : PackedScene = preload("uid://bcio80vdajk2l")
	
const PLUGIN_NAME: String = "Raigon Char Creator"
const PLUGIN_PATH: String = "rails_character_controller"

const UTILS_UID: String = "uid://3y2b13k824kj"
const PLAYER_MANAGER_UID: String = "uid://blm6rewq1r0ot"
const CHARACTER_UTILS_AUTOLOAD_NAME: String = "CharacterUtils"
const PLAYER_MANAGER_AUTOLOAD_NAME: String = "PlayerManager"

const PLUGIN_ICON_PATH := "" #TODO

var editor_view: RaigonCharacterEditor  # the root of the character editor
var inspector_plugin: EditorInspectorPlugin = null



## Initialization
func _init() -> void:
	self.name = "RailgonCharCreator"

func _enable_plugin() -> void:
	for plugin in DEPENDENT_PLUGINS:
		var path = PLUGIN_PATH + "/" + plugin.PLUGIN_PATH + "/"
		if !EditorInterface.is_plugin_enabled(path):
			EditorInterface.set_plugin_enabled(path, true)
	add_autoload_singleton(CHARACTER_UTILS_AUTOLOAD_NAME, ResourceUID.uid_to_path(UTILS_UID))
	add_autoload_singleton(PLAYER_MANAGER_AUTOLOAD_NAME, ResourceUID.uid_to_path(PLAYER_MANAGER_UID))
	var temp_helper = CharacterHelperFunctionUtils.new() # TODO Change this
	temp_helper.update_default_inputs()
	

func _disable_plugin() -> void:
	remove_autoload_singleton(CHARACTER_UTILS_AUTOLOAD_NAME)
	remove_autoload_singleton(PLAYER_MANAGER_AUTOLOAD_NAME)
	for plugin in DEPENDENT_PLUGINS:
		var path = PLUGIN_PATH + "/" + plugin.PLUGIN_PATH + "/"
		if EditorInterface.is_plugin_enabled(path):
			EditorInterface.set_plugin_enabled(path, false)
	var temp_helper = CharacterHelperFunctionUtils.new()
	temp_helper.erase_default_inputs()

func _enter_tree() -> void:
	editor_view = MAIN_PANEL.instantiate()
	editor_view.plugin_reference = self
	editor_view.hide()
	get_editor_interface().get_editor_main_screen().add_child(editor_view)


func _exit_tree() -> void:
	if editor_view:
		remove_control_from_bottom_panel(editor_view)
		editor_view.queue_free()

	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)
	
func _has_main_screen() -> bool:
	return true

func _get_plugin_name() -> String:
	return PLUGIN_NAME
	
func _make_visible(visible:bool) -> void:
	if not editor_view:
		return

	if editor_view.get_parent() is Window:
		if visible:
			get_editor_interface().set_main_screen_editor("Script")
			editor_view.show()
			editor_view.get_parent().grab_focus()
	else:
		editor_view.visible = visible

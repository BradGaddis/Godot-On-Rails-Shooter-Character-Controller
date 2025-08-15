extends Control
## Shows the given editor


@onready var tabbar := $HSplit/VBox/Toolbar/EditorTabBar
@onready var editors_holder := $HSplit/VBox/Editors


## Information on supported resource extensions and registered editors
var current_editor: Control = null
var previous_editor: Control = null
var editors := {}

func _ready() -> void:
	tabbar.tab_clicked.connect(_on_editors_tab_changed)


func open_editor(editor:DialogicEditor, save_previous: bool = true, extra_info:Variant = null) -> void:
	#if current_editor and save_previous:
		#current_editor._save()
##
	#if current_editor:
		#current_editor._close()
		#current_editor.hide()

	if current_editor != previous_editor:
		previous_editor = current_editor

	editor._open(extra_info)
	editor.opened.emit()
	current_editor = editor
	editor.show()
	tabbar.current_tab = editor.get_index()
#
	#if editor.current_resource:
		#var text: String = editor.current_resource.resource_path.get_file()
		#if editor.current_resource_state == DialogicEditor.ResourceStates.UNSAVED:
			#text += "(*)"

	## This makes custom button editor-specific
	## I think it's better without.

	#save_current_state()
	#editor_changed.emit(previous_editor, current_editor)

func _on_editors_tab_changed(tab:int) -> void:
	open_editor(editors_holder.get_child(tab))

@tool
extends Control
## Shows the given editor


@onready var tabbar := %CharacterTabBar
@onready var editors_holder := %Editors
@onready var character_name: Label = %CharacterName
@onready var _character_generator: RaigonCharacterGenerator = RaigonCharacterGenerator.new()

var _character_name_input: String
var _save_path: String

## Information on supported resource extensions and registered editors
var current_editor: RaigonCharacterCreator = null
var previous_editor: RaigonCharacterCreator = null
var editors := {}

func _ready() -> void:
	tabbar.clear_tabs()
	tabbar.tab_clicked.connect(_on_editors_tab_changed)
	_add_editor("uid://cntoa2fm8hhj5", "Flight Character")
	open_editor(editors_holder.get_child(0))


func open_editor(editor: RaigonCharacterCreator, ...extra_info) -> void:
	if current_editor:
		editor._close(extra_info)
		current_editor.hide()

	if current_editor != previous_editor:
		previous_editor = current_editor

	editor._open(extra_info)
	editor.opened.emit()
	
	current_editor = editor
	editor.show()
	tabbar.current_tab = editor.get_index()


func _on_editors_tab_changed(tab:int) -> void:
	open_editor(editors_holder.get_child(tab))


func _add_editor(path:String, name: String) -> void:
	var editor: RaigonCharacterCreator = load(path).instantiate()
	#var scroll_container: ScrollContainer = ScrollContainer.new()
	editors_holder.add_child(editor)
	editor.hide()
	tabbar.add_tab(name)


func _on_save_button_pressed() -> void:
	if !_character_name_input:
		return
		
	_character_generator.create_character(
		tabbar.get_index(),
		_character_name_input,
		current_editor.components_to_add,
		_save_path
	)


func _on_character_line_edit_text_changed(new_text: String) -> void:
	_character_name_input = new_text
	character_name.text = _character_name_input


func _on_save_path_line_edit_text_changed(new_text: String) -> void:
	_save_path = new_text
	print(_save_path)

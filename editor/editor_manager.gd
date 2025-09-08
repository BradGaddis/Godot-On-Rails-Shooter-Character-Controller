@tool
extends Control
## Shows the given editor


@onready var tabbar := %CharacterTabBar
@onready var editors_holder := %Editors
@onready var character_name: Label = %CharacterName
@onready var _character_generator: RaigonCharacterGenerator = RaigonCharacterGenerator.new()
@onready var save_path_label: Label = %"Save Path Label"

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
	_add_editor("uid://c8iuoxtibah42", "Foot Character")
	_add_editor("uid://c04ppy7lo7rjb", "Ground Character")
	open_editor(editors_holder.get_child(0))
	add_child(_character_generator)


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
	editors_holder.add_child(editor)
	editor.hide()
	tabbar.add_tab(name)


func _on_save_button_pressed() -> void:
	if !_character_name_input:
		push_error("Try inputing a character name before saving")
		return
	match tabbar.current_tab:
		0:
			if _character_generator is not RaigonFlightCharacterGenerator:
				_character_generator.free()
				_character_generator = RaigonFlightCharacterGenerator.new()
				add_child(_character_generator)
		1: 
			if _character_generator is not RaigonFootCharacterGenerator:
				_character_generator.free()
				_character_generator = RaigonFootCharacterGenerator.new()
				add_child(_character_generator)
		2:
			if _character_generator is not RaigonGroundCharacterGenerator:
				_character_generator.free()
				_character_generator = RaigonGroundCharacterGenerator.new()
				add_child(_character_generator)
				
	_character_generator.create_character(
		_character_name_input,
		current_editor.components_to_add,
		_save_path
	)


func _on_character_line_edit_text_changed(new_text: String) -> void:
	_character_name_input =  "".join(new_text.capitalize().split((" ")))
	character_name.text = _character_name_input


func _on_save_path_line_edit_text_changed(new_text: String) -> void:
	_save_path = new_text
	var dir = DirAccess.open("res://")
	var try_path = "res://%s" % _save_path.to_snake_case()
	save_path_label.text = "Save Paths are relative to Res://\n"
	if dir.dir_exists(try_path):
		save_path_label.text += "Save path is a valid path."
	else:
		save_path_label.text += "Save Path Is not a valid path.\nOne will be created on save."

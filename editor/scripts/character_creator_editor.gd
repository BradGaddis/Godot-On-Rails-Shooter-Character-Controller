@tool
class_name RaigonCharacterCreator extends Control # TODO refactor into other creators


@onready var components: GridContainer = %Components
@onready var selected_label: Label = %SelectedLabel
@onready var editor_manager = get_parent().get_node_or_null("%EditorManager")
signal opened
signal closed

var available_components: Dictionary[String, CheckBox] 
var components_to_add: Array[String] 

func _ready() -> void:
	for child: CheckBox in find_children("*", "CheckBox", true):
		available_components[child.name] = child
		if child.toggle_mode == true:
			_add_comp(child)
		else:
			_remove_comp(child)
		child.toggled.connect(_on_button_toggled.bind(child))
		

func _open(...args):
	pass

func _close(...args):
	pass

func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		return
	if selected_label:
		selected_label.text = ""
		if !components_to_add.is_empty():
			components_to_add.sort()
			for key in components_to_add:
				selected_label.text += key + " "
	
func _on_button_toggled(toggled, button: CheckBox):
	if toggled:
		_add_comp(button)
	elif !toggled:
		_remove_comp(button)
		
func _add_comp(button: CheckBox):
	components_to_add.append(button.get_parent().get_parent().name)

func _remove_comp(button: CheckBox):
	components_to_add.erase(button.get_parent().get_parent().name)

@tool
class_name RaigonCharacterGenerator extends Node

var _character: Character

enum character_type {
	flying,
	foot,
	ground,
}


func create_character(char_type: character_type, character_name: String, components: Array[String]):
	character_name = "".join(character_name.capitalize().split((" ")))
	
	match char_type:
		0:
			_character = _character as FlyingVehicleCharacter
			_character = FlyingVehicleCharacter.new()
		1:
			_character = _character as GroundedVehicleCharacter
			_character = GroundedVehicleCharacter.new()
		2:
			_character = _character as OnFootCharacter
			_character = GroundedVehicleCharacter.new()
			
	_add_components(components)
	_character.name = character_name
	_save_character()

func _add_components(comps: Array):
	for comp: String in comps:
		var comp_path: String = "res://addons/rails_character_controller/scenes/character/components/scripts/"
		var dir = DirAccess.open(comp_path)
		comp = comp.to_snake_case().to_lower()
		comp_path += comp + ".gd"
		if dir.file_exists(comp_path):
			var new_comp: Node = load(comp_path).new()
			new_comp.name = "".join(comp.capitalize().split((" ")))
			_character.add_child(new_comp)
			new_comp.owner = _character
			new_comp.set_unique_name_in_owner(true)
			
	
func _save_character():
	var packed_scene = PackedScene.new()
	if packed_scene.pack(_character) == OK:
		var error = ResourceSaver.save(packed_scene, "res://%s.tscn" % _character.name.to_camel_case())
		if error != OK:
			push_error("Failed to save scene")

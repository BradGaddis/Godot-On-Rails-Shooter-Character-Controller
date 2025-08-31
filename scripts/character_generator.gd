@tool
class_name RaigonCharacterGenerator extends Node


@onready var ei: EditorFileSystem = EditorInterface.get_resource_filesystem()
var _character: Character
var generator_helper: RaigonCharacterGenerator


func _add_base_component(component_type, parent = _character):
	var component = component_type.new()
	parent.add_child(component, true)
	component.owner = _character


func _new_character():
	_add_base_component(CollisionShape3D)


func create_character(character_name: String, components: Array[String], save_path: String):
	character_name = "".join(character_name.capitalize().split((" ")))
	_new_character()
	_add_components(components)
	_character.name = character_name
	_save_character(save_path)


func _add_components(comps: Array):
	for comp: String in comps:
		_add_custom_component(comp)


func _add_custom_component(component):
	var comp_path: String = "res://addons/rails_character_controller/scenes/character/components/scripts/"
	var dir = DirAccess.open(comp_path)
	component = component.to_snake_case().to_lower()
	comp_path += component + ".gd"
	if dir.file_exists(comp_path):
		var new_comp: Node = load(comp_path).new()
		new_comp.name = "".join(component.capitalize().split((" ")))
		if _handle_add_instantiated_component(new_comp):
			return
		_character.add_child(new_comp)
		new_comp.owner = _character
		new_comp.set_unique_name_in_owner(true)
		_handle_component_is_rigid_body_3D(new_comp)
		return new_comp


func _handle_component_is_rigid_body_3D(component):
	if component is PhysicsBody3D:
		_add_base_component(CollisionShape3D, component)


func _save_character(save_path: String):
	save_path = _update_save_path(save_path)
	var packed_scene = PackedScene.new()
	var packed_scene_result = packed_scene.pack(_character)

	if packed_scene_result == OK:
		var error = ResourceSaver.save(packed_scene, save_path)
		if error != OK:
			push_error("Failed to save scene ", packed_scene_result)
			return
		ei.scan_sources()
		ei.update_file(save_path)
		EditorInterface.reload_scene_from_path(save_path)
		EditorInterface.open_scene_from_path(save_path)



func _update_save_path(save_path: String):
	var dir = DirAccess.open("res://")
	var try_path = "res://%s" % save_path.to_snake_case()
	if !dir.dir_exists(try_path):
		var dirs: PackedStringArray = save_path.split("/")
		var updated_dirs: String
		for d in dirs:
			updated_dirs += "/" + d
			dir.make_dir("res://" + updated_dirs)

	return (try_path + "%s.tscn" % _character.name.to_snake_case()).strip_edges()


func handle_add_vehicle_component(component):
	pass


func _handle_add_instantiated_component(component) -> bool:
	var instantiated_components = {
		"ReticleComponent" : "uid://teei5itjmbra",
		"CameraComponent" : "uid://r85abir0qcii"
		}

	if not component.name in instantiated_components:
		return false

	var inst_comp = load(instantiated_components[component.name]).instantiate()
	_character.add_child(inst_comp)
	inst_comp.owner = _character
	inst_comp.set_unique_name_in_owner(true)
	return true

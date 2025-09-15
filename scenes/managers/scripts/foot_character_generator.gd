@tool
class_name RaigonFootCharacterGenerator extends RaigonCharacterGenerator

func _new_character():
	_character = OnFootCharacter.new()
	print("is this working?")
	super._new_character()

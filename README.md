My aim here is to make available my character controller for my game Raigon.

Currently, this addon does not work. I am actively working to make it so it does, so stay tuned for that update.

# Installation:
Clone this repo into the `addons` folder of your project recursively:

```
git clone https://github.com/BradGaddis/godot-on-rails-third-person-shooter-character-controller rails_character_controler --recursive
```

# Usage:
You will need to restart your project after enabling this plugin.

###### Tentative usage docs:
You will always need to assign the RailsComponent from however you are managing your level system.
	Presently, the character requires that you have a RailsComponent node in the level and assigned to the character

More TBD

# Features / Roadmap:
	
- [ ] Add character by adding a single tool script to the scene
- [ ] Character creater from the editor
	
#### Flight Vehicle Character
- [x] rail movement
- [x] free-range movement
- [x] swapping between free-range movement and rails movement
- [x] shooting
- [ ] optional multi-gun array
- [ ] charge shooting
- [ ] locking on to a target
	- [ ] force locking off a target
- [ ] proper collision handling
- [ ] support for taking damage
- [ ] support for dying
- [ ] camera view switching
	- [ ] 3rd person view
	- [ ] cockpit view
- [ ] taking damage from enemies
- [ ] taking damage from the environment

##### Flight Vehicle Character States:
- [x] support for banking / tilting
- [x] boosting
- [x] breaking
- [x] rolling
- [x] somersaulting
- [x] idling / landing
- [ ] u-turning

#### Grounded Vehicle Character
- [ ] Rail movement
- [ ] land driving movement
- [ ] optional multi-gun array
- [ ] charge shooting
- [ ] locking on to a target
	- [ ] force locking off a target
- [ ] proper collision handling
- [ ] support for taking damage
- [ ] support for dying
- [ ] camera view switching
	- [ ] 3rd person view
	- [ ] cockpit view
- [ ] taking damage from enemies
- [ ] taking damage from the environment

##### Grounded Vehicle Character States:
- [ ] hovering
- [ ] boosting
- [ ] breaking
- [ ] rolling

#### On Foot Character
- [x] shooting
- [ ] charge shooting
- [ ] support for switching guns
- [ ] locking on to a target
	- [ ] force locking off a target
- [ ] proper collision handling
- [ ] camera view switching
	- [ ] 3rd person view
	- [ ] 1st person view
- [ ] proper collision handling
- [ ] support for taking damage
- [ ] support for dying
- [ ] taking damage from enemies
- [ ] taking damage from the environment

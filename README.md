# What This Plugin Is:

My aim here is to make available my character controller for my game Raigon.

The initial plan was to de-couple my character controller for future projects, but the scope of this project seems to be increasing as I learn more about making editor plugins for Godot, so who knows where this will ultimately go.

  Currently, this addon does not work as expected. I am actively working to make it so it does, so stay tuned for that update.
  

# Installation:

Requires Godot Editor 4.5+ 

Clone this repo into the `addons` folder of your project recursively:

```

git clone https://github.com/BradGaddis/godot-on-rails-third-person-shooter-character-controller rails_character_controler --recursive

```

  

# Usage:

It is suggested that you restart your project after enabling this plugin.

###### Actively developing:
After enabling this plugin, you can open it from the top of the editor and toggle on which components you want to add to your character. Presently, only a `FlightCharacter` is supported, and you must name your character before it can be added to the game. It will save with the name that you give it on the top level of your project.

The character requires that you have a `RailsComponent` node in the level and assigned to the character in question, as well as its active `PathFollow3D` assigned.
  
More TBD

---
  

# Features / Roadmap:	
- [x] Character creator from the editor
	- [ ] Support for multiple character creation types
	- [ ] Support for overwriting characters
	- [ ] Interactive editor for creating the character
- [ ] Potentially integrate with Dialogic?
	
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
- [ ] floating (on fluids)

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

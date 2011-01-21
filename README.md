
Soulwire AS3 Framework
-----

###Classes
####uk.co.soulwire.gui.SimpleGUI
[View Demo](http://blog.soulwire.co.uk/code/actionscript-3/simple-flash-prototype-gui-tool/)

A tool for fast prototyping and class demos in Flash.
Quickly create a GUI (based on Keith Peter's [Minimal Comps](http://www.minimalcomps.com/)) to control variables in a sketch.

	// Create a new GUI tied to the sketch and provide a hotkey
	_gui = new SimpleGUI(this, "Example GUI", Keyboard.SPACE);

	// Groups and Columns help organise your control panels
	_gui.addGroup("General Settings");

	// Toggle control for a Boolean
	_gui.addToggle("doAnimation");

	// Nested properties are supported (use normal dot syntax)
	_gui.addSlider("someObject.position.x", 10, 200);

	// Link two properties as a range
	_gui.addRange("minParticles", "maxParticles", 10, 120);

	// Colour picker for uint / int
	_gui.addColour("backgroundColour");

	// Callbacks with parameters can be added to any component
	_gui.addButton("Regenerate", {callback:regenerate, callbackParams:[1000]});

	// Save functionality generates AS3 code with your current settings
	_gui.addSaveButton();

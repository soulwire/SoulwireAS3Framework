
/**		
 * 
 *	uk.co.soulwire.gui.SimpleGUI
 *	
 *	@version 1.00 | Jan 13, 2011
 *	@author Justin Windle
 *	
 *	SimpleGUI is a single Class utility designed for AS3 projects where a developer needs to 
 *	quickly add UI controls for variables or functions to a sketch. Properties can be controlled 
 *	with just one line of code using a variety of components from the fantastic Minimal Comps set 
 *	by Keith Peters, as well as custom components written for SimpleGUI such as the FileChooser
 *	
 *	Credit to Keith Peters for creating Minimal Comps which this class uses
 *	http://www.minimalcomps.com/
 *	http://www.bit-101.com/
 *  
 **/
 
package uk.co.soulwire.gui
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ColorChooser;
	import com.bit101.components.ComboBox;
	import com.bit101.components.Component;
	import com.bit101.components.HUISlider;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;
	import com.bit101.components.RangeSlider;
	import com.bit101.components.Style;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	/**
	 * SimpleGUI
	 */
	 
	public class SimpleGUI extends EventDispatcher
	{
		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------
		
		public static const VERSION : Number = 1.02;
		
		private static const TOOLBAR_HEIGHT : int = 13;
		private static const COMPONENT_MARGIN : int = 8;		private static const COLUMN_MARGIN : int = 1;		private static const GROUP_MARGIN : int = 1;		private static const PADDING : int = 4;		private static const MARGIN : int = 1;
		
		//	----------------------------------------------------------------
		//	PRIVATE MEMBERS
		//	----------------------------------------------------------------
		
		private var _components : Vector.<Component> = new Vector.<Component>();
		private var _parameters : Dictionary = new Dictionary();
		private var _container : Sprite = new Sprite();
		private var _target : DisplayObjectContainer;
		private var _active : Component;
		private var _stage : Stage;
		
		private var _toolbar : Sprite = new Sprite();		private var _message : Label = new Label();
		private var _version : Label = new Label();
		private var _toggle : Sprite = new Sprite();
		private var _lineH : Bitmap = new Bitmap();		private var _lineV : Bitmap = new Bitmap();
		private var _tween : Number = 0.0;
		private var _width : Number = 0.0;
		
		private var _hotKey : String;
		private var _column : Sprite;
		private var _group : Sprite;
		private var _dirty : Boolean;
		private var _hidden : Boolean;
		
		private var _showToggle : Boolean = true;
		
		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------
		
		public function SimpleGUI(target : DisplayObjectContainer, title : String = null, hotKey : * = null)
		{
			_target = target;

			_toggle.x = MARGIN;
			_toggle.y = MARGIN;
			
			_toolbar.x = MARGIN;
			_toolbar.y = MARGIN;
			
			_container.x = MARGIN;
			_container.y = TOOLBAR_HEIGHT + (MARGIN * 2);
			
			initStyles();
			initToolbar();
			initContextMenu();
			
			if (_target.stage) onAddedToStage(null);
			else _target.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			_target.addEventListener(Event.ADDED, onTargetAdded);
			
			if(hotKey) this.hotKey = hotKey;
			
			addColumn(title);
			addGroup();
			hide();
		}
		
		//	----------------------------------------------------------------
		//	PUBLIC METHODS
		//	----------------------------------------------------------------
		
		/**
		 * Shows the GUI
		 */
		
		public function show() : void
		{
			_lineV.visible = false;
			
			_target.addChild(_container);
			_target.addChild(_toolbar);
			_target.addChild(_toggle);
			
			_hidden = false;
		}
		
		/**
		 * Hides the GUI
		 */
		
		public function hide() : void
		{
			_lineV.visible = true;

			if (!_showToggle && _target.contains(_toggle)) _target.removeChild(_toggle);
			if (_target.contains(_container)) _target.removeChild(_container);
			if (_target.contains(_toolbar)) _target.removeChild(_toolbar);
			
			_hidden = true;
		}
		
		/**
		 * Populates the system clipboard with Actionscript code, setting all 
		 * controlled properties to their current values
		 */
		
		public function save() : void
		{
			var path : String;
			var prop : Object;
			var target : Object;
			var targets : Array;
			var options : Object;
			var component : Component;
			var output : String = '';
			
			for (var i : int = 0; i < _components.length; i++)
			{
				component = _components[i];
				options = _parameters[component];
				
				if (options.hasOwnProperty("target"))
				{
					targets = [].concat(options.target);
					
					for (var j : int = 0; j < targets.length; ++j)
					{
						path = targets[j];
						prop = getProp(path);
						target = getTarget(path);

						output += path + " = " + target[prop] + ';\n';
					}
				}
			}
			
			message = "Settings copied to clipboard";
			
			System.setClipboard(output);
		}
		
		/**
		 * Generic method for adding controls. This is called internally by 
		 * specific control methods. It is best to use explicit methods for 
		 * adding controls (such as addSlider and addToggle), however this 
		 * method has been exposed for flexibility
		 * 
		 * @param type The class definition of the component to add
		 * @param options The options to configure the component with
		 */
		
		public function addControl(type : Class, options : Object) : Component
		{
			var component : Component = new type();
			
			// apply settings
			
			for (var option : String in options)
			{
				if (component.hasOwnProperty(option))
				{
					component[option] = options[option];
				}
			}
			
			// subscribe to component events

			if (component is PushButton || component is CheckBox)
			{
				component.addEventListener(MouseEvent.CLICK, onComponentClicked);
			}
			else if (component is ComboBox)
			{
				component.addEventListener(Event.SELECT, onComponentChanged);
			}
			else
			{
				component.addEventListener(Event.CHANGE, onComponentChanged);
			}
			
			// listen for first draw
			
			component.addEventListener(Component.DRAW, onComponentDraw);
			
			// add a label if necessary

			if (!component.hasOwnProperty("label") && options.hasOwnProperty("label") && type !== Label)
			{
				var container : Sprite = new Sprite();
				var label : Label = new Label();
				
				label.text = options.label;
				label.draw();
				
				component.x = label.width + 5;
				
				container.addChild(label);
				container.addChild(component);
				
				_group.addChild(container);
			}
			else
			{
				_group.addChild(component);
			}
			
			_parameters[component] = options;
			_components.push(component);
			
			update();
			//component.width = 200;

			return component;
		}
		
		/**
		 * Adds a column to the GUI
		 * 
		 * @param title An optional title to display at the top of the column
		 */
		
		public function addColumn(title : String = null) : void
		{
			_column = new Sprite();
			_container.addChild(_column);
			addGroup(title);
		}
		
		/**
		 * Creates a separator with an optional title to help segment groups 
		 * of controls
		 * 
		 * @param title An optional title to display at the top of the group
		 */
		
		public function addGroup(title : String = null) : void
		{
			if (_group && _group.numChildren == 0)
			{
				_group.parent.removeChild(_group);
			}
			
			_group = new Sprite();
			_column.addChild(_group);

			if (title)
			{
				addLabel(title.toUpperCase());
			}
		}
		
		/**
		 * Adds a label
		 * 
		 * @param text The text content of the label
		 */
		
		public function addLabel(text : String) : void
		{
			addControl(Label, {text : text.toUpperCase()});
		}
		
		/**
		 * Adds a toggle control for a boolean value
		 * 
		 * @param target The name of the property to be controlled
		 * @param options An optional object containing initialisation parameters 
		 * for the control, the keys of which should correspond to properties on 
		 * the control. Additional values can also be placed within this object, 
		 * such as a callback function. If a String is passed as this parameter, 
		 * it will be used as the control's label, though it is recommended that 
		 * you instead pass the label as a property within the options object
		 */
		
		public function addToggle(target : String, options : Object = null) : void
		{
			options = parseOptions(target, options);
			
			var params : Object = {};
			
			params.target = target;
			
			addControl(CheckBox, merge(params, options));
		}
		
		public function addButton(label : String, options : Object = null) : void
		{
			options = parseOptions(label, options);
			
			var params : Object = {};

			params.label = label;
			
			addControl(PushButton, merge(params, options));
		}
		
		/**
		 * Adds a slider control for a numerical value
		 * 
		 * @param target The name of the property to be controlled
		 * @param minimum The minimum slider value
		 * @param maximum The maximum slider value
		 * @param options An optional object containing initialisation parameters 
		 * for the control, the keys of which should correspond to properties on 
		 * the control. Additional values can also be placed within this object, 
		 * such as a callback function. If a String is passed as this parameter, 
		 * it will be used as the control's label, though it is recommended that 
		 * you instead pass the label as a property within the options object
		 */
		
		public function addSlider(target : String, minimum : Number, maximum : Number, options : Object = null) : void
		{
			options = parseOptions(target, options);
			
			var params : Object = {};
			
			params.target = target;
			params.minimum = minimum;
			params.maximum = maximum;
			
			addControl(HUISlider, merge(params, options));
		}
		
		/**
		 * Adds a range slider control for a numerical value
		 * 
		 * @param target The name of the property to be controlled
		 * @param minimum The minimum slider value
		 * @param maximum The maximum slider value
		 * @param options An optional object containing initialisation parameters 
		 * for the control, the keys of which should correspond to properties on 
		 * the control. Additional values can also be placed within this object, 
		 * such as a callback function. If a String is passed as this parameter, 
		 * it will be used as the control's label, though it is recommended that 
		 * you instead pass the label as a property within the options object
		 */
		
		public function addRange(target1 : String, target2 : String, minimum : Number, maximum : Number, options : Object = null) : void
		{
			var target : Array = [target1, target2];
			
			options = parseOptions(target.join(" / "), options);
			
			var params : Object = {};

			params.target = target;
			params.minimum = minimum;
			params.maximum = maximum;
			
			addControl(HUIRangeSlider, merge(params, options));
		}
		
		/**
		 * Adds a numeric stepper control for a numerical value
		 * 
		 * @param target The name of the property to be controlled
		 * @param minimum The minimum stepper value
		 * @param maximum The maximum stepper value
		 * @param options An optional object containing initialisation parameters 
		 * for the control, the keys of which should correspond to properties on 
		 * the control. Additional values can also be placed within this object, 
		 * such as a callback function. If a String is passed as this parameter, 
		 * it will be used as the control's label, though it is recommended that 
		 * you instead pass the label as a property within the options object
		 */
		
		public function addStepper(target : String, minimum : Number, maximum : Number, options : Object = null) : void
		{
			options = parseOptions(target, options);
			
			var params : Object = {};
			
			params.target = target;
			params.minimum = minimum;
			params.maximum = maximum;
			
			addControl(NumericStepper, merge(params, options));
		}
		
		/**
		 * Adds a colour picker
		 * 
		 * @param target The name of the property to be controlled
		 * @param options An optional object containing initialisation parameters 
		 * for the control, the keys of which should correspond to properties on 
		 * the control. Additional values can also be placed within this object, 
		 * such as a callback function. If a String is passed as this parameter, 
		 * it will be used as the control's label, though it is recommended that 
		 * you instead pass the label as a property within the options object
		 */
		
		public function addColour(target : String, options : Object = null) : void
		{
			options = parseOptions(target, options);
			
			var params : Object = {};
			
			params.target = target;
			params.usePopup = true;
			
			addControl(ColorChooser, merge(params, options));
		}
		
		/**
		 * Adds a combo box of values for a property
		 * 
		 * @param target The name of the property to be controlled
		 * @param items A list of selectable items for the combo box in the form 
		 * or [{label:"The Label", data:anObject},...]
		 * @param options An optional object containing initialisation parameters 
		 * for the control, the keys of which should correspond to properties on 
		 * the control. Additional values can also be placed within this object, 
		 * such as a callback function. If a String is passed as this parameter, 
		 * it will be used as the control's label, though it is recommended that 
		 * you instead pass the label as a property within the options object
		 */
		
		public function addComboBox(target : String, items : Array, options : Object = null) : void
		{
			options = parseOptions(target, options);
			
			var params : Object = {};

			var prop : String = getProp(target);
			var targ : Object = getTarget(target);
			
			params.target = target;
			params.items = items;
			params.defaultLabel = targ[prop];
			params.numVisibleItems = Math.min(items.length, 5);
			
			addControl(StyledCombo, merge(params, options));
		}
		
		/**
		 * Adds a file chooser for a File object
		 * 
		 * @param label The label for the file
		 * @param file The File object to control
		 * @param onComplete A callback function to trigger when the file's data is loaded
		 * @param filter An optional list of FileFilters to apply when selecting the file
		 * @param options An optional object containing initialisation parameters 
		 * for the control, the keys of which should correspond to properties on 
		 * the control. Additional values can also be placed within this object, 
		 * such as a callback function. If a String is passed as this parameter, 
		 * it will be used as the control's label, though it is recommended that 
		 * you instead pass the label as a property within the options object
		 */
		
		public function addFileChooser(label : String, file : FileReference, onComplete : Function, filter : Array = null, options : Object = null) : void
		{
			options = parseOptions(label, options);
			
			var params : Object = {};
			
			params.file = file;
			params.label = label;
			params.width = 220;
			params.filter = filter;
			params.onComplete = onComplete;
			
			addControl(FileChooser, merge(params, options));
		}
		
		/**
		 * Adds a save button to the controls. The save method can also be called 
		 * manually or by pressing the 's' key. Saving populates the system clipboard 
		 * with Actionscript code, setting all controlled properties to their current values
		 * 
		 * @param label The label for the save button
		 * @param options An optional object containing initialisation parameters 
		 * for the control, the keys of which should correspond to properties on 
		 * the control. Additional values can also be placed within this object, 
		 * such as a callback function. If a String is passed as this parameter, 
		 * it will be used as the control's label, though it is recommended that 
		 * you instead pass the label as a property within the options object
		 */
		
		public function addSaveButton(label : String = "Save", options : Object = null) : void
		{
			addGroup("Save Current Settings (S)");
			
			options = parseOptions(label, options);
			
			var params : Object = {};

			params.label = label;
			
			var button : PushButton = addControl(PushButton, merge(params, options)) as PushButton;
			button.addEventListener(MouseEvent.CLICK, onSaveButtonClicked);
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------
		
		private function initStyles() : void
		{
			Style.PANEL = 0x333333;
			Style.BACKGROUND = 0x333333;
			Style.INPUT_TEXT = 0xEEEEEE;
			Style.LABEL_TEXT = 0xEEEEEE;
			Style.BUTTON_FACE = 0x555555;
			Style.DROPSHADOW = 0x000000;
		}
		
		private function initToolbar() : void
		{
			_toolbar.x += TOOLBAR_HEIGHT + 1;
			
			_version = new Label();
			_version.text = "SimpelGUI v" + VERSION;
			_version.alpha = 0.5;

			_message = new Label();
			_message.alpha = 0.6;
			_message.x = 2;
			
			_version.y = _message.y = -3;

			_toggle.graphics.beginFill(0x333333, 0.9);
			_toggle.graphics.drawRect(0, 0, TOOLBAR_HEIGHT, TOOLBAR_HEIGHT);
			_toggle.graphics.endFill();
			
			_toolbar.addChild(_version);
			_toolbar.addChild(_message);

			_toggle.addEventListener(MouseEvent.CLICK, onToggleClicked);
			_toggle.buttonMode = true;
			
			//

			_lineH.bitmapData = new BitmapData(5, 1, false, 0xFFFFFF);			_lineV.bitmapData = new BitmapData(1, 5, false, 0xFFFFFF);

			_lineH.x = (TOOLBAR_HEIGHT * 0.5) - 3;			_lineH.y = (TOOLBAR_HEIGHT * 0.5) - 1;

			_lineV.x = (TOOLBAR_HEIGHT * 0.5) - 1;			_lineV.y = (TOOLBAR_HEIGHT * 0.5) - 3;

			_toggle.addChild(_lineH);			_toggle.addChild(_lineV);
		}
		
		private function initContextMenu() : void
		{
			var menu : * = _target.contextMenu || new ContextMenu();
			var item : ContextMenuItem = new ContextMenuItem("Toggle Controls", true);
			
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuItemSelected);
			menu.customItems.push(item);
			
			_target.contextMenu = menu;
		}
		
		private function commit(component : Component = null) : void
		{
			if (component)
			{
				_active = component;
				apply(component, true);
			}
			else
			{
				for (var i : int = 0; i < _components.length; i++)
				{
					component = _components[i];
					apply(component, false);
				}
			}
			
			update();
		}
		
		private function apply(component : Component, extended : Boolean = false) : void
		{
			var i : int;
			var path : String;
			var prop : Object;			var target : Object;
			var targets : Array;
			var options : Object = _parameters[component];
			
			if (options.hasOwnProperty("target"))
			{
				targets = [].concat(options.target);
				
				for (i = 0; i < targets.length; i++)
				{
					path = targets[i];
					prop = getProp(path);
					target = getTarget(path);
					
					if (component is CheckBox)
					{
						target[prop] = component["selected"];
					}
					else if (component is RangeSlider)
					{
						target[prop] = component[i == 0 ? "lowValue" : "highValue"];
					}
					else if (component is ComboBox)
					{
						if(component["selectedItem"])
						{
							target[prop] = component["selectedItem"].data;
						}
					}
					else if(component.hasOwnProperty("value"))
					{
						target[prop] = component["value"];
					}
				}
			}
			
			if (extended && options.hasOwnProperty("callback"))
			{
				options.callback.apply(_target, options.callbackParams || []);
			}
		}
		
		private function update() : void
		{
			var i : int;
			var j : int;
			var path : String;
			var prop : Object;			var target : Object;			var targets : Array;
			var options : Object;
			var component : Component;
			
			for (i = 0; i < _components.length; i++)
			{
				component = _components[i];

				if (component == _active) continue;
				
				options = _parameters[component];
				
				if (options.hasOwnProperty("target"))
				{
					targets = [].concat(options.target);
				
					for (j = 0; j < targets.length; j++)
					{
						path = targets[j];
						prop = getProp(path);
						target = getTarget(path);
						
						if (component is CheckBox)
						{
							component["selected"] = target[prop];
						}
						else if (component is RangeSlider)
						{
							component[j == 0 ? "lowValue" : "highValue"] = target[prop];
						}
						else if ( component is ComboBox)
						{
							var items : Array = component["items"];
							
							for (var k : int = 0; k < items.length; k++)
							{
								if(items[k].data == target[prop])
								{
									if(component["selectedIndex"] != k)
									{
										component["selectedIndex"] = k;
										break;
									}
								}
							}
						}
						else if(component.hasOwnProperty("value"))
						{
							component["value"] = target[prop];
						}
					}
				}
			}
		}
		
		private function invalidate() : void
		{
			_container.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_dirty = true;
		}
		
		private function draw() : void
		{
			var i : int;
			var j : int;
			var k : int;
			
			var ghs : Array;
			
			var gw : int = 0;
			var gh : int = 0;
			var gy : int = 0;
			var cx : int = 0;
			var cw : int = 0;
			
			var group : Sprite;
			var column : Sprite;
			var component : Sprite;
			var bounds : Rectangle;
			
			for (i = 0; i < _container.numChildren; i++)
			{
				column = _container.getChildAt(i) as Sprite;
				column.x = cx;

				gy = cw = 0;
				ghs = [];
				
				for (j = 0; j < column.numChildren; j++)
				{
					group = column.getChildAt(j) as Sprite;
					group.y = gy;
					
					gw = 0;
					gh = PADDING;
					
					for (k = 0; k < group.numChildren; k++)
					{
						component = group.getChildAt(k) as Sprite;
						
						bounds = component.getBounds(component);
						
						component.x = PADDING - bounds.x;
						component.y = gh - bounds.y;
						
						gw = Math.max(gw, bounds.width);
						gh += bounds.height + (k < group.numChildren - 1 ? COMPONENT_MARGIN : 0);
					}

					gh += PADDING;
					ghs[j] = gh;

					gy += gh + GROUP_MARGIN;
					cw = Math.max(cw, gw);
				}
				
				cw += (PADDING * 2);
				
				for (j = 0; j < column.numChildren; j++)
				{
					group = column.getChildAt(j) as Sprite;
					
					for (k = 0; k < group.numChildren - 1; k++)
					{
						component = group.getChildAt(k) as Sprite;
						
						bounds = component.getBounds(component);
						bounds.bottom += COMPONENT_MARGIN / 2;
						
						component.graphics.clear();
						component.graphics.lineStyle(0, 0x000000, 0.1);
						component.graphics.moveTo(bounds.left, bounds.bottom);
						component.graphics.lineTo(bounds.x + cw - (PADDING * 2), bounds.bottom);
					}
					
					group.graphics.clear();
					group.graphics.beginFill(0x333333, 0.9);
					group.graphics.drawRect(0, 0, cw, ghs[j]);
					group.graphics.endFill();
				}

				cx += cw + COLUMN_MARGIN;
			}
			
			_width = cx - COLUMN_MARGIN;
			_version.x = _width - _toolbar.x -_version.width - 2;
			
			_toolbar.graphics.clear();
			_toolbar.graphics.beginFill(0x333333, 0.9);
			_toolbar.graphics.drawRect(0, 0, _width - _toolbar.x, TOOLBAR_HEIGHT);
			_toolbar.graphics.endFill();
		}
		
		private function parseOptions(target : String, options : Object) : Object
		{
			options = clone(options);
			
			var type : String = getQualifiedClassName(options);
			
			switch(type)
			{
				case "String" :
				
					return {label: options};
					
				case "Object" :
				
					options.label = options.label || propToLabel(target);
					return options;
					
				default :
				
					return {label: propToLabel(target)};
			}
		}
		
		private function getTarget(path : String) : Object
		{
			var target : Object = _target;
			var hierarchy : Array = path.split('.');

			if (hierarchy.length == 1) return _target;
			
			for (var i : int = 0; i < hierarchy.length - 1; i++)
			{
				target = target[hierarchy[i]];
			}
			
			return target;
		}
		
		private function getProp(path : String) : String
		{
			return /[_a-z0-9]+$/i.exec(path)[0];
		}
		
		private function merge(source : Object, destination : Object) : Object
		{
			var combined : Object = clone(destination);
			
			for (var prop : String in source)
			{
				if (!destination.hasOwnProperty(prop))
				{
					combined[prop] = source[prop];
				}
			}

			return combined;
		}
		
		private function clone(source : Object) : Object
		{
			var copy : Object = {};
			
			for (var prop : String in source)
			{
				copy[prop] = source[prop];
			}
			
			return copy;
		}
		
		private function propToLabel(prop : String) : String
		{
			return prop .replace(/[_]+([a-zA-Z0-9]+)|([0-9]+)/g, " $1$2 ")
						.replace(/(?<=[a-z0-9])([A-Z])|(?<=[a-z])([0-9])/g, " $1$2")
						.replace(/^(\w)|\s+(\w)|\.+(\w)/g, capitalise)
						.replace(/^\s|\s$|(?<=\s)\s+/g, '');
		}
		
		private function capitalise(...args) : String
		{
			return String(' ' + args[1] + args[2] + args[3]).toUpperCase();
		}
		
		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------

		private function onAddedToStage(event : Event) : void
		{
			_stage = _target.stage;
			_target.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_target.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
		}
		
		private function onTargetAdded(event : Event) : void
		{
			if (!_hidden) show();
		}
		
		private function onSaveButtonClicked(event : MouseEvent) : void
		{
			save();
		}
		
		private function onToggleClicked(event : MouseEvent) : void
		{
			_hidden ? show() : hide();
		}
		
		private function onContextMenuItemSelected(event : ContextMenuEvent) : void
		{
			_hidden ? show() : hide();
		}
		
		private function onComponentClicked(event : MouseEvent) : void
		{
			commit(event.target as Component);
		}

		private function onComponentChanged(event : Event) : void
		{
			commit(event.target as Component);
		}
		
		private function onComponentDraw(event : Event) : void
		{
			var component : Component = event.target as Component;
			component.removeEventListener(Component.DRAW, onComponentDraw);
			invalidate();
		}
		
		private function onEnterFrame(event : Event) : void
		{
			_container.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			if(_dirty)
			{
				_dirty = false;
				draw();
			}
		}

		private function onKeyPressed(event : KeyboardEvent) : void
		{
			if(hotKey && event.keyCode == hotKey.toUpperCase().charCodeAt(0))
			{
				_hidden ? show() : hide();
			}
			
			if(event.keyCode == 83)
			{
				save();
			}
		}
		
		private function onMessageEnterFrame(event : Event) : void
		{
			_tween += 0.01;
			_message.alpha = 1.0 - (-0.5 * (Math.cos(Math.PI * _tween) - 1));

			if (_message.alpha < 0.0001)
			{
				_message.removeEventListener(Event.ENTER_FRAME, onMessageEnterFrame);
				_message.text = '';
			}
		}
		
		//	----------------------------------------------------------------
		//	PUBLIC ACCESSORS
		//	----------------------------------------------------------------
		
		public function get showToggle() : Boolean
		{
			return _showToggle;
		}
		
		public function set showToggle( value : Boolean ) : void
		{
			_showToggle = value;
			if (_hidden) hide();
		}
		
		public function set message(value : String) : void
		{
			_tween = 0.0;
			_message.alpha = 1.0;
			_message.text = value.toUpperCase();
			_message.addEventListener(Event.ENTER_FRAME, onMessageEnterFrame);
		}
		
		public function get hotKey() : *
		{
			return _hotKey;
		}
		
		public function set hotKey( value : * ) : void
		{
			if (value is String)
			{
				_hotKey = value;
			}
			else if (value is int)
			{
				_hotKey = String.fromCharCode(value);
			}
			else
			{
				throw new Error("HotKey must be a String or an integer");
			}

			message = "Hotkey set to '" + _hotKey + "'";
		}
	}
}
import com.bit101.components.ComboBox;
import com.bit101.components.Component;
import com.bit101.components.HRangeSlider;
import com.bit101.components.InputText;
import com.bit101.components.Label;
import com.bit101.components.PushButton;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileReference;

internal class HUIRangeSlider extends HRangeSlider
{
	private var _label : Label = new Label();
	private var _offset : Number = 0.0;
	
	override protected function addChildren() : void
	{
		super.addChildren();
		_label.y = -5;
		addChild(_label);
	}
	
	override public function draw() : void
	{
		_offset = x = _label.width + 5;
		_width = Math.min(200 - _offset, 200);
		_label.x = -_offset;
		
		super.draw();
	}
	
	public function get label() : String
	{
		return _label.text;
	}
	
	public function set label(value : String) : void
	{
		_label.text = value;
		_label.draw();
	}
}

internal class FileChooser extends Component
{
	public var filter : Array = [];
	public var onComplete : Function;
	
	private var _label : Label = new Label();
	private var _file : FileReference;
	private var _filePath : InputText = new InputText();
	private var _button : PushButton = new PushButton();

	override protected function addChildren() : void
	{
		super.addChildren();

		_button.x = 125;
		_button.width = 75;
		_button.label = "Browse";
		_button.addEventListener(MouseEvent.CLICK, onButtonClicked);

		_filePath.enabled = false;
		_filePath.width = 120;
		_filePath.height = _button.height;
		
		_button.y = _filePath.y = 20;
		
		addChild(_filePath);
		addChild(_button);
		addChild(_label);
	}
	
	private function onButtonClicked(event : MouseEvent) : void
	{
		if (_file) _file.browse(filter);
	}

	private function onFileSelected(event : Event) : void
	{
		_filePath.text = _file.name;
		_file.addEventListener(Event.COMPLETE, onFileComplete);
		_file.load();
	}
	
	private function onFileComplete(event : Event) : void
	{
		if (onComplete != null) onComplete();
	}
		
	override public function set width(w : Number) : void
	{
		super.width = w;
		_button.x = w - _button.width;
		_filePath.width = w - _button.width - 5;
	}
	
	public function get label() : String
	{
		return _label.text;
	}
	
	public function set label( value : String ) : void
	{
		_label.text = value;
	}
	
	public function get file() : FileReference
	{
		return _file;
	}
	
	public function set file( value : FileReference ) : void
	{
		if (_file)
		{
			_file.removeEventListener(Event.SELECT, onFileSelected);
		}
		
		_file = value;
		_file.addEventListener(Event.SELECT, onFileSelected);

		if(_file.data)
		{
			_filePath.text = _file.name;
		}
	}
	
}

internal class StyledCombo extends ComboBox
{
	override protected function addChildren() : void
	{
		super.addChildren();

		_list.defaultColor = 0x333333;
		_list.alternateColor = 0x444444;
		_list.selectedColor = 0x111111;
		_list.rolloverColor = 0x555555;
	}
}
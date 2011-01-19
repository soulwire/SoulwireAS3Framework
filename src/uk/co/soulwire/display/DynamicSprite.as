
/**		
 * 
 *	uk.co.soulwire.display.DynamicSprite
 *	
 *	@version 1.00 | May 21, 2010
 *	@author Justin Windle
 *  
 **/
 
package uk.co.soulwire.display 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedSuperclassName;

	/**
	 * DynamicSprite
	 */
	public class DynamicSprite extends Sprite 
	{
		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------
		
		/**
		 * Dispatched from the DynamicSprite class when a library is added or 
		 * updated via the static update method.
		 */

		public static const LIBRARY_UPDATE_START : String = "DynamicSprite::libraryUpdateStart";
		
		/**
		 * Dispatched from the DynamicSprite class when a library has been added 
		 * or updated and all DynamicSprite instances have been updated from it.
		 */
		
		public static const LIBRARY_UPDATE_COMPLETE : String = "DynamicSprite::libraryUpdateComplete";
		
		/**
		 * Dispatched from DynamicSprite instances when their assets have been updated.
		 */
		
		public static const INSTANCE_UPDATED : String = "DynamicSprite::instanceUpdated";

		//	----------------------------------------------------------------
		//	CLASS MEMBERS
		//	----------------------------------------------------------------

		private static var _eventDispatcher : EventDispatcher = new EventDispatcher();
		private static var _libraries : Dictionary = new Dictionary();
		private static var _instances : int = 0;
		private static var _updated : int = 0;

		//	----------------------------------------------------------------
		//	PUBLIC CLASS METHODS
		//	----------------------------------------------------------------
		
		/**
		 * Adds or updates an asset library. All instances of DynamicSprite will 
		 * attempt to update themselves each time this method is called.
		 * 
		 * @param libraryID An ID for this type of library. Use the same ID each time 
		 * you wish to update assets of one type. For example, you could use the ID of 
		 * 'buttons' when setting the library from buttons_EN.swf and buttons_FR.swf.
		 * 
		 * @param librarySWF The loaded SWF library (normally yourLoaderInstance.content). 
		 * The applicationDomain of this Object will be searched by each DynamicSprite 
		 * instance for it's particular Class which it will update from.
		 */

		public static function update(libraryID : String, librarySWF : DisplayObject) : void
		{
			_updated = 0;
			_libraries[libraryID] = librarySWF;
			dispatchEvent( new Event( LIBRARY_UPDATE_START ));
		}

		// Encapsulate EventDispatcher

		public static function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function dispatchEvent(event : Event) : Boolean
		{
			return _eventDispatcher.dispatchEvent(event);
		}

		public static function hasEventListener(type : String) : Boolean
		{
			return _eventDispatcher.hasEventListener(type);
		}

		public static function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}

		public static function willTrigger(type : String) : Boolean
		{
			return _eventDispatcher.willTrigger(type);
		}

		//	----------------------------------------------------------------
		//	PRIVATE INSTANCE MEMBERS
		//	----------------------------------------------------------------

		private var _asset : DisplayObject;
		private var _classDefinition : String;

		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------
		
		/**
		 * Creates a new DynamicSprite instance
		 * 
		 * @param __classDefinition The fully qualified class name of the 
		 * library asset which this DynamicSprite should use.
		 */

		public function DynamicSprite(__classDefinition : String = '')
		{
			++DynamicSprite._instances;
			
			_classDefinition = name = __classDefinition;
			DynamicSprite.addEventListener(DynamicSprite.LIBRARY_UPDATE_START, update, false, -1, false);
			update();
		}
		
		//	----------------------------------------------------------------
		//	PUBLIC METHODS
		//	----------------------------------------------------------------
		
		/**
		 * Destroys this DynamicSprite instance internally. Remember to also 
		 * remove all external references and listeners before nullifying.
		 */
		
		public function destroy() : void
		{
			--DynamicSprite._instances;
			
			DynamicSprite.removeEventListener(DynamicSprite.LIBRARY_UPDATE_START, update);
			destroyAsset();
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------
		
		private function destroyAsset() : void
		{
			if( _asset )
			{
				if( contains(_asset) )
				{
					removeChild(_asset);
				}
				
				if( _asset is Bitmap )
				{
					Bitmap(_asset).bitmapData.dispose();
				}
				
				_asset = null;
			}
		}

		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------

		private function update(event : Event = null) : void
		{
			var hasChanged : Boolean = false;
			
			for each ( var lib : DisplayObject in _libraries )
			{
				if( lib.root.loaderInfo.applicationDomain.hasDefinition(_classDefinition) )
				{
					try
					{
						var type : Class = lib.root.loaderInfo.applicationDomain.getDefinition(_classDefinition) as Class;
						
						destroyAsset();
						
						if( getQualifiedSuperclassName(type) == "flash.display::BitmapData" )
						{
							_asset = new Bitmap(new type(0, 0), PixelSnapping.AUTO, true);
						}
						else
						{
							_asset = new type();
						}
						
						hasChanged = true;
						addChild(_asset);
						
						break;
					}
					catch( error : Error )
					{
						trace(error.name + " : " + error.message);
					}
				}
			}
			
			if( hasChanged )
			{
				dispatchEvent( new Event( DynamicSprite.INSTANCE_UPDATED ) );
			}
			
			if( ++_updated == _instances && event )
			{
				DynamicSprite.dispatchEvent( new Event( DynamicSprite.LIBRARY_UPDATE_COMPLETE ));
			}
		}

		//	----------------------------------------------------------------
		//	PUBLIC ACCESSORS
		//	----------------------------------------------------------------
		
		/**
		 * The asset for this DynamicSprite instance.
		 */

		public function get asset() : DisplayObject
		{
			return _asset;
		}
		
		/**
		 * The fully qualified class name of the library asset which this 
		 * DynamicSprite should use.
		 */

		public function get classDefinition() : String
		{
			return _classDefinition;
		}

		public function set classDefinition(value : String) : void
		{
			_classDefinition = name = value;
			update();
		}
	}
}
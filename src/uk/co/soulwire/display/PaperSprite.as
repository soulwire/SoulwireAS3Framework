
/**		
 * 
 *	uk.co.soulwire.display.PaperSprite
 *	
 *	@version 1.00 | Jan 11, 2011
 *	@author Justin Windle
 *  
 **/
package uk.co.soulwire.display
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author justin
	 */
	public class PaperSprite extends Sprite
	{
		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------
		
		private static const POINT_A : Point = new Point(0,   0);
		private static const POINT_B : Point = new Point(100, 0);
		private static const POINT_C : Point = new Point(0, 100);
		
		//	----------------------------------------------------------------
		//	PRIVATE MEMBERS
		//	----------------------------------------------------------------
		
		private var _p1 : Point;		private var _p2 : Point;		private var _p3 : Point;
		
		private var _pivot : Point = new Point(0.5, 0.5);
		private var _isFrontFacing : Boolean = false;		private var _dirty : Boolean = false;
		private var _rect : Rectangle;
		
		private var _front : DisplayObject;
		private var _back : DisplayObject;
		
		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------
		
		/**
		 * Creates a new PaperSprite instance
		 * 
		 * @param front The DisplayObject to use as the front face 		 * @param back The DisplayObject to use as the back face 
		 */
		
		public function PaperSprite(front : DisplayObject = null, back : DisplayObject = null)
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			if(front) this.front = front;			if(back) this.back = back;
		}
		
		//	----------------------------------------------------------------
		//	PUBLIC METHODS
		//	----------------------------------------------------------------
		
		/**
		 * Invalidates the PaperSprite's display, causing it to recalculate 
		 * the face positions and visibility during the next render cycle.
		 */
		
		public function invalidate() : void
		{
			_dirty = true;
			if(stage) stage.invalidate();
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------
		
		private function update(event : Event = null) : void
		{
			if (_dirty)
			{
				_p1 = localToGlobal( POINT_A );
				_p2 = localToGlobal( POINT_B );
				_p3 = localToGlobal( POINT_C );
				
				_isFrontFacing = (_p2.x-_p1.x)*(_p3.y-_p1.y)-(_p2.y-_p1.y)*(_p3.x-_p1.x) > 0;
				
				if (_front)
				{
					_rect = _front.getBounds(_front);
					
					_front.x = -(_rect.width * _pivot.x);
					_front.y = -(_rect.height * _pivot.y);
					_front.visible = _isFrontFacing;
				}

				if (_back)
				{
					_rect = _back.getBounds(_back);
					
					_back.x = -(_rect.width * _pivot.x * -1);
					_back.y = -(_rect.height * _pivot.y);
					_back.scaleX = -1;
					_back.visible = !_isFrontFacing;
				}

				_dirty = false;
			}
		}
		
		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------
		
		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(Event.RENDER, update);
			update();
		}
		
		//	----------------------------------------------------------------
		//	PUBLIC ACCESSORS
		//	----------------------------------------------------------------
		
		/**
		 * Whether or not the PaperSprite is oriented so that the front face 
		 * is visible
		 */
		
		public function get isFrontFacing() : Boolean
		{
			return _isFrontFacing;
		}
		
		/**
		 * Relative position of the x axis pivot (between 0.0 and 1.0). Defaults 
		 * to the center of each face (0.5).
		 */
		
		public function get pivotX() : Number
		{
			return _pivot.x;
		}
		
		public function set pivotX( value : Number ) : void
		{
			_pivot.x = value;
			invalidate();
		}
		
		/**
		 * Relative position of the y axis pivot (between 0.0 and 1.0). Defaults 
		 * to the center of each face (0.5).
		 */
		
		public function get pivotY() : Number
		{
			return _pivot.x;
		}
		
		public function set pivotY( value : Number ) : void
		{
			_pivot.y = value;
			invalidate();
		}
		
		/**
		 * The DisplayObject to use as the front face
		 */
		
		public function get front() : DisplayObject
		{
			return _front;
		}
		
		public function set front( value : DisplayObject ) : void
		{
			_front = addChild(value);
			invalidate();
		}
		
		/**
		 * The DisplayObject to use as the back face
		 */
		
		public function get back() : DisplayObject
		{
			return _back;
		}
		
		public function set back( value : DisplayObject ) : void
		{
			_back = addChild(value);
			invalidate();
		}
		
		// override display methods
			
		override public function set x(value : Number) : void
		{
			super.x = value;
			invalidate();
		}
		
		override public function set y(value : Number) : void
		{
			super.y = value;
			invalidate();
		}
		
		override public function set z(value : Number) : void
		{
			super.z = value;
			invalidate();
		}
		
		override public function set rotationX(value : Number) : void
		{
			super.rotationX = value;
			invalidate();
		}
		
		override public function set rotationY(value : Number) : void
		{
			super.rotationY = value;
			invalidate();
		}
		
		override public function set rotationZ(value : Number) : void
		{
			super.rotationZ = value;
			invalidate();
		}

	}
}

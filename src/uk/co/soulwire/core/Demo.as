
/**		
 * 
 *	uk.co.soulwire.core.Demo
 *	
 *	@version 1.00 | Jan 11, 2011
 *	@author Justin Windle
 *  
 **/

package uk.co.soulwire.core
{
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.display.Sprite;

	/**
	 * @author justin
	 */
	public class Demo extends Sprite
	{
		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------
		
		public function Demo()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		//	----------------------------------------------------------------
		//	PROTECTED METHODS
		//	----------------------------------------------------------------
		
		virtual protected function setup() : void
		{
			
		}
		
		protected function start() : void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function stop() : void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		virtual protected function update() : void
		{
			
		}
		
		virtual protected function draw() : void
		{
			
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------
		
		
		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------

		protected function onAddedToStage(event : Event) : void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			setup();
			
			var t : TextField = new TextField();
			t.width = stage.stageWidth;
			t.height = stage.stageHeight;
			t.multiline = true;
			t.selectable = false;
			t.mouseEnabled = false;
			t.text = getQualifiedClassName(this);
			
			//addChildAt(t, 0);
		}
		
		private function onEnterFrame(event : Event) : void
		{
			update();
			draw();
		}
	}
}

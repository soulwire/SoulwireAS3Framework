package uk.co.soulwire
{
	import flash.events.Event;
	import flash.display.Shape;
	import flash.display.Sprite;

	/**
	 * @author justin
	 */
	
	public class Example extends Sprite
	{
		public function Example()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event : Event) : void
		{
			for (var i : int = 0; i < 100; i++) {
				
				var s : Shape = addChild(new Shape()) as Shape;
				
				s.x = Math.random() * stage.stageWidth;
				s.y = Math.random() * stage.stageHeight;
				
				s.graphics.beginFill(Math.random() * 0xFFFFFF, 0.8);
				s.graphics.drawCircle(0, 0, Math.random() * 40);
				s.graphics.endFill();
			}
		}
	}
}

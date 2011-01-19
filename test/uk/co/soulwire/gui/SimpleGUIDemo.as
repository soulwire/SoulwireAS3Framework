
/**		
 * 
 *	uk.co.soulwire.gui.SimpleGUIDemo
 *	
 *	@version 1.00 | Jan 18, 2011
 *	@author Justin Windle
 *  
 **/
package uk.co.soulwire.gui
{
	import uk.co.soulwire.core.Demo;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Keyboard;

	/**
	 * @author justin
	 */
	 
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="850", height="550")]
	
	public class SimpleGUIDemo extends Demo
	{
		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------
		
		private static const MAX_WAVE_STEPS : int = 80;		private static const CIRCLE_RADIUS : int = 80;
		
		//	----------------------------------------------------------------
		//	PUBLIC MEMBERS
		//	----------------------------------------------------------------
		
		// Wave options
		
		public var waveCount : int = 15;
		public var waveSteps : int = 50;
		public var amplitude : int = 140;
		
		public var waveColour : uint = 0xFFFFFF;
		public var backgroundColour : uint = 0xF2F2F2;
		
		// Noise options
		
		public var noiseBase : Point = new Point(120, 120);
		public var noiseSeed : int = Math.random() * 0xFFFFFF;
		public var turbulence : Point = new Point(-0.5, 1.0);
		public var noiseOctaves : int = 3;
		
		// Circle options
		
		public var circle : Sprite = new Sprite();
		public var animateCircle : Boolean = true;
		public var minCircleSize : Number = 10.0;
		public var maxCircleSize : Number = 100.0;
		public var rotationSpeed : Number = 1.0;
		public var textureFileRef : FileReference = new FileReference();
		
		//	----------------------------------------------------------------
		//	PRIVATE MEMBERS
		//	----------------------------------------------------------------
		
		private var _gui : SimpleGUI;
		
		private var _noise : BitmapData;
		private var _loader : Loader = new Loader();
		private var _offsets : Array = [new Point(), new Point()];
		private var _phase : Number = 0.0;
		
		//	----------------------------------------------------------------
		//	PROTECTED METHODS
		//	----------------------------------------------------------------
		
		override protected function setup() : void
		{
			_noise = new BitmapData(stage.stageWidth * 0.5, stage.stageHeight * 0.5, false, 0x0);

			circle.x = stage.stageWidth * 0.5;
			circle.y = stage.stageHeight * 0.5;
			circle.blendMode = BlendMode.DARKEN;
			
			drawCircle(null);
			addChild(circle);
			
			initGUI();
			start();
		}
		
		protected function initGUI() : void
		{
			_gui = new SimpleGUI(this, "Example GUI", Keyboard.SPACE);

			_gui.addGroup("General Settings");
			_gui.addColour("backgroundColour");
			_gui.addButton("Randomise Circle Position", {callback:positionCircle, width:160});
			_gui.addSaveButton();

			_gui.addColumn("Noise Options");
			_gui.addSlider("noiseBase.x", 10, 200);			_gui.addSlider("noiseBase.y", 10, 200);
			_gui.addSlider("noiseSeed", 1, 1000);
			_gui.addSlider("noiseOctaves", 1, 4);
			_gui.addSlider("turbulence.x", -10, 10);
			_gui.addSlider("turbulence.y", -10, 10);

			_gui.addGroup("Wave Options");
			_gui.addStepper("waveCount", 1, 20);
			_gui.addStepper("waveSteps", 2, MAX_WAVE_STEPS);
			_gui.addSlider("amplitude", 0, 200);
			_gui.addColour("waveColour");

			_gui.addColumn("Circle Options");
			_gui.addRange("minCircleSize", "maxCircleSize", 10, 120, {label:"Circle Size Range"});
			_gui.addSlider("rotationSpeed", -10, 10);
			_gui.addComboBox("circle.blendMode", [
			
				{label:"Normal",		data:BlendMode.NORMAL},
				{label:"Darken",		data:BlendMode.DARKEN},
				{label:"Overlay",		data:BlendMode.OVERLAY},				{label:"Difference",	data:BlendMode.DIFFERENCE},
				
			]);
			
			_gui.addFileChooser("Circle Texture", textureFileRef, textureLoaded, [
				new FileFilter("Image Files", "*.jpg;*.jpeg;*.png")
			]);
			
			_gui.addToggle("animateCircle");
			_gui.show();
		}

		override protected function draw() : void
		{
			_offsets[0].x -= turbulence.x;
			_offsets[0].y -= turbulence.y;
			
			_offsets[1].x += 0.5;			_offsets[1].y -= 1.5;
			
			_noise.perlinNoise(noiseBase.x, noiseBase.y, noiseOctaves, noiseSeed, true, true, 7, true, _offsets);
			
			graphics.clear();
			graphics.beginFill(backgroundColour);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			
			var i : int;
			var j : int;
			
			var px : Number;
			var py : Number;			var oy : Number;
			
			var bri : Number;
			var off : Number;
			
			var mh : Number = stage.stageHeight * 0.5;			var oh : Number = (stage.stageHeight - mh) * 0.5;

			var sx : Number = stage.stageWidth / waveSteps;
			var sy : Number = mh / waveCount;

			for (i = 1; i < waveCount; i++)
			{
				py = oh + (i * sy);
				
				graphics.beginFill(waveColour);
				graphics.moveTo(0, py);
				
				for (j = 0; j <= waveSteps; j++)
				{
					px = j * sx;
					
					bri = _noise.getPixel((px % stage.stageWidth) * 0.5, py * 0.5);
					bri *= 5.960464832810452e-8; // (1 / 0xFFFFFF)
					
					off = (bri * bri) * amplitude;
					oy = py - off;

					graphics.lineTo(px, oy);
					
					if(j == 0) graphics.lineStyle(0, 0x000000, 0.5);
				}

				if (i == waveCount - 1) py = stage.stageHeight;
				else py += sy;
				
				graphics.lineStyle ();
				graphics.lineTo(stage.stageWidth, oy);
				graphics.lineTo(stage.stageWidth, py);
				graphics.lineTo(0, py);
				graphics.endFill();
			}
			
			if (animateCircle)
			{
				_phase += 0.05;
				
				var scale : Number = Math.abs(Math.sin(_phase));
				var range : Number = maxCircleSize - minCircleSize;

				circle.scaleX = circle.scaleY = (minCircleSize + (range * scale)) / CIRCLE_RADIUS;
				circle.rotation += rotationSpeed;
			}
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------
		
		private function positionCircle() : void
		{
			circle.x = Math.random() * stage.stageWidth;			circle.y = Math.random() * stage.stageHeight;
		}
		
		private function drawCircle(texture : BitmapData = null) : void
		{
			circle.graphics.clear();
			
			if (texture)
			{
				var scale : Number;
				var matrix : Matrix = new Matrix();

				scale = (CIRCLE_RADIUS * 2) / Math.min(texture.width, texture.height);
				
				matrix.translate(-(texture.width * 0.5), -(texture.height * 0.5));
				matrix.scale(scale, scale);
				
				circle.graphics.beginBitmapFill(texture, matrix, true, true);
			}
			else
			{
				circle.graphics.beginFill(0xCCCCCC);
			}
			
			circle.graphics.drawCircle(0, 0, CIRCLE_RADIUS);
			circle.graphics.endFill();
		}
		
		private function textureLoaded() : void
		{
			_loader.unload();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBytesLoaded);
			_loader.loadBytes(textureFileRef.data);
		}

		private function onBytesLoaded(event : Event) : void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBytesLoaded);
			drawCircle(Bitmap(_loader.content).bitmapData);
		}
	}
}
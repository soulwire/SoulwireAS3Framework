
/**		
 * 
 *	uk.co.soulwire.display.PaperSpriteDemo
 *	
 *	@version 1.00 | Jan 11, 2011
 *	@author Justin Windle
 *  
 **/
package uk.co.soulwire.display
{
	import uk.co.soulwire.core.Demo;

	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	/**
	 * @author justin
	 */
	public class PaperSpriteDemo extends Demo
	{
		//	----------------------------------------------------------------
		//	PRIVATE MEMBERS
		//	----------------------------------------------------------------
		
		private var _sprites : Vector.<PaperSprite> = new Vector.<PaperSprite>();
		private var _container : Sprite = new Sprite();
		
		//	----------------------------------------------------------------
		//	PROTECTED METHODS
		//	----------------------------------------------------------------
		
		override protected function setup() : void
		{
			var sprite : Sprite;
			var matrix : Matrix3D;
			var rad : Number = 100;
			var aXY : Number, aYZ : Number;
			var theta : Number, phi : Number;
			var s : Number, px : Number, py : Number, pz : Number;
			
			for(aXY = 0.0; aXY < 360; aXY += 30)
			{
				theta = aXY * Math.PI / 180;
				
				for(aYZ = 0.0; aYZ < 360; aYZ += 30)
				{
					phi = aYZ * Math.PI / 180;

					s = Math.sin(phi) * rad;
					px = Math.cos(theta) * s;					py = Math.sin(theta) * s;					pz = Math.cos(phi) * rad;
					
					sprite = new PaperSprite(createBox(0x333333), createBox(0xCCCCCC));

					matrix = new Matrix3D();
					matrix.appendTranslation(px, py, pz);
					//matrix.pointAt(new Vector3D(), Vector3D.Z_AXIS, Vector3D.Y_AXIS);					matrix.pointAt(new Vector3D(), Vector3D.Z_AXIS, Vector3D.Y_AXIS);

					sprite.transform.matrix3D = matrix;

					_container.addChild(sprite);
					_sprites.push(sprite);
				}
			}

			_container.x = stage.stageWidth >> 1;
			_container.y = stage.stageHeight >> 1;
			addChild(_container);
			
			start();
		}
		
		override protected function update() : void
		{
			_container.rotationY += 1.5;
			_container.rotationX += 3.5;
			_container.rotationZ -= 0.5;
			
			//return;
			for each (var sprite : PaperSprite in _sprites)
			{
				sprite.invalidate();
				/*trace(sprite.transform.getRelativeMatrix3D(_container).position.z);
				sprite.rotationY += 1.5;
				sprite.rotationX += 3.5;
				sprite.rotationZ -= 0.5;-*/
			}
		}
		
		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------
		
		private function createBox(colour : int = -1) : Sprite
		{
			var box : Sprite = new Sprite();

			box.graphics.beginFill((colour == -1) ? Math.random() * 0xFFFFFF : colour);
			//box.graphics.drawRect(0, 0, 20, 20);
			box.graphics.drawCircle(0, 0, 10);
			box.graphics.endFill();

			/*box.graphics.lineStyle(5, 0x000000);
			
			box.graphics.moveTo(20, 50);
			box.graphics.lineTo(80, 50);
			
			box.graphics.moveTo(60, 20);
			box.graphics.lineTo(80, 50);*/
			
			/*box.graphics.moveTo(60, 80);
			box.graphics.lineTo(80, 50);*/

			return box;
		}
		
	}
}

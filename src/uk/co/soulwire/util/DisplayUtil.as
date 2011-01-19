
/**		
 * 
 *	uk.co.soulwire.util.DisplayUtil
 *	
 *	@version 1.00 | Jan 11, 2011
 *	@author Justin Windle
 *  
 **/

package uk.co.soulwire.util
{
	import uk.co.soulwire.enum.Alignment;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class DisplayUtil
	{	

		//	----------------------------------------------------------------
		//	PUBLIC CLASS METHODS
		//	----------------------------------------------------------------
		
		/**
		 * Fits a DisplayObject into a rectangular area with several options for scale 
		 * and alignment. This method will return the Matrix required to duplicate the 
		 * transformation and can optionally apply this matrix to the DisplayObject.
		 * 
		 * @param displayObject
		 * 
		 * The DisplayObject that needs to be fitted into the Rectangle.
		 * 
		 * @param rectangle
		 * 
		 * A Rectangle object representing the space which the DisplayObject should fit into.
		 * 
		 * @param fillRect
		 * 
		 * Whether the DisplayObject should fill the entire Rectangle or just fit within it. 
		 * If true, the DisplayObject will be cropped if its aspect ratio differs to that of 
		 * the target Rectangle.
		 * 
		 * @param align
		 * 
		 * The alignment of the DisplayObject within the target Rectangle. Use a constant from 
		 * the DisplayUtils class.
		 * 
		 * @param applyTransform
		 * 
		 * Whether to apply the generated transformation matrix to the DisplayObject. By setting this 
		 * to false you can leave the DisplayObject as it is but store the returned Matrix for to use 
		 * either with a DisplayObject's transform property or with, for example, BitmapData.draw()
		 */

		public static function fitIntoRect(displayObject : DisplayObject, rectangle : Rectangle, fillRect : Boolean = true, align : String = "C", applyTransform : Boolean = true) : Matrix
		{
			var matrix : Matrix = new Matrix();
			
			var wD : Number = displayObject.width / displayObject.scaleX;
			var hD : Number = displayObject.height / displayObject.scaleY;
			
			var wR : Number = rectangle.width;
			var hR : Number = rectangle.height;
			
			var sX : Number = wR / wD;
			var sY : Number = hR / hD;
			
			var rD : Number = wD / hD;
			var rR : Number = wR / hR;
			
			var sH : Number = fillRect ? sY : sX;
			var sV : Number = fillRect ? sX : sY;
			
			var s : Number = rD >= rR ? sH : sV;
			var w : Number = wD * s;
			var h : Number = hD * s;
			
			var tX : Number = 0.0;
			var tY : Number = 0.0;
			
			switch(align)
			{
				case Alignment.LEFT :
				case Alignment.TOP_LEFT :
				case Alignment.BOTTOM_LEFT :
					tX = 0.0;
					break;
					
				case Alignment.RIGHT :
				case Alignment.TOP_RIGHT :
				case Alignment.BOTTOM_RIGHT :
					tX = w - wR;
					break;
					
				default : 					
					tX = 0.5 * (w - wR);
			}
			
			switch(align)
			{
				case Alignment.TOP :
				case Alignment.TOP_LEFT :
				case Alignment.TOP_RIGHT :
					tY = 0.0;
					break;
					
				case Alignment.BOTTOM :
				case Alignment.BOTTOM_LEFT :
				case Alignment.BOTTOM_RIGHT :
					tY = h - hR;
					break;
					
				default : 					
					tY = 0.5 * (h - hR);
			}
			
			matrix.scale(s, s);
			matrix.translate(rectangle.left - tX, rectangle.top - tY);
			
			if(applyTransform)
			{
				displayObject.transform.matrix = matrix;
			}
			
			return matrix;
		}

		/**
		 * Creates a thumbnail of a BitmapData. The thumbnail can be any size as 
		 * the copied image will be scaled proportionally and cropped if necessary 
		 * to fit into the thumbnail area. If the image needs to be cropped in order 
		 * to fit the thumbnail area, the alignment of the crop can be specified
		 * 
		 * @param image
		 * 
		 * The source image for which a thumbnail should be created. The source 
		 * will not be modified
		 * 
		 * @param width
		 * 
		 * The width of the thumbnail
		 * 
		 * @param height
		 * 
		 * The height of the thumbnail
		 * 
		 * @param align
		 * 
		 * If the thumbnail has a different aspect ratio to the source image, although 
		 * the image will be scaled to fit along one axis it will be necessary to crop 
		 * the image. Use this parameter to specify how the copied and scaled image should 
		 * be aligned within the thumbnail boundaries. Use a constant from the Alignment 
		 * enumeration class
		 * 
		 * @param smooth
		 * 
		 * Whether to apply bitmap smoothing to the thumbnail
		 */

		public static function createThumb(image : BitmapData, width : int, height : int, align : String = "C", smooth : Boolean = true) : Bitmap
		{
			var source : Bitmap = new Bitmap(image);
			var thumbnail : BitmapData = new BitmapData(width, height, false, 0x0);
			
			thumbnail.draw(image, fitIntoRect(source, thumbnail.rect, true, align, false), null, null, null, smooth);
			source = null;
			
			return new Bitmap(thumbnail, PixelSnapping.AUTO, smooth);
		}
	}
}


/**		
 * 
 *	uk.co.soulwire.colour.ColourUtil
 *	
 *	@version 1.00 | Mar 23, 2010
 *	@author Justin Windle
 *  
 **/
 
package uk.co.soulwire.util 
{
	import flash.display.BitmapData;
	import flash.geom.Point;

	/**
	 * ColourUtils
	 */
	public class ColourUtil
	{

		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------

		private static const ZERO : Point = new Point();

		//	----------------------------------------------------------------
		//	CLASS MEMBERS
		//	----------------------------------------------------------------
		
		// Colour Palette

		private static var	pix : Vector.<uint>;
		private static var	out : Vector.<uint>;
		private static var	col : Vector.<Colour>;

		private static var 	c : Colour;
		private static var	o : Object;
		private static var	t : Number;

		private static var	i : int,	r : int,
							j : int,	g : int,
							k : int,	b : int,
							n : int,	x : int,
							p : int,	y : int,
							q : int,	z : int;

		private static var	data : Vector.<int> = new Vector.<int>(1, true),
							sort : Vector.<int> = new Vector.<int>(1, true);

		private static var	qa : Vector.<int> = new Vector.<int>(256, true),
							qb : Vector.<int> = new Vector.<int>(256, true),
							na : Vector.<int> = new Vector.<int>(1, true),
							nb : Vector.<int> = new Vector.<int>(1, true);

		//	----------------------------------------------------------------
		//	CLASS METHODS
		//	----------------------------------------------------------------
		
		/**
		 * Extracts a colour palette of a specified size from a BitmapData image. 
		 * The colours returned are selected by their uniqueness and ordered by 
		 * their frequency, ensuring rare but distinctive colours are included 
		 * in the palette, producing a fair representation of the range of colours 
		 * within a given image.
		 * 
		 * @param image The image from which you wish to extract the colour palette
		 * @param max The maximum amount of colours to extract
		 * @param tolerance The tolerance of the algorithm when assessing a colours 
		 * uniqueness. Lower values will increase sensitivity for images with a 
		 * bland colour palette, higher values are best for images with a multitude 
		 * of distinct colours as there will be a stronger contrast between the 
		 * colours selected by the algorithm
		 * @return A list of unique colours extracted from the source image
		 * 
		 * TODO Auto adjust tolerance based on image histogram
		 * TODO Option output sort based on hue
		 * TODO Optimise colour indexing, or blur input and skip pixels
		 */

		public static function getPalette( image : BitmapData, max : int = 16, tolerance : Number = 0.01 ) : Vector.<uint>
		{
			o = {};
			out = new Vector.<uint>();
			(col = col || new Vector.<Colour>()).length = 0;
			
			/**
			 * Replace the nested getPixel loop with a call to getVector. 
			 * This native BitmapData method returns a list of uints 
			 * representing the pixels in the BitmapData instance.
			 */
			
			pix = image.getVector(image.rect);
			n = pix.length;
			j = -1;
			
			/**
			 * Index all pixels in the image, storing them as Colour objects 
			 * consisting of their RGB value (removing the alpha channel is 
			 * over 230% faster) and the frequency at which they occur.
			 */

			for(i = 0;i < n;++i) (c = o[p = pix[i] & 0xFFFFFF]) ? ++c.n : col[int(++j)] = o[p] = new Colour(p);
			
			/**
			 * Sort the colours by frequency. We're working with integers, 
			 * so lets take advantage of the fast radix sort algorithm:
			 * 
			 * http://en.wikipedia.org/wiki/Radix_sort
			 * http://www.cs.ubc.ca/~harrison/Java/sorting-demo.html
			 * 
			 * I'm using a version of Rob Bateman's AS3 implementation, 
			 * which you can read about and download here:
			 * 
			 * http://www.infiniteturtles.co.uk/blog/fast-sorting-in-as3
			 * 
			 * After trying many techniques (Quick, Insertion, Flash...) 
			 * this gave the best results, so thank you Rob!
			 * http://www.infiniteturtles.co.uk/
			 */

			n = j;
			i = j = 0;
			
			qa.fixed = qb.fixed = na.fixed = nb.fixed = data.fixed = sort.fixed = false;
			qa.length = qb.length = na.length = nb.length = data.length = sort.length = 0;
			
			qa.length = qb.length = 256;
			na.length = nb.length = n + 1;
			data.length = sort.length = n;
			
			qa.fixed = qb.fixed = na.fixed = nb.fixed = data.fixed = sort.fixed = true;

			while (i < n)
			{
				c = col[i];
				na[int(i + 1)] = qa[k = (255 & (data[i] = c.n))];
				qa[k] = int(++i);
			}

			i = 256;
			
			while (i--)
			{
				j = qa[i];
				while (j)
				{
					nb[j] = qb[k = (65280 & data[int(j - 1)]) >> 8];
					j = na[qb[k] = j];
				}
			}
			
			i = k = 0;

			while (i < 255)
			{
				j = qb[int(i++)];
				while (j)
				{
					c = col[int(j - 1)];
					p = c.c;
					sort[int(--n)] = p;
					j = nb[j];
				}
			}
			
			/**
			 * Working through the list from most frequent to least, find distinct 
			 * colours by computing the distance between their RGB components and 
			 * those of the palette and comparing this to the tolerance threshold.
			 */

			k = 0;
			n = col.length - 1;
			t = tolerance * 195075;

			for (i = 0;i < n;++i)
			{
				r = (p = sort[i]) >> 16 & 0xFF;
				g = p >> 8 & 0xFF;
				b = p & 0xFF;
				
				for (j = 0;j < k;++j) if((x = r - ((q = out[j]) >> 16 & 0xFF)) * x + (y = g - (q >> 8 & 0xFF)) * y + (z = b - (q & 0xFF)) * z <= t) break;
				if(j == k) out[int(k++)] = p;
				if(k == max) break;
			}
			
			return out;
		}

		/**
		 * Reduces the colours in a BitmapData instance by computing the red, 
		 * green and blue components at intervals and applying the resulting 
		 * values with paletteMap.
		 * 
		 * @param image A BitmapData instance to modify
		 * @param colours The number of colours to use in the resulting image
		 * @param clone If true, paletteMap will be applied to a copy of the 
		 * specified image, leaving the original untouched
		 * @return The modified BitmapData instance. If the clone is false, this 
		 * will be a reference to the BitmapData passed as the image parameter
		 */

		public static function reduceColours( image : BitmapData, colours : int = 128, clone : Boolean = false ) : BitmapData
		{
			var i : int,j : int,n : int;
			var r : Array = [],g : Array = [],b : Array = [];
			var s : Number = 1 / (n = int(256 / (colours / 3)));
			
			for (i = 0;i < 256;++i)
			{
				b[i] = j = int(int(i * s) * n);
				g[i] = j << 8;
				r[i] = j << 16;
			}
			
			if(clone) image = image.clone();
			image.paletteMap(image, image.rect, ZERO, r, g, b);
			return image;
		}
	}
}

// VO Class for storing indexed colours

internal final class Colour
{

	public var	c : int,
				n : int = 1;

	public function Colour(p : int) 
	{
		c = p;
	}
}
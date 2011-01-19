
/**		
 * 
 *	uk.co.soulwire.math.Random
 *	
 *	@version 1.00 | Jan 11, 2009
 *	@author Justin Windle
 *  
 **/

package uk.co.soulwire.math
{
	/**
	 * Random
	 */
	public class Random
	{
		//	----------------------------------------------------------------
		//	CLASS MEMBERS
		//	----------------------------------------------------------------
		
		private static var _seed : Number = 1.0;
		private static var _next : Number = 1.0;
		
		//	----------------------------------------------------------------
		//	SINGLETON ENFORCER
		//	----------------------------------------------------------------
		
		public function Random()
		{
			throw new Error("The Random class cannot be instantiated");
		}
		
		//	----------------------------------------------------------------
		//	PUBLIC CLASS METHODS
		//	----------------------------------------------------------------
		
		/**
		 * Increments the random number generator and returns the next value
		 */
		
		public static function next() : Number
		{
			_next = ( _next * 16807 ) % 2147483647;
			return _next * 4.656612875245797e-10;
		}
		
		/**
		 * Randomly seeds the random number generator
		 */
		
		public static function randomSeed() : void
		{
			seed = Math.random() * 2147483647;
			trace("Random::seed » " + _seed);
		}
		
		/**
		 * Returns a random float within the specified range
		 * 
		 * @param min The lower range limit. If only this parameter is passed, 
		 * this will be used as the upper range limit, the lower limit being 0
		 * 
		 * @param max The upper range limit
		 */
		
		public static function float( min : Number, max : Number = NaN ) : Number
		{
			if ( isNaN(max) )
			{
				max = min;
				min = 0;
			}
			
			return next() * ( max - min ) + min;
		}
		
		/**
		 * Returns a random integer within the specified range
		 * 
		 * @param min The lower range limit. If only this parameter is passed, 
		 * this will be used as the upper range limit, the lower limit being 0
		 * 
		 * @param max The upper range limit
		 */

		public static function integer( min : Number, max : Number = NaN ) : int
		{
			if ( isNaN(max) )
			{
				max = min;
				min = 0;
			}
			
			return int( (next() * ( max - min ) + min) + 0.5 );
		}
		
		/**
		 * Returns either true or false based on a given probability
		 * 
		 * @param chance The probability (between 0 and 1) of returning true
		 */

		public static function bool( chance : Number = 0.5 ) : Boolean
		{
			return Random.next() < chance;
		}
		
		/**
		 * Returns either -1 or 1 based on a given probability
		 * 
		 * @param chance The probability (between 0 and 1) of returning 1
		 */

		public static function sign( change : Number = 0.5 ) : int
		{
			return next() < change ? 1 : -1;
		}
		
		/**
		 * Returns a random item from a list or property from a dynamic object
		 * 
		 * @param list A list of objects or values in the form of an Array or Vector. If 
		 * a dynamic object is passed, a random property from this object will be returned
		 */

		public static function item( list : * ) : *
		{
			if (list is Array || list is Vector)
			{
				return list[ int(next() * list.length) ];
			}
			else
			{
				var i : int = 0;
				var p : Vector.<String> = new Vector.<String>();
				
				for (var j : String in list)
				{
					p[int(i++)] = j;
				}
				
				return list[ p[ int(next() * i) ] ];
			}
		}
		
		//	----------------------------------------------------------------
		//	CLASS ACCESSORS
		//	----------------------------------------------------------------
		
		/**
		 * The seed for this random number generator
		 */
		
		public static function get seed() : Number
		{
			return _seed;
		}

		public static function set seed(value : Number) : void
		{
			_seed = _next = value;
		}
	}
}

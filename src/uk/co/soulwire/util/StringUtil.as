
/**		
 * 
 *	uk.co.soulwire.util.StringUtil
 *	
 *	@version 1.00 | Jan 12, 2011
 *	@author Justin Windle
 *  
 **/
package uk.co.soulwire.util
{
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	/**
	 * @author justin
	 */
	public class StringUtil
	{
		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------
		
		public function StringUtil()
		{
			throw new Error("The StringUtil class cannot be instantiated");
		}
		
		//	----------------------------------------------------------------
		//	PUBLIC CLASS METHODS
		//	----------------------------------------------------------------
		
		/**
		 * Removes extra spaces from a String and replaces them with a single space
		 * 
		 * @param input The String to clean
		 * @return The modified String
		 */

		public static function clean(input : String) : String
		{
			return trim(input.replace(/\s+/g, ' '));
		}
		
		/**
		 * Removes whitespace from the start and end of a String
		 * 
		 * @param input The String to trim
		 * @return The modified String
		 */

		public static function trim(input : String) : String
		{
			return input.replace(/^\s+|\s+$/g, '');
		}
		
		/**
		 * Truncates a String after a specified amount and optionally 
		 * appends characters to the end
		 * 
		 * @param input The text to truncate
		 * @param limit The position to truncate the String at
		 * @param append An optional String to append to the truncated String
		 */

		public static function truncate(input : String, limit : int, append : String = "...") : String
		{			
			return input.length > limit ? input.substr(0, limit).replace(/\s+$/, '') + append : input;
		}
		
		/**
		 * Adds characters to the beginning of a String until it is the desired length
		 * 
		 * @param str The String to pad
		 * @param char The character to use as padding
		 * @param size The desired total length of the String
		 * @return A left padded String
		 */
		
		public static function padLeft(input : String, char : String, size : int) : String
		{
			while (input.length < size) input = char + input;
			return input;
		}
		
		/**
		 * Adds characters to the end of a String until it is the desired length
		 * 
		 * @param input The String to pad
		 * @param char The character to use as padding
		 * @param size The desired total length of the String
		 * @return A left padded String
		 */
		
		public static function padRight(input : String, char : String, size : int) : String
		{
			while (input.length < size) input = input + char;
			return input;
		}

		/**
		 * Strips the specified tag from a String
		 * 
		 * @param input The String to strip tags from
		 * @param tag The tag to remove, minus brackets, e.g. div
		 * @return The Modified String
		 */

		public static function stripTag(input : String, tag : String) : String
		{
			return input.replace(new RegExp("<\/?" + tag + "([^<]+)?>", "gim"), '');
		}
		
		/**
		 * Strips all tags from a String
		 * 
		 * @param input The String to strip tags from
		 * @return The Modified String
		 */

		public static function stripTags(input : String) : String
		{
			return input.replace(/<[^<]+?>/gim, '');
		}
		
		/**
		 * Strips extra slashes from a URL while omitting the double
		 * slash after http:
		 * 
		 * For example http://www.domain.com///data//config.xml
		 * is trimmed to become http://www.domain.com/data/config.xml
		 * 
		 * This can be useful for cleaning URLs which have been
		 * constructed dynamically when certain paths are blank
		 * 
		 * @param input The URL to strip extra slashes from
		 * @return The cleaned URL
		 */

		public static function stripSlashes(input : String) : String
		{
			return input.replace(/(?<!:)\/+/ig, "/");
		}
		
		/**
		 * Extracts all content within a specified tag from a String. Useful 
		 * for extracting the text from all anchor tags in HTML, for example
		 * 
		 * @param input The String to analyse
		 * @param tag The tag name to search for, e.g. div
		 * @return An Array of values found within the tags
		 */
		
		public static function extractContent(input : String, tag : String) : Array
		{
			var logic : RegExp = new RegExp("<" + tag + "[^<]+>(.*?)<\/" + tag + ">", "gim");
			var result : Object = logic.exec(input);
			var output : Array = [];

			while (result)
			{
				output.push(result[1]);
				result = logic.exec(input);
			}
			
			return output;
		}
		
		/**
		 * Extracts the domain form a url and returns the domain
		 * 
		 * @param input The URI for which you wish to find the domain
		 * @return The domain of the URI
		 */
		
		public static function extractDomain(input : String) : String
		{
			return /(^\w+:\/\/)?([^\/|\?]+).*?$/i.exec(input)[2];
		}
		
		/**
		 * Determines the protocol of a uri, for example http, ftp, svn...
		 * 
		 * @param input The URI for which you wish to find the protocol
		 * @return The protocol of the URI
		 */
		
		public static function extractProtocol(input : String) : String
		{
			return /^([a-z]+):\/\//i.exec(input)[1];
		}
		
		/**
		 * Validates an email address based on the account name, domain and extension
		 * 
		 * @param input The email address to validate
		 * @return Whether or not the email address is valid
		 */
		 
		public static function validateEmail(input : String) : Boolean
		{
			// http://en.wikipedia.org/wiki/Email_address
			// http://en.wikipedia.org/wiki/List_of_Internet_top-level_domains
			
			// acount:		[a-z0-9]([a-z0-9\.\_\-]{0,62}[a-z0-9])?
			// domain:		[a-z0-9][a-z0-9\-]{1,61}[a-z0-9]
			// extension:	([a-z]{2,3}(\.[a-z]{2,3})?|(aero|asia|coop|info|jobs|mobi|museum|name|travel))
						return /^[a-z0-9]([a-z0-9\.\_\-]{0,62}[a-z0-9])?@[a-z0-9][a-z0-9\-]{1,61}[a-z0-9]\.([a-z]{2,3}(\.[a-z]{2,3})?|(aero|asia|coop|info|jobs|mobi|museum|name|travel))$/i.exec(input) ? true : false;
		}
		
		/**
		 * Checks whether an IP adress is valid or not
		 * 
		 * @param input The IP address to validate
		 * @return Whether or not the IP address is valid
		 */
		
		public static function validateIP(input : String) : Boolean
		{
			var valid : Boolean = /^(\d{1,3}\.){3}\d{1,3}$/.exec(input);
			
			if (valid)
			{
				var components : Array = input.match(/\d+/g);

				if (components.length == 4)
				{
					for each (var num : String in components)
					{
						if(parseInt(num) > 255)
						{
							return false;
						}
					}
					
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * Returns the file extension from a path or file name
		 * 
		 * @param input The path or file name
		 * @param removeDot Whether or not to remove the dot
		 * @return The file type of a path or file name
		 */
		
		public static function fileExtension(input : String) : String
		{
			var output : Object = /\.([^\.]+)$/.exec(input);
			output = /^[^\?]+/.exec(output ? output[0] : '');
			return output ? output[0].replace(/^\./, '') : '';
		}
		
		/**
		 * Returns the location of a file (the full path excluding the file)
		 * For example, passing http://site.com/swf/mov.swf?t=1234 will return http://site.com/swf/
		 * 
		 * @param input The full file path
		 * @return The location of the file
		 */
		
		public static function fileLocation(input : String) : String
		{
			return input.replace(/[^\/]+[^\.]+$/, '');
		}
		
		/**
		 * Converts special symbols in a string to HTML entities. For example, & becomes &amp;
		 * 
		 * @param input The text to convert to HTML entities
		 * @return The text with HTML entities
		 */

		public static function htmlEscape(input : String) : String
		{
			return XML(new XMLNode(XMLNodeType.TEXT_NODE, input)).toXMLString();
		}
		
		/**
		 * Replaces HTML entities in a string with their corrosponding symbols, for example &amp; becomes &
		 * 
		 * @param input The text which should have HTML entities replaced by symbols
		 * @return The text after having HTML entities replaced by symbols
		 */

		public static function htmlUnescape(input : String) : String
		{
			return new XMLDocument(input).firstChild.nodeValue;
		}
	}
}

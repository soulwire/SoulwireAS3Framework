
/**		
 * 
 *	uk.co.soulwire.util.StringUtilDemo
 *	
 *	@version 1.00 | Jan 12, 2011
 *	@author Justin Windle
 *  
 **/
package uk.co.soulwire.util
{
	import flash.text.TextField;
	import uk.co.soulwire.core.Demo;

	/**
	 * @author justin
	 */
	public class StringUtilDemo extends Demo
	{
		private var _output : TextField;
		
		override protected function setup() : void
		{
			_output = new TextField();
			_output.multiline = true;
			_output.width = stage.stageWidth;
			_output.height = stage.stageHeight;
			addChild(_output);
			run();
		}
		
		private function run() : void
		{
			var input : String;
			var output : String;
			
			// trim
			
			input = '   hello   world  ';
			output = StringUtil.trim(input);
			log("trim", '"' + input + '"', '"' + output + '"');
			
			// clean
			
			output = StringUtil.clean(input);
			log("clean", '"' + input + '"', '"' + output + '"');

			// truncate
			
			input = "This is a long String, much too long for the container it belongs in";
			output = StringUtil.truncate(input, 40, "...");
			log("truncate", input, output);
			
			// padLeft
			
			input = '7';
			output = StringUtil.padLeft(input, '0', 3);
			log("padLeft", input, output);
			
			// padRight
			
			input = '7';
			output = StringUtil.padRight(input, '0', 3);
			log("padRight", input, output);
			
			// strip tag
			
			input = '<p>hello <a href="#" target="_blank">world</a></p>';
			output = StringUtil.stripTag(input, 'A');
			log("stripTag", input, output);
			
			// strip tags
			
			output = StringUtil.stripTags(input);
			log("stripTags", input, output);
			
			// strip slashes

			input = "http://www.domain.com///data//config.xml";
			output = StringUtil.stripSlashes(input);
			log("stripSlashes", input, output);
			
			// extract content
			
			input = '<p>this is <a href="#">link 1</a></p><p>and this is <a href="#">link 2</a></p>';
			output = StringUtil.extractContent(input, 'a').toString();
			log("extractContent", input, output);
			
			// extract domain
			
			input = "https://subdomain.domain.com/path/script.php?val1=a&val2=b";
			output = StringUtil.extractDomain(input).toString();
			log("extractDomain", input, output);
			
			// extract protocol
			
			input = "ftp://subdomain.domain.com/path/script.php?val1=a&val2=b";
			output = StringUtil.extractProtocol(input).toString();
			log("extractProtocol", input, output);
			
			// validate email
			
			input = "justin.soulwire_12-3@some-domain.mobi";
			output = StringUtil.validateEmail(input).toString();
			log("validateEmail", input, output);
			
			// validate ip
			
			input = "192.168.1.100";
			output = StringUtil.validateIP(input).toString();
			log("validateIP", input, output);
			
			// file extension
			
			input = "https://subdomain.domain.com/path/script.php?val1=a&val2=b";
			output = StringUtil.fileExtension(input);
			log("fileExtension", input, output);
			
			// file location
			
			input = "https://subdomain.domain.com/path/script.php?val1=a&val2=b";
			output = StringUtil.fileLocation(input);
			log("fileLocation", input, output);
		}
		
		private function log(method : String, input : String, output : String, ...values) : void
		{
			var message : String = "StringUtil." + method + "()\n\n\tinput:\t" + input + "\n\toutput:\t" + output + "\n";
			_output.appendText(message + "\n");
			trace(message);
		}

	}
}

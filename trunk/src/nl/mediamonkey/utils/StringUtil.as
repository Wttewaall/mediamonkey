package nl.mediamonkey.utils {
	
	import flash.external.ExternalInterface;
	
	public class StringUtil {
		
		public static const REGEXP_TRIM					:RegExp = /^\s+|\s+$/g;
		public static const REGEXP_URL_ENCODING_SAFE	:RegExp = /(["<>\\\^\[\]'\+\$,])+/gi;
		public static const REGEXP_LEADING_ZEROES		:RegExp = /^0+/g;
		public static const REGEXP_DOUBLE_SPACES		:RegExp = /[ \t]+/g;
		public static const REGEXP_VARNAME_SEGMENTS		:RegExp = /[A-Z]?[a-z]*/g;
		public static const REGEXP_NUMBER				:RegExp = /[0-9]+(?:\.[0-9]*)?/g;
		public static const REGEXP_DATE_TIME			:RegExp = /\d{1,2}\W\d{1,2}\W\d{4}\s*\d{1,2}\W\d{2}(\W\d{2})?\s*(am|AM|pm|PM)?/g; //"MM-DD-YYYY HH:NN:SS"
		public static const REGEXP_DATE_TIME_EXT		:RegExp = /(?P<day>\d{1,2})\W(?P<month>\d{1,2})\W(?P<year>\d{4})\s*(?P<hours>\d{1,2})\W(?P<minutes>\d{2})(\W(?P<seconds>\d{2}))?\s*(?P<period>(?:am|AM|pm|PM)?)/g;
		public static const REGEXP_DATE_TIME2			:RegExp = /\d{4}\W\d{1,2}\W\d{1,2}\s*\d{1,2}\W\d{2}(\W\d{2})?\s*(am|AM|pm|PM)?/g; //"YYYY-MM-DD HH:NN:SS"
		public static const REGEXP_DATE_TIME2_EXT		:RegExp = /(?P<year>\d{4})\W(?P<month>\d{1,2})\W(?P<day>\d{1,2})\s*(?P<hours>\d{1,2})\W(?P<minutes>\d{2})(\W(?P<seconds>\d{2}))?\s*(?P<period>(?:am|AM|pm|PM)?)/g;
		public static const REGEXP_NO_HTML				:RegExp = /(?<=^|>)[^><]+?(?=<|$)/g;
		public static const REGEXP_HTML_HEX_ENTITY		:RegExp = /&#x?([0-9A-F]+);/gi;
		
		public static function trim(input:String):String {
			return input.replace(REGEXP_TRIM, "");
		}
		
		public static function truncateText(input:String, maxLength:int=50):String {
			// first n chars ending in space (complete words)
			var trunkPattern:RegExp	= new RegExp("(^.{0,"+(maxLength-4)+"}\s){1}", "g");
			return (input.length > maxLength) ? input.match(trunkPattern)[0] + "..." : input;
		}
		
		public static function isURLEncodingSafe(value:String):Boolean {
			return REGEXP_URL_ENCODING_SAFE.test(value);
		}
		
		public static function splitAtLength(value:String, length:uint):String {
			var numRows:uint = Math.ceil(value.length / length);
			var result:String = "";
			for (var i:uint=0; i<numRows; i++) {
				result += value.substr(length * i, length) + ((i == numRows - 1) ? "" : "\n");
			}
			return result;
		}
		
		public static function removeZeroesAtBegin(input:String):String {
			return input.replace(REGEXP_LEADING_ZEROES, "");
		}
		
		public static function removeDoubleSpaces(input:String):String {
			return input.replace(REGEXP_DOUBLE_SPACES, " ");
		}
		
		/**
		 * camelCaseName string to UPPER_CASE_NAME
		 */
		public static function camelToUpper(name:String):String {
			var output:String = "";
			
			var segments:Array = name.match(REGEXP_VARNAME_SEGMENTS);
			for (var i:uint=0; i<segments.length; i++) {
				output += String(segments[i]).toUpperCase();
				output += (i < segments.length-1) ? "_" : "";
			}
			
			return output;
		}
		
		public static function getCurrencySymbol(value:String):String {
			switch (value) {
				case "EUR": return "€";
				case "GBP": return "£";
				case "USD": return "$";
				case "JPY": return "¥";
				/* etc. */
				default: return value;
			}
		}
		
		public static function YYMMDDtoDate(value:String):Date {
			var date:Date = new Date();
			
			var century:String = date.getFullYear().toString().substr(0, 2)
			var year:Number = parseInt(century + value.substr(0, 2));
			var month:Number = parseInt(value.substr(2, 2))-1;
			var day:Number = parseInt(value.substr(4, 2));
			
			date.setFullYear(year, month, day);
			return date;
		}
		
		public static function CCYYMMDDtoDate(value:String):Date {
			var date:Date = new Date();
			
			var year:Number = parseInt(value.substr(0, 4));
			var month:Number = parseInt(value.substr(4, 2))-1;
			var day:Number = parseInt(value.substr(6, 2));
			
			date.setFullYear(year, month, day);
			return date;
		}
		
		public static function stringToDate(value:String):Date {
			var match:* = StringUtil.REGEXP_DATE_TIME_EXT.exec(value);
			return new Date(match.year, match.month-1, match.day, match.hours, match.minutes, match.seconds);
		}
		
		public static function stringToDate2(value:String):Date {
			var match:* = StringUtil.REGEXP_DATE_TIME2_EXT.exec(value);
			return new Date(match.year, match.month-1, match.day, match.hours, match.minutes, match.seconds);
		}
		
		public static function getURLParams():Object {
			var pageURL:String = ExternalInterface.call('window.location.href.toString');
			if (pageURL != null) {
				var index:int = pageURL.lastIndexOf("#");
				
				if (index > -1) {
					var params:Array = pageURL.substr(index+1).split("&");
					var fragment:Object = {};
					var arg:String;
					var prop:String;
					var value:String;
					
					for (var i:uint=0; i<params.length; i++) {
						arg = params[i] as String;
						prop = arg.substr(0, arg.indexOf("="));
						value = arg.substr(arg.indexOf("=")+1);
						fragment[prop] = value;
					}
					
					return fragment;
				}
			}
			return null;
		}
		
		public static function toFileSizeString(value:uint):String {
			var normalizedSize:Number;
			var unit:String;
			
			const KB:uint = 1024;
			const MB:uint = 1024 * 1024;
			const GB:uint = 1024 * 1024 * 1024;
			
			if (value < KB) {
				normalizedSize = value;
				unit = (normalizedSize == 1) ? "byte" : "bytes";
				
			} else if (value >= KB && value < MB) {
				normalizedSize = Math.round(value / KB * 100) / 100;
				unit = "KB";
				
			} else if (value >= MB && value < GB) {
				normalizedSize = Math.round(value / MB * 100) / 100;
				unit = "MB";
				
			} else if (value >= GB) {
				normalizedSize = Math.round(value / GB * 100) / 100;
				unit = "GB";
			}
			
			return normalizedSize + " " + unit;
		}
		
		public static function replaceHexEntities(input:String):String {
			var result:Object = REGEXP_HTML_HEX_ENTITY.exec(input);
			
			// replace hex entities while a result is found
			while (result != null) {
				
				// convert hex to decimal, then replace result with char from code
				input = input.replace(result[0] as String, String.fromCharCode(hexStringToValue(result[1] as String, "")))
				
				// try finding more results
				result = REGEXP_HTML_HEX_ENTITY.exec(input);
			}
			
			return input;
		}
		
		protected static function hexStringToValue(hexString:String, prefix:String="#"):uint {
			var args:Array = (prefix != "") ? hexString.split(prefix) : [hexString];
			var str:String = args[args.length-1] as String;
			
			var num:uint;
			var result:uint;
			
			for (var i:uint=0; i<str.length; i++) {
				num = parseInt("0x" + str.charAt(str.length-1-i)); // char from reversed index
				result += num * Math.pow(0x10, i);
			}
			
			return result;
		}
		
		public static function filterTags(input:String):String {
			return input.match(StringUtil.REGEXP_NO_HTML).join("");
		}
		
		private static var htmlCharCodes:Array;
		
		public static function replaceHTML(input:String):String {
			if (!htmlCharCodes) htmlCharCodes = getHTMLEntityArray();
			
			for (var code:String in htmlCharCodes) {
				input = input.replace(new RegExp(code, "g"), htmlCharCodes[code]);
			}
			
			return input;
		}
		
		public static function getHTMLEntityArray():Array {
			var charCodes:Array = new Array();
			
			charCodes["&quot;"]   = "\u0022"; // quotation mark
			charCodes["&amp;"]    = "\u0026"; // ampersand
			charCodes["&lt;"]     = "\u003C"; // less-than sign
			charCodes["&gt;"]     = "\u003E"; // greater-than sign
			charCodes["&OElig;"]  = "\u0152"; // Latin capital ligature OE
			charCodes["&oelig;"]  = "\u0153"; // Latin small ligature oe
			charCodes["&Scaron;"] = "\u0160"; // Latin capital letter S with caron
			charCodes["&scaron;"] = "\u0161"; // Latin small letter s with caron
			charCodes["&Yuml;"]   = "\u0178"; // Latin capital letter Y with diaeresis
			charCodes["&circ;"]   = "\u02C6"; // modifier letter circumflex accent
			charCodes["&tilde;"]  = "\u02DC"; // small tilde
			charCodes["&ensp;"]   = "\u2002"; // en space
			charCodes["&emsp;"]   = "\u2003"; // em space
			charCodes["&thinsp;"] = "\u2009"; // thin space
			charCodes["&zwnj;"]   = "\u200C"; // zero width non-joiner
			charCodes["&zwj;"]    = "\u200D"; // zero width joiner
			charCodes["&lrm;"]    = "\u200E"; // left-to-right mark
			charCodes["&rlm;"]    = "\u200F"; // right-to-left mark
			charCodes["&ndash;"]  = "\u2013"; // en dash
			charCodes["&mdash;"]  = "\u2014"; // em dash
			charCodes["&lsquo;"]  = "\u2018"; // left single quotation mark
			charCodes["&rsquo;"]  = "\u2019"; // right single quotation mark
			charCodes["&sbquo;"]  = "\u201A"; // single low-9 quotation mark
			charCodes["&ldquo;"]  = "\u201C"; // left double quotation mark
			charCodes["&rdquo;"]  = "\u201D"; // right double quotation mark
			charCodes["&bdquo;"]  = "\u201E"; // double low-9 quotation mark
			charCodes["&dagger;"] = "\u2020"; // dagger
			charCodes["&Dagger;"] = "\u2021"; // double dagger
			charCodes["&permil;"] = "\u2030"; // per mille sign
			charCodes["&lsaquo;"] = "\u2039"; // single left-pointing angle quotation mark
			charCodes["&rsaquo;"] = "\u203A"; // single right-pointing angle quotation mark
			charCodes["&euro;"]   = "\u20AC"; // euro sign
			
			charCodes["&nbsp;"]   = "\u00A0"; // non-breaking space
			charCodes["&iexcl;"]  = "\u00A1"; // inverted exclamation mark
			charCodes["&cent;"]   = "\u00A2"; // cent sign
			charCodes["&pound;"]  = "\u00A3"; // pound sign
			charCodes["&curren;"] = "\u00A4"; // currency sign
			charCodes["&yen;"]    = "\u00A5"; // yen sign
			charCodes["&brvbar;"] = "\u00A6"; // broken vertical bar (|)
			charCodes["&sect;"]   = "\u00A7"; // section sign
			charCodes["&uml;"]    = "\u00A8"; // diaeresis
			charCodes["&copy;"]   = "\u00A9"; // copyright sign
			charCodes["&reg;"]    = "\u00AE"; // registered sign
			charCodes["&deg;"]    = "\u00B0"; // degree sign
			charCodes["&plusmn;"] = "\u00B1"; // plus-minus sign
					// remove spaces from next three lines in actual code
			charCodes["& sup1;"]  = "\u00B9"; // superscript one
			charCodes["& sup2;"]  = "\u00B2"; // superscript two
			charCodes["& sup3;"]  = "\u00B3"; // superscript three
			charCodes["&acute;"]  = "\u00B4"; // acute accent
			charCodes["&micro;"]  = "\u00B5"; // micro sign
					// remove spaces from next three lines in actual code
			charCodes["& frac14;"] = "\u00BC"; // vulgar fraction one quarter
			charCodes["& frac12;"] = "\u00BD"; // vulgar fraction one half
			charCodes["& frac34;"] = "\u00BE"; // vulgar fraction three quarters
			charCodes["&iquest;"] = "\u00BF"; // inverted question mark
			charCodes["&Agrave;"] = "\u00C0"; // Latin capital letter A with grave
			charCodes["&Aacute;"] = "\u00C1"; // Latin capital letter A with acute
			charCodes["&Acirc;"]  = "\u00C2"; // Latin capital letter A with circumflex
			charCodes["&Atilde;"] = "\u00C3"; // Latin capital letter A with tilde
			charCodes["&Auml;"]   = "\u00C4"; // Latin capital letter A with diaeresis
			charCodes["&Aring;"]  = "\u00C5"; // Latin capital letter A with ring above
			charCodes["&AElig;"]  = "\u00C6"; // Latin capital letter AE
			charCodes["&Ccedil;"] = "\u00C7"; // Latin capital letter C with cedilla
			charCodes["&Egrave;"] = "\u00C8"; // Latin capital letter E with grave
			charCodes["&Eacute;"] = "\u00C9"; // Latin capital letter E with acute
			charCodes["&Ecirc;"]  = "\u00CA"; // Latin capital letter E with circumflex
			charCodes["&Euml;"]   = "\u00CB"; // Latin capital letter E with diaeresis
			charCodes["&Igrave;"] = "\u00CC"; // Latin capital letter I with grave
			charCodes["&Iacute;"] = "\u00CD"; // Latin capital letter I with acute
			charCodes["&Icirc;"]  = "\u00CE"; // Latin capital letter I with circumflex
			charCodes["&Iuml;"]   = "\u00CF"; // Latin capital letter I with diaeresis
			charCodes["&ETH;"]    = "\u00D0"; // Latin capital letter ETH
			charCodes["&Ntilde;"] = "\u00D1"; // Latin capital letter N with tilde
			charCodes["&Ograve;"] = "\u00D2"; // Latin capital letter O with grave
			charCodes["&Oacute;"] = "\u00D3"; // Latin capital letter O with acute
			charCodes["&Ocirc;"]  = "\u00D4"; // Latin capital letter O with circumflex
			charCodes["&Otilde;"] = "\u00D5"; // Latin capital letter O with tilde
			charCodes["&Ouml;"]   = "\u00D6"; // Latin capital letter O with diaeresis
			charCodes["&Oslash;"] = "\u00D8"; // Latin capital letter O with stroke
			charCodes["&Ugrave;"] = "\u00D9"; // Latin capital letter U with grave
			charCodes["&Uacute;"] = "\u00DA"; // Latin capital letter U with acute
			charCodes["&Ucirc;"]  = "\u00DB"; // Latin capital letter U with circumflex
			charCodes["&Uuml;"]   = "\u00DC"; // Latin capital letter U with diaeresis
			charCodes["&Yacute;"] = "\u00DD"; // Latin capital letter Y with acute
			charCodes["&THORN;"]  = "\u00DE"; // Latin capital letter THORN
			charCodes["&szlig;"]  = "\u00DF"; // Latin small letter sharp s = ess-zed
			charCodes["&agrave;"] = "\u00E0"; // Latin small letter a with grave
			charCodes["&aacute;"] = "\u00E1"; // Latin small letter a with acute
			charCodes["&acirc;"]  = "\u00E2"; // Latin small letter a with circumflex
			charCodes["&atilde;"] = "\u00E3"; // Latin small letter a with tilde
			charCodes["&auml;"]   = "\u00E4"; // Latin small letter a with diaeresis
			charCodes["&aring;"]  = "\u00E5"; // Latin small letter a with ring above
			charCodes["&aelig;"]  = "\u00E6"; // Latin small letter ae
			charCodes["&ccedil;"] = "\u00E7"; // Latin small letter c with cedilla
			charCodes["&egrave;"] = "\u00E8"; // Latin small letter e with grave
			charCodes["&eacute;"] = "\u00E9"; // Latin small letter e with acute
			charCodes["&ecirc;"]  = "\u00EA"; // Latin small letter e with circumflex
			charCodes["&euml;"]   = "\u00EB"; // Latin small letter e with diaeresis
			charCodes["&igrave;"] = "\u00EC"; // Latin small letter i with grave
			charCodes["&iacute;"] = "\u00ED"; // Latin small letter i with acute
			charCodes["&icirc;"]  = "\u00EE"; // Latin small letter i with circumflex
			charCodes["&iuml;"]   = "\u00EF"; // Latin small letter i with diaeresis
			charCodes["&eth;"]    = "\u00F0"; // Latin small letter eth
			charCodes["&ntilde;"] = "\u00F1"; // Latin small letter n with tilde
			charCodes["&ograve;"] = "\u00F2"; // Latin small letter o with grave
			charCodes["&oacute;"] = "\u00F3"; // Latin small letter o with acute
			charCodes["&ocirc;"]  = "\u00F4"; // Latin small letter o with circumflex
			charCodes["&otilde;"] = "\u00F5"; // Latin small letter o with tilde
			charCodes["&ouml;"]   = "\u00F6"; // Latin small letter o with diaeresis
			charCodes["&oslash;"] = "\u00F8"; // Latin small letter o with stroke
			charCodes["&ugrave;"] = "\u00F9"; // Latin small letter u with grave
			charCodes["&uacute;"] = "\u00FA"; // Latin small letter u with acute
			charCodes["&ucirc;"]  = "\u00FB"; // Latin small letter u with circumflex
			charCodes["&uuml;"]   = "\u00FC"; // Latin small letter u with diaeresis
			charCodes["&yacute;"] = "\u00FD"; // Latin small letter y with acute
			charCodes["&thorn;"]  = "\u00FE"; // Latin small letter thorn
			charCodes["&yuml;"]   = "\u00FF"; // Latin small letter y with diaeresis
			
			return charCodes;
		}
		
	}
}
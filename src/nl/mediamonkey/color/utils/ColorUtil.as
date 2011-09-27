package nl.mediamonkey.color.utils {
	
	/**
	 * conversion formulas originate from:
	 * http://www.easyrgb.com/index.php?X=MATH
	 */
	
	import nl.mediamonkey.color.ARGBColor;
	import nl.mediamonkey.color.CMYKColor;
	import nl.mediamonkey.color.HSLColor;
	import nl.mediamonkey.color.HSVColor;
	import nl.mediamonkey.color.IColor;
	import nl.mediamonkey.color.LABColor;
	import nl.mediamonkey.color.RGBColor;
	import nl.mediamonkey.color.XYZColor;
	import nl.mediamonkey.color.enum.HexPrefix;
	import nl.mediamonkey.utils.EnumUtil;
	
	public class ColorUtil {
		
		public static const hexPatternString	:String = "^(0x|\#|\\x|&\#x)?([0-9A-Fa-f]{1,8}?)$";
		public static const hexPattern			:RegExp = /^(0x|\#|\\x|&\#x)?([0-9A-Fa-f]{1,8}?)$/;
		
		public static function isValidHexString(hexString:String):Boolean {
			return hexPattern.test(hexString);
		}
		
		public static function getHexPrefix(hexString:String):String {
			return hexString.replace(hexPattern, "$1");
		}
		
		public static function hexStringToValue(hexString:String, prefix:String="#"):uint {
			if (!isValidHexString(hexString))
				throw new ArgumentError("invalid hexString as argument");
			
			if (!EnumUtil.hasConst(HexPrefix, prefix))
				throw new ArgumentError("invalid prefix as argument");
			
			var args:Array = (prefix != "") ? hexString.split(prefix) : [hexString];
			var str:String = args[args.length-1] as String;
			
			var num:uint;
			var result:uint;
			
			for (var i:uint=0; i<str.length; i++) {
				num = parseInt(HexPrefix.CODE + str.charAt(str.length-1-i)); // char from reversed index
				result += num * Math.pow(16, i);
			}
			
			return result;
		}
		
		public static function toHexString(value:uint, length:uint=6, prefix:String="#"):String {
			var charArray:Array = value.toString(16).toUpperCase().split("");
			var numChars:Number = charArray.length;
			
			for (var i:int=0; i<(length-numChars); i++){
				charArray.unshift("0");
			}
			
			return prefix + charArray.join("");
		}
		
		public static function getNearestColorValue(value:uint, pool:Array):uint {
			var currentRGB:RGBColor = RGBColor.fromDecimal(value);
			
			var dR:Number;
			var dG:Number;
			var dB:Number;
			var colorValue:uint;
			var distance:Number;
			var minDistance:Number = Number.POSITIVE_INFINITY;
			var minColorValue:uint;
			var nextRGB:RGBColor = new RGBColor();
			
			for (var i:uint=0; i<pool.length; i++) {
				colorValue = pool[i];
				nextRGB.fromDecimal(colorValue);
				
				dR = nextRGB.r - currentRGB.r;
				dG = nextRGB.g - currentRGB.g;
				dB = nextRGB.b - currentRGB.b;
				distance = dR*dR + dG*dG + dB*dB;
				
				if (distance == 0) {
					return nextRGB.colorValue;
					
				} else if (distance < minDistance) {
					minDistance = distance;
					minColorValue = colorValue;
					
				} else if (minColorValue == Number.POSITIVE_INFINITY) {
					minColorValue = colorValue;
				}
			}
			
			return minColorValue;
		}
		
		// ---- color methods ----
		
		public static function multiply(color1:Object, color2:Object):uint {
			var argb1:ARGBColor = ARGBColor.fromDecimal(getColorValue(color1, true));
			var argb2:ARGBColor = ARGBColor.fromDecimal(getColorValue(color2, true));
			
			return (
				((argb1.a * argb2.a / 255) << 24) |
				((argb1.r * argb2.r / 255) << 16) |
				((argb1.g * argb2.g / 255) << 8) |
				(argb1.b * argb2.b / 255)
			);
		}
		
		public static function interpolate(color1:Object, color2:Object, ratio:Number=0.5):uint {
			var rgb1:RGBColor = RGBColor.fromDecimal(getColorValue(color1));
			var rgb2:RGBColor = RGBColor.fromDecimal(getColorValue(color2));
			
			var inverseRatio:Number = 1 - ratio;
			
			var r:uint = Math.round(ratio * rgb2.r + inverseRatio * rgb1.r);
			var g:uint = Math.round(ratio * rgb2.g + inverseRatio * rgb1.g);
			var b:uint = Math.round(ratio * rgb2.b + inverseRatio * rgb1.b);
			
			return r << 16 | g << 8 | b;
		}
		
		public static function interpolate32(color1:Object, color2:Object, ratio:Number=0.5):uint {
			var argb1:ARGBColor = ARGBColor.fromDecimal(getColorValue(color1, true));
			var argb2:ARGBColor = ARGBColor.fromDecimal(getColorValue(color2, true));
			
			var inverseRatio:Number = 1 - ratio;
			
			var a:uint = Math.round(ratio * argb2.a + inverseRatio * argb1.a);
			var r:uint = Math.round(ratio * argb2.r + inverseRatio * argb1.r);
			var g:uint = Math.round(ratio * argb2.g + inverseRatio * argb1.g);
			var b:uint = Math.round(ratio * argb2.b + inverseRatio * argb1.b);
			
			return a << 24 | r << 16 | g << 8 | b;
		}
		
		/** @param saturation 0 to 1 **/
		public static function saturate(color:Object, saturation:Number):uint {
			var hsv:HSVColor = HSVColor.fromDecimal(getColorValue(color));
			hsv.s = Math.max(0, Math.min(saturation, 1)) * 100;
			return hsv.colorValue;
		}
		
		/** @param lightness 0 to 1 **/
		public static function lighten(color:Object, lightness:Number):uint {
			var hsv:HSVColor = HSVColor.fromDecimal(getColorValue(color));
			hsv.v = Math.max(0, Math.min(lightness, 1)) * 100;
			return hsv.colorValue;
		}
		
		public static function brighten(color:Object):uint {
			var baseScale:Number = 0.7;
			var argb:ARGBColor = ARGBColor.fromDecimal(getColorValue(color, true));
			
			var i:int = (1.0/(1.0-baseScale));
			
			if ( argb.r == 0 && argb.g == 0 && argb.b == 0) {
				return argb.colorValue;
			}
			
			if ( argb.r > 0 && argb.r < i ) argb.r = i;
			if ( argb.g > 0 && argb.g < i ) argb.g = i;
			if ( argb.b > 0 && argb.b < i ) argb.b = i;
			
			argb.r = Math.min(255, (argb.r / baseScale));
			argb.g = Math.min(255, (argb.g / baseScale));
			argb.b = Math.min(255, (argb.b / baseScale));
			
			return argb.colorValue;
		}
		
		public static function darken(color:Object):uint {
			var baseScale:Number = 0.7;
			var argb:ARGBColor = ARGBColor.fromDecimal(getColorValue(color, true));
			
			argb.r = Math.max(0, argb.r * baseScale);
			argb.g = Math.max(0, argb.g * baseScale);
			argb.b = Math.max(0, argb.b * baseScale);
			
			return argb.colorValue;
		}
		
		public static function desaturate(color:Object):uint {
			var argb:ARGBColor = ARGBColor.fromDecimal(getColorValue(color, true));
			
			argb.r *= 0.2125; // red band weight
			argb.g *= 0.7154; // green band weight
			argb.b *= 0.0721; // blue band weight
			
			var gray:uint = Math.min((argb.r + argb.g + argb.b), 0xff) & 0xff;
			return argb.a | (gray << 16) | (gray << 8) | gray;
		}
		
		public static function getColorValue(object:Object, argb:Boolean=false):uint {
			var color:IColor;
			
			if (object is IColor) {
				if (argb) color = ARGBColor.fromDecimal((object as IColor).colorValue);
				else color = RGBColor.fromDecimal((object as IColor).colorValue)
					
			} else if (object is Number) {
				if (argb) color = ARGBColor.fromDecimal(object as uint);
				else color = RGBColor.fromDecimal(object as uint);
			}
			
			return (color) ? color.colorValue : 0;
		}
		
		// ---- conversion methods ----
		
		public static function RGBToHSV(R:uint, G:uint, B:uint):HSVColor {
			var tR:Number = R / 255; // R from 0 to 255
			var tG:Number = G / 255; // G from 0 to 255
			var tB:Number = B / 255; // B from 0 to 255
			
			var minValue:Number = Math.min( tR, tG, tB ); // Min. value of RGB
			var maxValue:Number = Math.max( tR, tG, tB ); // Max. value of RGB
			var diff:Number = maxValue - minValue;		  // Delta RGB value
			
			var H:Number;
			var S:Number;
			var V:Number = maxValue;
			
			if ( diff == 0 ) {                      // This is a gray, no chroma...
				H = 0;                            	// HSV results from 0 to 1
				S = 0;
				
			} else {                                // Chromatic data...
				S = diff / maxValue;
			
				var dR:Number = ( ( ( maxValue - tR ) / 6 ) + ( diff / 2 ) ) / diff;
				var dG:Number = ( ( ( maxValue - tG ) / 6 ) + ( diff / 2 ) ) / diff;
				var dB:Number = ( ( ( maxValue - tB ) / 6 ) + ( diff / 2 ) ) / diff;
			
				if      ( tR == maxValue ) H = dB - dG;
				else if ( tG == maxValue ) H = ( 1 / 3 ) + dR - dB;
				else if ( tB == maxValue ) H = ( 2 / 3 ) + dG - dR;
			
				if ( H < 0 ) H += 1;
				if ( H > 1 ) H -= 1;
			}
			
			return new HSVColor(H * 360, S * 100, V * 100);
		}
		
		public static function HSVToRGB(H:uint, S:uint, V:uint):RGBColor {
			var tH:Number = H / 360; // H from 0 to 360
			var tS:Number = S / 100; // S from 0 to 100
			var tV:Number = V / 100; // V from 0 to 100
			
			if ( tS == 0 ) {
				return new RGBColor(tV * 255, tV * 255, tV * 255);
			
			} else {
				var h:Number = tH * 6;
				if ( h == 6 ) h = 0; // H must be < 1
				
				var i:int = int( h ); // or i = floor( h )
				var v1:Number = tV * ( 1 - tS );
				var v2:Number = tV * ( 1 - tS * ( h - i ) );
				var v3:Number = tV * ( 1 - tS * ( 1 - ( h - i ) ) );
				var R:Number;
				var G:Number;
				var B:Number;
				
				if      ( i == 0 ) { R = tV; G = v3; B = v1 }
				else if ( i == 1 ) { R = v2; G = tV; B = v1 }
				else if ( i == 2 ) { R = v1; G = tV; B = v3 }
				else if ( i == 3 ) { R = v1; G = v2; B = tV  }
				else if ( i == 4 ) { R = v3; G = v1; B = tV  }
				else               { R = tV; G = v1; B = v2 }
				
				return new RGBColor(R * 255, G * 255, B * 255);
			}
		}
		
		public static function RGBToHSL(R:uint, G:uint, B:uint):HSLColor {
			var tR:Number = ( R / 255 )    //RGB from 0 to 255
			var tG:Number = ( G / 255 )
			var tB:Number = ( B / 255 )
			
			var minValue:Number = Math.min( tR, tG, tB ); // Min. value of RGB
			var maxValue:Number = Math.max( tR, tG, tB ); // Max. value of RGB
			var diff:Number = maxValue - minValue;		  // Delta RGB value
			
			var H:Number;
			var S:Number;
			var L:Number = ( maxValue + minValue ) / 2
			
			if ( diff == 0 ) {								//This is a gray, no chroma...
				H = 0;										//HSL results from 0 to 1
				S = 0;
				
			} else {                                //Chromatic data...
				if ( L < 0.5 ) S = diff / ( maxValue + minValue )
				else		   S = diff / ( 2 - maxValue - minValue )
			
				var dR:Number = ( ( ( maxValue - tR ) / 6 ) + ( diff / 2 ) ) / diff
				var dG:Number = ( ( ( maxValue - tG ) / 6 ) + ( diff / 2 ) ) / diff
				var dB:Number = ( ( ( maxValue - tB ) / 6 ) + ( diff / 2 ) ) / diff
			
				if		( tR == maxValue ) H = dB - dG
				else if ( tG == maxValue ) H = ( 1 / 3 ) + dR - dB
				else if ( tB == maxValue ) H = ( 2 / 3 ) + dG - dR
				
				if ( H < 0 ) H += 1;
				if ( H > 1 ) H -= 1;
			}
			
			return new HSLColor(H * 360, S * 100, L * 255);
		}
		
		public static function HSLToRGB(h:Number, s:Number, l:Number):RGBColor {
			h /= 360;
			s /= 100;
			l /= 255;
			
			var r:Number;
			var g:Number;
			var b:Number;
			
			if (s == 0) {                     //HSL from 0 to 1
				r = g = b = l;                //RGB results from 0 to 255
				
			} else {
				var v2:Number;
				if ( l < 0.5 ) v2 = l * ( 1 + s );
				else           v2 = ( l + s ) - ( s * l );
			
				var v1:Number = 2 * l - v2
			
				r = HueToRGB( v1, v2, h + ( 1 / 3 ) );
				g = HueToRGB( v1, v2, h );
				b = HueToRGB( v1, v2, h - ( 1 / 3 ) );
			}
			
			return new RGBColor(r * 255, g * 255, b * 255);
		}
		
		public static function HueToRGB(v1:Number, v2:Number, vH:Number):Number {
			if ( vH < 0 ) vH += 1
			if ( vH > 1 ) vH -= 1
			if ( ( 6 * vH ) < 1 ) return ( v1 + ( v2 - v1 ) * 6 * vH );
			if ( ( 2 * vH ) < 1 ) return ( v2 );
			if ( ( 3 * vH ) < 2 ) return ( v1 + ( v2 - v1 ) * ( ( 2 / 3 ) - vH ) * 6 );
			return v1;
		}
		
		public static function RGBToCMYK(r:Number, g:Number, b:Number):CMYKColor {
			var c:Number = 1 - (r / 255);
			var m:Number = 1 - (g / 255);
			var y:Number = 1 - (b / 255);
			var k:Number = 1;
			
			if (c < k) k = c;
			if (m < k) k = m;
			if (y < k) k = y;
			
			if (k == 1) { //Black
				c = 0
				m = 0
				y = 0
				
			} else {
				c = (c - k) / (1 - k);
				m = (m - k) / (1 - k);
				y = (y - k) / (1 - k);
			}
			
			return new CMYKColor(c * 100, m * 100, y * 100, k * 100);
		}
		
		public static function CMYKToRGB(c:Number, m:Number, y:Number, k:Number):RGBColor {
			c /= 100;
			m /= 100;
			y /= 100;
			k /= 100;
			
			var r:Number = 1 - (c * (1 - k) + k);
			var g:Number = 1 - (m * (1 - k) + k);
			var b:Number = 1 - (y * (1 - k) + k);
			
			return new RGBColor(r * 255, g * 255, b * 255);
		}
		
		public static function RGBToXYZ(r:Number, g:Number, b:Number):XYZColor {
			r /= 255;
			g /= 255;
			b /= 255;
			 
			if (r > 0.04045){ r = Math.pow((r + 0.055) / 1.055, 2.4); }
			else { r = r / 12.92; }
			if ( g > 0.04045){ g = Math.pow((g + 0.055) / 1.055, 2.4); }
			else { g = g / 12.92; }
			if (b > 0.04045){ b = Math.pow((b + 0.055) / 1.055, 2.4); }
			else { b = b / 12.92; }
			r = r * 100;
			g = g * 100;
			b = b * 100;
			 
			//Observer. = 2°, Illuminant = D65
			var xyz:XYZColor = new XYZColor();
			xyz.x = r * 0.4124 + g * 0.3576 + b * 0.1805;
			xyz.y = r * 0.2126 + g * 0.7152 + b * 0.0722;
			xyz.z = r * 0.0193 + g * 0.1192 + b * 0.9505;
			 
			return xyz;
		}
		
		public static function XYZToLAB(x:Number, y:Number, z:Number ):LABColor {
			x /= XYZColor.MAX_X;
			y /= XYZColor.MAX_Y;
			z /= XYZColor.MAX_Z;
			 
			if ( x > 0.008856 ) { x = Math.pow( x , 1/3 ); }
			else { x = ( 7.787 * x ) + ( 16/116 ); }
			if ( y > 0.008856 ) { y = Math.pow( y , 1/3 ); }
			else { y = ( 7.787 * y ) + ( 16/116 ); }
			if ( z > 0.008856 ) { z = Math.pow( z , 1/3 ); }
			else { z = ( 7.787 * z ) + ( 16/116 ); }
			 
			var lab:LABColor = new LABColor();
			lab.l = ( 116 * y ) - 16;
			lab.a = 500 * ( x - y );
			lab.b = 200 * ( y - z );
			 
			return lab;
		}
		
		public static function LABToXYZ(l:Number, a:Number, b:Number):XYZColor {
			var y:Number = (l + 16) / 116;
			var x:Number = a / 500 + y;
			var z:Number = y - b / 200;
			 
			if ( Math.pow( y , 3 ) > 0.008856 ) { y = Math.pow( y , 3 ); }
			else { y = ( y - 16 / 116 ) / 7.787; }
			if ( Math.pow( x , 3 ) > 0.008856 ) { x = Math.pow( x , 3 ); }
			else { x = ( x - 16 / 116 ) / 7.787; }
			if ( Math.pow( z , 3 ) > 0.008856 ) { z = Math.pow( z , 3 ); }
			else { z = ( z - 16 / 116 ) / 7.787; }
			 
			return new XYZColor(XYZColor.MAX_X * x, XYZColor.MAX_Y * y, XYZColor.MAX_Z * z);
		}
		
		public static function XYZToRGB(x:Number, y:Number, z:Number):RGBColor {
			x /= 100;		  
			y /= 100;		  
			z /= 100;		  
			
			// warning: use longer numbers for more accuracy
			var r:Number = x * 3.2406 + y * -1.5372 + z * -0.4986;
			var g:Number = x * -0.9689 + y * 1.8758 + z * 0.0415;
			var b:Number = x * 0.0557 + y * -0.2040 + z * 1.0570;
			 
			if ( r > 0.0031308 ) { r = 1.055 * Math.pow( r , ( 1 / 2.4 ) ) - 0.055; }
			else { r = 12.92 * r; }
			if ( g > 0.0031308 ) { g = 1.055 * Math.pow( g , ( 1 / 2.4 ) ) - 0.055; }
			else { g = 12.92 * g; }
			if ( b > 0.0031308 ) { b = 1.055 * Math.pow( b , ( 1 / 2.4 ) ) - 0.055; }
			else { b = 12.92 * b; }
			
			return new RGBColor(uint(r * 255), uint(g * 255), uint(b * 255));
		}
		
		public static function RGBToLAB(r:uint, g:uint, b:uint):LABColor {
			var xyz:XYZColor = RGBToXYZ(r, g, b);
			return XYZToLAB(xyz.x, xyz.y, xyz.z);
		}
		
		public static function LABToRGB(l:Number, a:Number, b:Number):RGBColor {
			var xyz:XYZColor = LABToXYZ(l, a, b);
			return XYZToRGB(xyz.x, xyz.y, xyz.z);
		}
		
	}
}
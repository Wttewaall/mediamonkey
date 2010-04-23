package nl.mediamonkey.color.utils {
	
	/**
	 * conversion formulas originate from:
	 * http://www.easyrgb.com/index.php?X=MATH
	 */
	
	import nl.mediamonkey.color.CMYKColor;
	import nl.mediamonkey.color.HSLColor;
	import nl.mediamonkey.color.HSVColor;
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
			
			var args:Array = hexString.split(prefix);
			var str:String = args[args.length-1] as String;
			
			var num:uint;
			var result:uint;
			
			for (var i:uint=0; i<str.length; i++) {
				num = parseInt(HexPrefix.CODE + str.charAt(str.length-i)); // char from reversed index
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
			var currentRGB:RGBColor = new RGBColor();
			currentRGB.fromDecimal(value);
			
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
				
				dR = nextRGB.R - currentRGB.R;
				dG = nextRGB.G - currentRGB.G;
				dB = nextRGB.B - currentRGB.B;
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
		
		public static function HSLToRGB(H:Number, S:Number, L:Number):RGBColor {
			H /= 360;
			S /= 100;
			L /= 255;
			
			var R:Number;
			var G:Number;
			var B:Number;
			
			if ( S == 0 ) {                     //HSL from 0 to 1
				R = G = B = L;                   //RGB results from 0 to 255
				
			} else {
				var v2:Number;
				if ( L < 0.5 ) v2 = L * ( 1 + S );
				else           v2 = ( L + S ) - ( S * L );
			
				var v1:Number = 2 * L - v2
			
				R = HueToRGB( v1, v2, H + ( 1 / 3 ) );
				G = HueToRGB( v1, v2, H );
				B = HueToRGB( v1, v2, H - ( 1 / 3 ) );
			}
			
			return new RGBColor(R * 255, G * 255, B * 255);
		}
		
		public static function HueToRGB(v1:Number, v2:Number, vH:Number):Number {
			if ( vH < 0 ) vH += 1
			if ( vH > 1 ) vH -= 1
			if ( ( 6 * vH ) < 1 ) return ( v1 + ( v2 - v1 ) * 6 * vH );
			if ( ( 2 * vH ) < 1 ) return ( v2 );
			if ( ( 3 * vH ) < 2 ) return ( v1 + ( v2 - v1 ) * ( ( 2 / 3 ) - vH ) * 6 );
			return v1;
		}
		
		public static function RGBToCMYK(R:uint, G:uint, B:uint):CMYKColor {
			var C:Number = 1 - (R / 255);
			var M:Number = 1 - (G / 255);
			var Y:Number = 1 - (B / 255);
			var K:Number = 1;
			
			if (C < K) K = C;
			if (M < K) K = M;
			if (Y < K) K = Y;
			
			if (K == 1) { //Black
				C = 0
				M = 0
				Y = 0
				
			} else {
				C = (C - K) / (1 - K);
				M = (M - K) / (1 - K);
				Y = (Y - K) / (1 - K);
			}
			
			return new CMYKColor(C * 100, M * 100, Y * 100, K * 100);
		}
		
		public static function CMYKToRGB(C:Number, M:Number, Y:Number, K:Number):RGBColor {
			C /= 100;
			M /= 100;
			Y /= 100;
			K /= 100;
			
			var R:Number = 1 - (C * (1 - K) + K);
			var G:Number = 1 - (M * (1 - K) + K);
			var B:Number = 1 - (Y * (1 - K) + K);
			
			return new RGBColor(R * 255, G * 255, B * 255);
		}
		
		public static function RGBToXYZ(R:uint, G:uint, B:uint):XYZColor {
			//R from 0 to 255
			//G from 0 to 255
			//B from 0 to 255
			var r:Number = R/255;
			var g:Number = G/255;
			var b:Number = B/255;
			 
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
			xyz.X = r * 0.4124 + g * 0.3576 + b * 0.1805;
			xyz.Y = r * 0.2126 + g * 0.7152 + b * 0.0722;
			xyz.Z = r * 0.0193 + g * 0.1192 + b * 0.9505;
			 
			return xyz;
		}
		
		public static function XYZToLAB(X:Number, Y:Number, Z:Number ):LABColor {
			const REF_X:Number = 95.047; // Observer= 2°, Illuminant= D65
			const REF_Y:Number = 100.000;
			const REF_Z:Number = 108.883;
			
			var x:Number = X / REF_X;	
			var y:Number = Y / REF_Y;  
			var z:Number = Z / REF_Z;  
			 
			if ( x > 0.008856 ) { x = Math.pow( x , 1/3 ); }
			else { x = ( 7.787 * x ) + ( 16/116 ); }
			if ( y > 0.008856 ) { y = Math.pow( y , 1/3 ); }
			else { y = ( 7.787 * y ) + ( 16/116 ); }
			if ( z > 0.008856 ) { z = Math.pow( z , 1/3 ); }
			else { z = ( 7.787 * z ) + ( 16/116 ); }
			 
			var lab:LABColor = new LABColor();
			lab.L = ( 116 * y ) - 16;
			lab.A = 500 * ( x - y );
			lab.B = 200 * ( y - z );
			 
			return lab;
		}
		
		public static function LABToXYZ( l:Number, a:Number, b:Number ):XYZColor {
			const REF_X:Number = 95.047; // Observer= 2°, Illuminant= D65
			const REF_Y:Number = 100.000; 
			const REF_Z:Number = 108.883;
			
			var y:Number = (l + 16) / 116;
			var x:Number = a / 500 + y;
			var z:Number = y - b / 200;
			 
			if ( Math.pow( y , 3 ) > 0.008856 ) { y = Math.pow( y , 3 ); }
			else { y = ( y - 16 / 116 ) / 7.787; }
			if ( Math.pow( x , 3 ) > 0.008856 ) { x = Math.pow( x , 3 ); }
			else { x = ( x - 16 / 116 ) / 7.787; }
			if ( Math.pow( z , 3 ) > 0.008856 ) { z = Math.pow( z , 3 ); }
			else { z = ( z - 16 / 116 ) / 7.787; }
			 
			return new XYZColor(REF_X * x, REF_Y * y, REF_Z * z);
		}
		
		public static function XYZToRGB(X:Number, Y:Number, Z:Number):RGBColor {
			//X from 0 to  95.047		(Observer = 2°, Illuminant = D65)
			//Y from 0 to 100.000
			//Z from 0 to 108.883
			var x:Number = X / 100;		  
			var y:Number = Y / 100;		  
			var z:Number = Z / 100;		  
			
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
		
		public static function RGBToLAB(R:uint, G:uint, B:uint):LABColor {
			var xyz:XYZColor = RGBToXYZ(R, G, B);
			return XYZToLAB(xyz.X, xyz.Y, xyz.Z);
		}
		
		public static function LABToRGB(L:Number, A:Number, B:Number):RGBColor {
			var xyz:XYZColor = LABToXYZ(L, A, B);
			return XYZToRGB(xyz.X, xyz.Y, xyz.Z);
		}
		
	}
}
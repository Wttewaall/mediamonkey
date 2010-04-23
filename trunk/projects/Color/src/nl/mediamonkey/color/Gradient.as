package nl.mediamonkey.color {
	
	import nl.mediamonkey.color.HSLColor;
	import nl.mediamonkey.color.RGBColor;
	
	public class Gradient {
		
		public var colors:Array;
		public var alphas:Array;
		public var ratios:Array;
		
		public function Gradient(colors:Array=null, alphas:Array=null, ratios:Array=null) {
			this.colors = colors || [];
			this.alphas = alphas || [];
			this.ratios = ratios || [];
		}
		
		public function toString():String {
			return "[Gradient colors:"+colors+", alphas:"+alphas+", ratios:"+ratios+"]";
		}
		
		public static function createColorAlphaRange(color1:uint, color2:uint, alpha1:uint=1, alpha2:uint=1, interval:uint=2):Gradient {
			var gradient:Gradient = new Gradient();
			var diffAlpha:Number = alpha2 - alpha1;
			
			for (var i:uint=0; i<=interval; i++) {
				gradient.colors.push(interpolate(color1, color2, i/interval));
				gradient.alphas.push(alpha1 + (diffAlpha/interval) * i);
				gradient.ratios.push((0xFF/interval) * i);
			}
			
			return gradient;
		}
		
		public static function createGradientRange(colors:Array, interpolationInterval:uint=0):Gradient {
			var numColors:uint = colors.length;
			if (numColors < 2) throw new ArgumentError("array must contain at least 2 colors");
			
			var gradient:Gradient = new Gradient();
			var color1:uint;
			var color2:uint;
			
			for (var i:uint=0; i<numColors-1; i++) {
				color1 = getColorValue(colors[i]);
				color2 = getColorValue(colors[i+1]);
				
				if (interpolationInterval > 0) {
					
					for (var j:uint=0; j<=interpolationInterval+1; j++) {
						gradient.colors.push(interpolate(color1, color2, j/(interpolationInterval+1)));
						gradient.alphas.push(1);
						gradient.ratios.push((0xFF/numColors * i) + 0xFF/numColors/interpolationInterval * j);
					}
					
				} else {
					if (i == 0) {
						gradient.colors.push(color1);
						gradient.alphas.push(1);
						gradient.ratios.push(0);
					}
					
					gradient.colors.push(color2);
					gradient.alphas.push(1);
					gradient.ratios.push(0xFF/numColors * (i+2));
				}
			}
			
			return gradient;
		}
		
		protected static function getColorValue(value:Object):uint {
			var type:String = typeof(value);
			
			switch (type) {
				case "number": return uint(value);
				case "IColor": return IColor(value).colorValue;
				default: return 0;
			}
		}
		
		public static function getHueColors():Array {
			var colors:Array = [];
			var interval:uint = 12; // max 15
			
			var hsv:HSLColor = new HSLColor(0, 100, 127);
			for (var i:uint=0; i<=interval; i++) {
				hsv.H = (360/interval) * i;
				colors.push(hsv.colorValue);
			}
			return colors;
		}
		
		public static function interpolate(color1:uint, color2:uint, t:Number):uint {
			var c1:RGBColor = new RGBColor().fromDecimal(color1) as RGBColor;
			var c2:RGBColor = new RGBColor().fromDecimal(color2) as RGBColor;
			var result:RGBColor = new RGBColor();
			
			var it:Number = 1-t;
			result.R = Math.round(t * c2.R + it * c1.R);
			result.G = Math.round(t * c2.G + it * c1.G);
			result.B = Math.round(t * c2.B + it * c1.B);
			
			return result.colorValue;
		}
		
	}
}
package nl.mediamonkey.color {
	
	import nl.mediamonkey.color.HSLColor;
	import nl.mediamonkey.color.RGBColor;
	import nl.mediamonkey.color.utils.ColorUtil;
	
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
		
		public static function createColorAlphaRange(value1:uint, value2:uint, alpha1:Number=1, alpha2:Number=1, stops:uint=1):Gradient {
			var gradient:Gradient = new Gradient();
			var a:Number = (alpha2 - alpha1) / stops;
			var r:Number = 0xFF / stops;
			
			for (var i:uint=0; i<=stops; i++) {
				gradient.colors.push(ColorUtil.interpolate(value1, value2, i/stops));
				gradient.alphas.push(alpha1 + a * i);
				gradient.ratios.push(r * i);
			}
			
			return gradient;
		}
		
		public static function createGradientRange(colors:Array, interpolationInterval:uint=0):Gradient {
			var numColors:uint = colors.length;
			if (numColors < 2) throw new ArgumentError("array must contain at least 2 colors");
			
			var gradient:Gradient = new Gradient();
			var value1:uint;
			var value2:uint;
			
			for (var i:uint=0; i<numColors-1; i++) {
				value1 = ColorUtil.getColorValue(colors[i]);
				value2 = ColorUtil.getColorValue(colors[i+1]);
				
				if (interpolationInterval > 0) {
					
					for (var j:uint=0; j<=interpolationInterval+1; j++) {
						gradient.colors.push(ColorUtil.interpolate(value1, value2, j/(interpolationInterval+1)));
						gradient.alphas.push(1);
						gradient.ratios.push((0xFF/numColors * i) + 0xFF/numColors/interpolationInterval * j);
					}
					
				} else {
					if (i == 0) {
						gradient.colors.push(value1);
						gradient.alphas.push(1);
						gradient.ratios.push(0);
					}
					
					gradient.colors.push(value2);
					gradient.alphas.push(1);
					gradient.ratios.push(0xFF/numColors * (i+2));
				}
			}
			
			return gradient;
		}
		
		// max stops is 15
		public static function getHueColors(stops:uint = 12):Array {
			var colors:Array = []; 
			
			var hsv:HSLColor = new HSLColor(0, 100, 127);
			for (var i:uint=0; i<=stops; i++) {
				hsv.h = (360/stops) * i;
				colors.push(hsv.colorValue);
			}
			return colors;
		}
		
	}
}
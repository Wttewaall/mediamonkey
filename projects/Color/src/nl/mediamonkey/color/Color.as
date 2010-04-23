package nl.mediamonkey.color {
	
	import nl.mediamonkey.color.utils.ColorUtil;
	
	public class Color implements IColor {
		
		// ---- getters & setters ----
		
		private var _colorValue:uint;
		
		[Bindable]
		public function get colorValue():uint {
			return _colorValue;
		}
		
		public function set colorValue(value:uint):void {
			if (_colorValue != value) {
				_colorValue = value;
				fromDecimal(value);
			}
		}
		
		public function setColorValue(value:uint):void {
			_colorValue = value;
		}
		
		// ---- conversion methods ----
		
		public function fromDecimal(value:uint):IColor {
			throw new Error("Class must override fromDecimal method");
		}
		
		public function toDecimal():uint {
			throw new Error("Class must override toDecimal method");
		}
		
		// ---- more conversion methods ----
		
		public function toString():String {
			return "[Color value:"+colorValue+"]";
		}
		
		public function toHexString(prefix:String="#"):String {
			return ColorUtil.toHexString(colorValue, 6, prefix);
		}
		
		public function toRGBColor():RGBColor {
			var color:RGBColor = new RGBColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toHexColor():HexColor {
			var color:HexColor = new HexColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toCMYKColor():CMYKColor {
			var color:CMYKColor = new CMYKColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toHSVColor():HSVColor {
			var color:HSVColor = new HSVColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toHSLColor():HSLColor {
			var color:HSLColor = new HSLColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toXYZColor():XYZColor {
			var color:XYZColor = new XYZColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		public function toLABColor():LABColor {
			var color:LABColor = new LABColor();
			color.fromDecimal(colorValue);
			return color;
		}
		
		// ---- color manipulation ----
		
		public function lighten(scale:Number):Color {
			return null;
		}
		
		public function darken(scale:Number):Color {
			return null;
		}
		
		public function saturate(scale:Number):Color {
			return null;
		}
		
		public function deSaturate(scale:Number):Color {
			return null;
		}
		
		public function invert():Color {
			return null;
		}
		
		public function multiply(color:Color):Color {
			return null;
		}
		
		public function tint(color:Color):Color {
			return null;
		}
		

	}
}
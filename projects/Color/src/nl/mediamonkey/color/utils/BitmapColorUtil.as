package nl.mediamonkey.color.utils {
	
	public class BitmapColorUtil {
		
		// modes
		public static function Greyscale():void {}
		public static function Duotone():void {}
		public static function Indexed():void {} // first convert to greytone
		public static function RGB():void {}
		public static function CMYC():void {}
		public static function LAB():void {}
		public static function HSB():void {}
		
		// methods
		public static function invert(bitmapDrawable:IBitmapDrawable):Bitmap {}
		public static function brighten
		public static function darken
		public static function saturate
		public static function deSaturate
		public static function hue
		
		
	}
}
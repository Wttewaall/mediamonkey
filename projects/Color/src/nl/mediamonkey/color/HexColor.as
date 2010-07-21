package nl.mediamonkey.color {
	import nl.mediamonkey.color.enum.HexPrefix;
	import nl.mediamonkey.color.utils.ColorUtil;
	import nl.mediamonkey.utils.EnumUtil;
	
	
	public class HexColor extends Color {
		
		// ---- getters & setters ----
		
		private var _prefix			:String;
		private var _hex			:String;
		
		public function get prefix():String {
			return ColorUtil.getHexPrefix(hex);
		}
		
		public function set prefix(value:String):void {
			if (!EnumUtil.hasConst(HexPrefix, value))
				throw new ArgumentError("invalid prefix value; choose a type from HexPrefix");
			
			var arr:Array = _hex.split(_prefix);
			_hex = value + String(arr.pop());
			
			_prefix = value;
		}
		
		public function get hex():String {
			return _hex;
		}
		
		public function set hex(value:String):void {
			if (_hex != value) {
				_hex = value;
				setColorValue(toDecimal());
			}
		}
		
		// ---- constructor ----
		
		public function HexColor(value:*="#000000") {
			var type:String = typeof(value);
			
			if (value is String) {
				value = parseInt(value);
				setColorValue(value);
				_hex = ColorUtil.toHexString(value);
				
			} else if (value is Number) {
				setColorValue(value as Number);
				_hex = ColorUtil.toHexString(value);
				
			} else {
				throw new TypeError("invalid value type as argument ("+type+"), type must be either Number or String");
			} 
		}
		
		// ---- conversion methods ----
		
		public function fromString(value:String):void {
			hex = value;
		}
		
		public static function fromDecimal(value:uint):HexColor {
			var color:HexColor = new HexColor();
			color.fromDecimal(value);
			return color;
		}
		
		override public function fromDecimal(value:uint):void {
			setColorValue(value);
		}
		
		override public function toDecimal():uint {
			return ColorUtil.hexStringToValue(hex, prefix);
		}
		
		override public function toString():String {
			return "[HexColor "+_hex+"]";
		}
		
	}
}
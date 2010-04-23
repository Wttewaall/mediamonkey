package nl.mediamonkey.color {
	
	public class RGBColor extends Color {
		
		// ---- getters & setters ----
		
		private var _R			:uint; // 0 to 255
		private var _G			:uint; // 0 to 255
		private var _B			:uint; // 0 to 255
		
		public function get R():uint {
			return _R;
		}
		
		public function set R(value:uint):void {
			if (_R != value) {
				_R = Math.max(0, Math.min(value, 255));
				setColorValue(toDecimal());
			}
		}
		
		public function get G():uint {
			return _G;
		}
		
		public function set G(value:uint):void {
			if (_G != value) {
				_G = Math.max(0, Math.min(value, 255));
				setColorValue(toDecimal());
			}
		}
		
		public function get B():uint {
			return _B;
		}
		
		public function set B(value:uint):void {
			if (_B != value) {
				_B = Math.max(0, Math.min(value, 255));
				setColorValue(toDecimal());
			}
		}
		
		// ---- constructor ----
		
		public function RGBColor(R:uint=0, G:uint=0, B:uint=0) {
			_R = Math.max(0, Math.min(R, 255));
			_G = Math.max(0, Math.min(G, 255));
			_B = Math.max(0, Math.min(B, 255));
			setColorValue(toDecimal());
		}
		
		// ---- conversion methods ----
		
		override public function fromDecimal(value:uint):IColor {
			setColorValue(value);
			
			if (value < 0 || value > 0xFFFFFF)
				throw new ArgumentError("invalid value, input must be a value between 0 and 16777215");
			
			_R = value >> 16;
			_G = value >> 8 & 0xFF;
			_B = value & 0xFF;
			
			return new RGBColor(R, G, B);
		}
		
		override public function toDecimal():uint {
			return R << 16 | G << 8 | B;
		}
		
		override public function toString():String {
			return "[RGBColor R:"+R+" G:"+G+" B:"+B+"]";
		}
		
	}
}
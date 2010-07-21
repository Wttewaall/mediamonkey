package nl.mediamonkey.color {
	
	public interface IColor {
		
		// ---- getters & setters ----
		
		function get colorValue():uint;
		function set colorValue(value:uint):void;
		
		// ---- public methods ----
		
		function fromDecimal(value:uint):void;
		function toDecimal():uint;
		function toString():String;
		function toHexString(prefix:String="#"):String;
		
	}
}
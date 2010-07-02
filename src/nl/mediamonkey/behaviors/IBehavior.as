package nl.mediamonkey.behaviors {
	
	import flash.display.InteractiveObject;
	
	public interface IBehavior {
		
		/** The target on which the behaviour has effect */
		function get target():InteractiveObject;
		function set target(value:InteractiveObject):void;
		
		/** enabled property */
		function get enabled():Boolean;
		function set enabled(value:Boolean):void;
		
		/** enabled method */
		function enable():void;
		
		/** disabled method */
		function disable():void;
	}
}
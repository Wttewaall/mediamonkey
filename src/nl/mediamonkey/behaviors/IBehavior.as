package nl.mediamonkey.behaviors {
	
	import flash.display.InteractiveObject;
	import flash.events.IEventDispatcher;
	
	public interface IBehavior extends IEventDispatcher {
		
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
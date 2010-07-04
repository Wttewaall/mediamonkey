package nl.mediamonkey.behaviors {
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.IMXMLObject;
	
	/**
	 * A behavior is a class that injects logic into an InteractiveObject as a target by means of event listeners.
	 */
	
	public class Behavior extends EventDispatcher implements IBehavior, IMXMLObject {
		
		private var document:Object;
		
		// ---- getters & setters ----
		
		private var _target		:InteractiveObject;
		private var _enabled	:Boolean = true;
		
		[Bindable]
		public function get target():InteractiveObject {
			return _target;
		}
		
		public function set target(value:InteractiveObject):void {
			if (_target == value) return;
			
			if (_target != null) disable();
			_target = value;
			
			if (_target != null) {
				if (value.stage) addedToStageHandler();
				else value.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
		}
		
		[Bindable]
		public function get enabled():Boolean {
			return _enabled
		}
		
		public function set enabled(value:Boolean):void {
			if (_enabled != value) {
				_enabled = value;
				
				if (_enabled) addListeners(target);
				else removeListeners(target);
			}
		}
		
		// ---- constructor ----
		
		public function Behavior(target:InteractiveObject = null) {
			this.target = target;
		}
		
		// ---- public methods ----
		
		public function initialized(document:Object, id:String):void {
			this.document = document;
		}
		
		public function enable():void {
			enabled = true;
		}
		
		public function disable():void {
			enabled = false;
		}
		
		// ---- protected methods ----
		
		protected function addListeners(target:InteractiveObject):void {
			removeListeners(target);
		}
		
		protected function removeListeners(target:InteractiveObject):void {
		}
		
		// ---- event handlers ----
		
		protected function addedToStageHandler(event:Event = null):void {
			target.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			if (enabled) addListeners(target);
			else removeListeners(target);
		}
		
	}
}
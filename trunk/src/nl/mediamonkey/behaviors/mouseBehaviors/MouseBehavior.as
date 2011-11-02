package nl.mediamonkey.behaviors.mouseBehaviors {
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.Application;
	import mx.events.SandboxMouseEvent;
	
	import nl.mediamonkey.behaviors.events.MouseBehaviorEvent;
	
	[Event(name="mouseDown", type="nl.mediamonkey.behaviors.events.MouseBehaviorEvent")]
	[Event(name="mouseUp", type="nl.mediamonkey.behaviors.events.MouseBehaviorEvent")]
	[Event(name="mouseMove", type="nl.mediamonkey.behaviors.events.MouseBehaviorEvent")]
	[Event(name="dragStart", type="nl.mediamonkey.behaviors.events.MouseBehaviorEvent")]
	[Event(name="dragMove", type="nl.mediamonkey.behaviors.events.MouseBehaviorEvent")]
	[Event(name="dragEnd", type="nl.mediamonkey.behaviors.events.MouseBehaviorEvent")]
	
	/* TODO: add cursor logic for mouseOver? */
	
	public class MouseBehavior extends Behavior {
		
		// ---- public variables ----
		
		public var useGlobalSpace			:Boolean = false;
		
		// ---- protected variables ----
		
		protected var dispatcher			:IEventDispatcher;
		protected var sandboxRoot			:DisplayObject;
		protected var mouseOver				:Boolean;
		protected var mouseDown				:Boolean;
		protected var origin				:Point;
		protected var downPoint				:Point;
		protected var dragging				:Boolean;
		
		// ---- getters & setters ----
		
		private var _dispatchFromTarget		:Boolean;
		
		public function get dispatchFromTarget():Boolean {
			return _dispatchFromTarget;
		}
		
		public function set dispatchFromTarget(value:Boolean):void {
			_dispatchFromTarget = value;
			dispatcher = (value && target) ? target : this;
		}
		
		public function get isMouseOver():Boolean {
			return mouseOver;
		}
		
		public function get isMouseDown():Boolean {
			return mouseDown;
		}
		
		public function get isDragging():Boolean {
			return dragging;
		}
		
		// ---- constructor ----
		
		public function MouseBehavior(target:InteractiveObject = null, dispatchFromTarget:Boolean = true) {
			this.target = target;
			this.dispatchFromTarget = dispatchFromTarget;
			
			sandboxRoot = Application.application.systemManager.getSandboxRoot();
		}
		
		// ---- protected methods ----
		
		override protected function addedToStageHandler(event:Event = null):void {
			super.addedToStageHandler(event);
			if (_dispatchFromTarget) dispatchFromTarget = true;
		}
		
		override protected function addListeners(target:InteractiveObject):void {
			super.addListeners(target);
			target.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
		}
		
		override protected function removeListeners(target:InteractiveObject):void {
			super.removeListeners(target);
			target.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		protected function startDragging():void {
			if (!dragging) {
				dragging = true;
				
				sandboxRoot.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
				sandboxRoot.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
				sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
				
				dispatcher.dispatchEvent(new MouseBehaviorEvent(MouseBehaviorEvent.DRAG_START, this, false, false, downPoint.x, downPoint.y));
			}
		}
		
		protected function stopDragging():void {
			if (dragging) {
				dragging = false;
				
				sandboxRoot.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
				sandboxRoot.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
				sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
				
				dispatcher.dispatchEvent(new MouseBehaviorEvent(MouseBehaviorEvent.DRAG_END, this, false, false, downPoint.x, downPoint.y));
			}
		}
		
		protected function resetMouseVariables():void {
			origin = null;
			downPoint = null;
		}
		
		// ---- event handlers ----
		
		protected function rollOverHandler(event:MouseEvent):void {
			mouseOver = true;
		}
		
		protected function rollOutHandler(event:MouseEvent):void {
			mouseOver = false;
		}
		
		protected function mouseDownHandler(event:MouseEvent):void {
			mouseDown = true;
			
			if (enabled) {
				origin = new Point(target.x, target.y);
				if (useGlobalSpace) origin = target.parent.localToGlobal(origin);
				
				downPoint = new Point(target.parent.mouseX, target.parent.mouseY);
				if (useGlobalSpace) downPoint = target.parent.localToGlobal(downPoint);
				
				if (!dragging) startDragging();
			}
		}
		
		protected function mouseMoveHandler(event:MouseEvent):void {
			dispatcher.dispatchEvent(new MouseBehaviorEvent(MouseBehaviorEvent.MOUSE_MOVE, this, false, false, downPoint.x, downPoint.y));
			dispatcher.dispatchEvent(new MouseBehaviorEvent(MouseBehaviorEvent.DRAG_MOVE, this, false, false, downPoint.x, downPoint.y));
			
			/*var current:Point = new Point(target.parent.mouseX, target.parent.mouseY);
			if (useGlobalSpace) current = target.parent.localToGlobal(current);
			trace("mouse:", current);*/
		}
		
		protected function mouseUpHandler(event:MouseEvent):void {
			mouseDown = false;
			stopDragging();
			resetMouseVariables();
		}
		
		protected function mouseUpSomewhereHandler(event:SandboxMouseEvent):void {
			mouseDown = false;
			stopDragging();
			resetMouseVariables();
		}
		
	}
}
package nl.mediamonkey.behaviors {
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.FlexGlobals;
	import mx.events.SandboxMouseEvent;
	
	import nl.mediamonkey.behaviors.events.MoveEvent;
	import nl.mediamonkey.utils.CoordsUtil;
	
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
			
			sandboxRoot = FlexGlobals.topLevelApplication.systemManager.getSandboxRoot();
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
				
				dispatcher.dispatchEvent(new MoveEvent(MoveEvent.DRAG_START));
			}
		}
		
		protected function stopDragging():void {
			if (dragging) {
				dragging = false;
				
				sandboxRoot.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
				sandboxRoot.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
				sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
				
				dispatcher.dispatchEvent(new MoveEvent(MoveEvent.DRAG_END));
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
				if (useGlobalSpace) origin = CoordsUtil.localToGlobal(target, origin);
				
				downPoint = new Point(target.parent.mouseX, target.parent.mouseY);
				if (useGlobalSpace) downPoint = CoordsUtil.localToGlobal(target, downPoint);
				
				if (!dragging) startDragging();
			}
		}
		
		protected function mouseMoveHandler(event:MouseEvent):void {
			dispatcher.dispatchEvent(new MoveEvent(MoveEvent.MOVE));
			
			/*var current:Point = new Point(target.parent.mouseX, target.parent.mouseY);
			if (useGlobalSpace) current = CoordsUtil.localToGlobal(target, current);
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
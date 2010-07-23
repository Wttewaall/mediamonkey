package nl.mediamonkey.behaviors {
	
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.events.SandboxMouseEvent;
	
	import nl.mediamonkey.behaviors.events.MoveEvent;
	import nl.mediamonkey.utils.CoordsUtil;
	
	/**
	 * The ScrubBehavior makes a DisplayObject Scrubable.
	 * That means that MouseEvent.CLICK events will be dispatched on the DisplayObject when you are scrubbing over the Object.
	 * Scrubbing means: moving the mouse while pressing.
	 */
	public class ScrubBehavior extends MouseBehavior {
		
		protected var position:Point;
		
		// ---- constructor ----
		
		public function ScrubBehavior(target:InteractiveObject = null, dispatchFromTarget:Boolean = true) {
			super(target, dispatchFromTarget);
		}
		
		override protected function addListeners(target:InteractiveObject):void {
			trace(">>addListeners", target.name);
			super.addListeners(target);
		}
		
		override protected function removeListeners(target:InteractiveObject):void {
			super.removeListeners(target);
		}
		
		// ---- event handlers ----
		
		override protected function mouseDownHandler(event:MouseEvent):void {
			trace("mouseDownHandler");
			super.mouseDownHandler(event);
			dispatchClickEvent();
		}
		
		override protected function mouseMoveHandler(event:MouseEvent):void {
			trace("mouseMoveHandler");
			super.mouseMoveHandler(event);
			if (dragging) dispatchClickEvent();
		}
		
		override protected function mouseUpHandler(event:MouseEvent):void {
			trace("mouseUpHandler");
			super.mouseUpHandler(event);
			dispatchClickEvent();
		}
		
		override protected function mouseUpSomewhereHandler(event:SandboxMouseEvent):void {
			trace("mouseUpSomewhereHandler");
			super.mouseUpSomewhereHandler(event);
			dispatchClickEvent();
		}
		
		// ---- protected methods ----
		
		protected function dispatchClickEvent():void {
			position = new Point(target.mouseX, target.mouseY);
			if (useGlobalSpace) position = CoordsUtil.localToGlobal(target, position);
			
			target.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, position.x, position.y));
		}
	}
}
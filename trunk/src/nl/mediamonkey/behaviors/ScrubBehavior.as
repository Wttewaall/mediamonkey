package nl.mediamonkey.behaviors {
	
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.events.SandboxMouseEvent;
	
	import nl.mediamonkey.behaviors.events.MoveEvent;
	
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
		
		// ---- event handlers ----
		
		override protected function mouseDownHandler(event:MouseEvent):void {
			super.mouseDownHandler(event);
			dispatchClickEvent();
		}
		
		override protected function mouseMoveHandler(event:MouseEvent):void {
			super.mouseMoveHandler(event);
			if (dragging) dispatchClickEvent();
		}
		
		override protected function mouseUpHandler(event:MouseEvent):void {
			super.mouseUpHandler(event);
			dispatchClickEvent();
		}
		
		override protected function mouseUpSomewhereHandler(event:SandboxMouseEvent):void {
			super.mouseUpSomewhereHandler(event);
			dispatchClickEvent();
		}
		
		// ---- protected methods ----
		
		protected function dispatchClickEvent():void {
			position = new Point(target.mouseX, target.mouseY);
			if (useGlobalSpace) position = target.parent.localToGlobal(position);
			
			target.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, position.x, position.y));
		}
	}
}
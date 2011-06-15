package nl.mediamonkey.behaviors {
	
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.events.SandboxMouseEvent;
	
	import nl.mediamonkey.behaviors.events.DrawBehaviorEvent;
	
	[Event(name="penDown",	type="nl.mediamonkey.behaviors.events.DrawBehaviorEvent")]
	[Event(name="penUp",	type="nl.mediamonkey.behaviors.events.DrawBehaviorEvent")]
	[Event(name="draw",		type="nl.mediamonkey.behaviors.events.DrawBehaviorEvent")]
	
	/**
	 * The ScrubBehavior makes a DisplayObject Scrubable.
	 * That means that MouseEvent.CLICK events will be dispatched on the DisplayObject when you are scrubbing over the Object.
	 * Scrubbing means: moving the mouse while pressing.
	 */
	public class DrawBehavior extends MouseBehavior {
		
		protected var position:Point;
		
		// ---- constructor ----
		
		public function DrawBehavior(target:InteractiveObject = null, dispatchFromTarget:Boolean = true) {
			super(target, dispatchFromTarget);
		}
		
		// ---- event handlers ----
		
		override protected function mouseDownHandler(event:MouseEvent):void {
			super.mouseDownHandler(event);
			
			position = getPosition();
			dispatcher.dispatchEvent(new DrawBehaviorEvent(DrawBehaviorEvent.PEN_DOWN, position.x, position.y));
		}
		
		override protected function mouseMoveHandler(event:MouseEvent):void {
			super.mouseMoveHandler(event);
			
			if (dragging) {
				position = getPosition();
				dispatcher.dispatchEvent(new DrawBehaviorEvent(DrawBehaviorEvent.DRAW, position.x, position.y));
			}
		}
		
		override protected function mouseUpHandler(event:MouseEvent):void {
			super.mouseUpHandler(event);
			
			position = getPosition();
			dispatcher.dispatchEvent(new DrawBehaviorEvent(DrawBehaviorEvent.PEN_UP, position.x, position.y));
		}
		
		override protected function mouseUpSomewhereHandler(event:SandboxMouseEvent):void {
			super.mouseUpSomewhereHandler(event);
			
			position = getPosition();
			dispatcher.dispatchEvent(new DrawBehaviorEvent(DrawBehaviorEvent.PEN_UP, position.x, position.y));
		}
		
		// ---- protected methods ----
		
		protected function getPosition():Point {
			var point:Point = new Point(target.mouseX, target.mouseY);
			if (useGlobalSpace) point = target.parent.localToGlobal(point);
			return point;
		}
	}
}
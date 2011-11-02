/**
 * @author Bart Wttewaall, email: bart[at]mediamonkey.nl
 * Copyright © 2010 Mediamonkey
 */ 

package nl.mediamonkey.behaviors.mouseBehaviors {
	
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import nl.mediamonkey.behaviors.enum.Direction;
	import nl.mediamonkey.behaviors.events.MouseBehaviorEvent;
	import nl.mediamonkey.utils.CoordsUtil;
	
	/** Fires on the element for the movable behavior when the user first starts a drag operation.
	 * @eventType mx.events.DragEvent.DRAG_START */
	[Event(name="dragStart", type="nl.mediamonkey.behaviors.events.MouseBehaviorEvent")]
	
	/** Fires for the movable behavior when the user continuously drags an element.
	 * @eventType mx.events.MoveEvent.MOVE */
	[Event(name="dragMove", type="nl.mediamonkey.behaviors.events.MouseBehaviorEvent")]
	
	/** Fires on the element for the movable behavior when the user ends a drag operation.
	 * @eventType mx.events.DragEvent.DRAG_COMPLETE */
	[Event(name="dragEnd", type="nl.mediamonkey.behaviors.events.MouseBehaviorEvent")]
	
	/**
	 * A behavior that injects move logic into an InteractiveObject as a target.
	 * This workings of this class are highly adaptable through the many properties.
	 */
	public class MoveBehavior extends MouseBehavior {
		
		// ---- bindable variables ----
		
		[Bindable]
		[Inspectable(defaultValue="horizontal", category="Common", verbose=1, enumeration="all,horizontal,vertical")]
		/** Specifies the direction in which an element can be moved for the movable behavior. */
		public var direction		:String = Direction.ALL;
		
		[Bindable]
		/** Sets or retrieves the boundaries that the object can move within based on a composite value of the LEFT, TOP, RIGHT, and BOTTOM attributes for the movable behavior. */
		public var bounds			:Rectangle;
		
		// ---- constructor ----
		
		public function MoveBehavior(target:InteractiveObject = null, dispatchFromTarget:Boolean = true) {
			super(target, dispatchFromTarget);
		}
		
		// ---- protected methods ----
		
		override protected function addListeners(target:InteractiveObject):void {
			super.addListeners(target);
			
			target.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
			target.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
		}
		
		override protected function removeListeners(target:InteractiveObject):void {
			super.removeListeners(target);
			
			target.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			target.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		protected function drag():void {
			var oldPosition:Point = new Point(target.x, target.y);
			
			var position:Point = new Point(target.parent.mouseX, target.parent.mouseY);
			if (useGlobalSpace) position = CoordsUtil.localToGlobal(target, position);
			
			var dx:Number = position.x - downPoint.x;
			var dy:Number = position.y - downPoint.y;
			
			moveTo(origin.x + dx, origin.y + dy);
			
			dispatcher.dispatchEvent(new MouseBehaviorEvent(MouseBehaviorEvent.DRAG_MOVE, this, false, false, oldPosition.x, oldPosition.y));
		}
		
		// ---- public methods ----
		
		/** Moves the upper-left corner of the element to the specified location for the movable behavior. */
		public function moveTo(x:Number, y:Number):void {
			var oldPosition:Point = new Point(target.x, target.y);
			
			var position:Point = new Point(x, y);
			if (useGlobalSpace) position = CoordsUtil.globalToLocal(target, position);
			
			var moveX:Boolean = (direction == Direction.ALL || direction == Direction.HORIZONTAL);
			var moveY:Boolean = (direction == Direction.ALL || direction == Direction.VERTICAL);
			
			if (bounds != null) {
				if (moveX) target.x = Math.max(bounds.left, Math.min(position.x, bounds.right - target.width));
				if (moveY) target.y = Math.max(bounds.top, Math.min(position.y, bounds.bottom - target.height));
				
			} else {
				if (moveX) target.x = position.x;
				if (moveY) target.y = position.y;
			}
			
			dispatcher.dispatchEvent(new MouseBehaviorEvent(MouseBehaviorEvent.DRAG_MOVE, this, false, false, oldPosition.x, oldPosition.y));
		}
		
		// ---- event handlers ----
		
		override protected function mouseMoveHandler(event:MouseEvent):void {
			super.mouseMoveHandler(event);
			if (dragging) drag();
		}
		
	}
}
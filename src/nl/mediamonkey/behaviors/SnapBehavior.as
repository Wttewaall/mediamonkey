/**
 * @author Bart Wttewaall, email: bart[at]mediamonkey.nl
 * Copyright © 2010 Mediamonkey
 */ 

package nl.mediamonkey.behaviors {
	
	import designtool.view.components.GuideLine;
	
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.FlexGlobals;
	import mx.core.IUIComponent;
	import mx.events.SandboxMouseEvent;
	
	import nl.mediamonkey.behaviors.data.SnapResult;
	import nl.mediamonkey.behaviors.enum.Direction;
	import nl.mediamonkey.behaviors.enum.SnapAccuracy;
	import nl.mediamonkey.behaviors.events.MoveEvent;
	import nl.mediamonkey.behaviors.events.SnapEvent;
	import nl.mediamonkey.utils.CoordsUtil;
	import nl.mediamonkey.utils.DrawUtil;
	
	/**
	 * A behavior that injects move logic into an InteractiveObject as a target.
	 * This workings of this class are highly adaptable through the many properties.
	 */
	public class SnapBehavior extends MoveBehavior {
		
		// ---- bindable variables ----
		
		[Bindable]
		/** Sets or retrieves the composite values of the horizontal and vertical grid the element snaps to when the snapable attribute is enabled for the movable behavior.
		 * <p>The x and y properties are used as the grid's offset, the width and height properties are used as the cell's width and height</p>
		 * <p>Adding a grid will make the movement snappable to the grid</p> */
		public var grid				:Rectangle;
		
		public var snapObjects		:Array;
		public var includeOwnRect	:Boolean = false;
		public var snapAccuracy		:Number = SnapAccuracy.NORMAL;
		
		// ---- constructor ----
		
		public function SnapBehavior(target:InteractiveObject = null, dispatchFromTarget:Boolean = true) {
			super(target, dispatchFromTarget);
		}
		
		override protected function drag():void {
			var oldPosition:Point = new Point(target.x, target.y);
			
			var position:Point = new Point(target.parent.mouseX, target.parent.mouseY);
			if (useGlobalSpace) position = CoordsUtil.localToGlobal(target, position);
			
			var dx:Number = position.x - downPoint.x;
			var dy:Number = position.y - downPoint.y;
			
			var pos:Point;
			
			// first we try to snap to an object
			if (!pos) pos = snapToObject(origin.x + dx, origin.y + dy);
			
			// if unsuccessful, try snapping on grid
			if (!pos) pos = snapToGrid(origin.x + dx, origin.y + dy);
			
			// if all fails, don't snap but just use the mouse offset
			if (!pos) pos = new Point(origin.x + dx, origin.y + dy); 
			
			// now move to the position, whether snapped or not
			moveTo(pos.x, pos.y);
			
			dispatcher.dispatchEvent(new MoveEvent(MoveEvent.DRAG_MOVE, false, false, oldPosition.x, oldPosition.y));
		}
		
		// ---- public methods ----
		
		override public function moveTo(x:Number, y:Number):void {
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
			
			dispatcher.dispatchEvent(new MoveEvent(MoveEvent.MOVE, false, false, oldPosition.x, oldPosition.y));
		}
		
		/** Snaps the element to the grid as defined by the grid attribute for the movable behavior. */
		public function snapToGrid(x:Number = NaN, y:Number = NaN):Point {
			if (!grid) return null;
			
			// TODO: convert x,y to global space
			
			x = (isNaN(x)) ? target.x : x;
			y = (isNaN(y)) ? target.y : y;
			
			// TODO: add snapAccuracy for when using very large grid cells
			x = Math.round(x / grid.width) * grid.width + (grid.x % grid.width);
			y = Math.round(y / grid.height) * grid.height + (grid.y % grid.height);
			
			dispatcher.dispatchEvent(new SnapEvent(SnapEvent.SNAP_ALL, x, y));
			
			return new Point(x, y);
		}
		
		public function snapToObject(x:Number, y:Number):Point {
			if (!snapObjects) return null;
				
			var snapPoint:Point = findNearestSnapPoint();
			
			var snapVertical:Boolean = (Math.abs(snapPoint.x - x) <= snapAccuracy);
			var snapHorizontal:Boolean = (Math.abs(snapPoint.y - y) <= snapAccuracy);
			
			x = (snapVertical) ? snapPoint.x : x;
			y = (snapHorizontal) ? snapPoint.y : y;
			
			if (snapVertical || snapHorizontal) {
				var eventType:String = (snapVertical && snapHorizontal) ? SnapEvent.SNAP_ALL : (snapVertical) ? SnapEvent.SNAP_VERTICAL : SnapEvent.SNAP_HORIZONTAL;
				dispatcher.dispatchEvent(new SnapEvent(eventType, x, y));
			}
			
			drawBorders(x, y, FlexGlobals.topLevelApplication.drawGroup.graphics);
			
			return (snapVertical || snapHorizontal) ? new Point(x, y) : null;
		}
		
		override protected function mouseUpHandler(event:MouseEvent):void {
			super.mouseUpHandler(event);
			FlexGlobals.topLevelApplication.drawGroup.graphics.clear();
		}
		
		override protected function mouseUpSomewhereHandler(event:SandboxMouseEvent):void {
			super.mouseUpSomewhereHandler(event);
			FlexGlobals.topLevelApplication.drawGroup.graphics.clear();
		}
		
		protected function drawBorders(x:Number, y:Number, g:Graphics):void {
			g.clear();
			
			var borderLength:Number = 30;
			
			g.lineStyle(0, 0, 0);
			g.beginFill(0xFF0000, 1);
			g.drawCircle(x, y, 3);
			g.endFill();
			
			// 1. skip GuideLines als result
			// 2. bepaal op distance of de left of right result wordt getekend
			
			/*var test:Boolean = false;
			if (test == true && leftResult.object is GuideLine == false) {
				if (Math.abs(leftResult.value - x) <= snapAccuracy) {
					g.lineStyle(1, 0xFF0000, 1, true);
					
					var p1:Rectangle = CoordsUtil.getGlobalBounds(target);
					var p2:Rectangle = CoordsUtil.getGlobalBounds(leftResult.object);
					
					x = (leftResult.side == SnapResult.LEFT) ? p2.left : p2.right;
					
					var a1:Point;
					var a2:Point;
					
					if (p1.top < p2.bottom) {
						
						a1 = new Point(x, p1.top - borderLength);
						a2 = new Point(x, p2.bottom + borderLength);
						
						DrawUtil.dashTo(g, a1, a2);
						//g.moveTo(x, p1.top - borderLength);
						//g.lineTo(x, p2.bottom + borderLength);
					} else {
						
						a1 = new Point(x, p2.top - borderLength);
						a2 = new Point(x, p1.bottom + borderLength);
						
						DrawUtil.dashTo(g, a1, a2);
						//g.moveTo(x, p2.top - borderLength);
						//g.lineTo(x, p1.bottom + borderLength);
					}
					
				}
			}*/
			
			if (Math.abs(leftResult.value - x) <= snapAccuracy) {
				g.lineStyle(1, 0xFF0000, 1, true);
				g.moveTo(leftResult.value, 0);
				g.lineTo(leftResult.value, 1000);
			}
			
			if (Math.abs(rightResult.value - x - target.width) <= snapAccuracy) {
				g.lineStyle(1, 0x00FF00, 1, true);
				g.moveTo(rightResult.value+1, 0);
				g.lineTo(rightResult.value+1, 1000);
			}
			
			if (Math.abs(topResult.value - y) <= snapAccuracy) {
				g.lineStyle(1, 0x0000FF, 1, true);
				g.moveTo(0, topResult.value);
				g.lineTo(1000, topResult.value);
			}
			
			if (Math.abs(bottomResult.value - y - target.height) <= snapAccuracy) {
				g.lineStyle(1, 0xFF00FF, 1, true);
				g.moveTo(0, bottomResult.value+1);
				g.lineTo(1000, bottomResult.value+1);
			}
		}
		
		public var leftResult		:SnapResult = new SnapResult();
		public var rightResult		:SnapResult = new SnapResult();
		public var topResult		:SnapResult = new SnapResult();
		public var bottomResult		:SnapResult = new SnapResult();
		
		protected function findNearestSnapPoint():Point {
			var object				:InteractiveObject;
			
			var targetRect			:Rectangle;
			var rect				:Rectangle;
			var offset				:Point;
			
			var nearestLeft			:Number = NaN;
			var nearestRight		:Number = NaN;
			var nearestTop			:Number = NaN;
			var nearestBottom		:Number = NaN;
			
			targetRect = (useGlobalSpace) ? CoordsUtil.getGlobalBounds(target) : CoordsUtil.getBounds(target);
			
			for each (object in snapObjects) {
				
				// ignore disabled objects
				if (object is IUIComponent && (object as IUIComponent).enabled == false) continue;
				
				rect = CoordsUtil.getBounds(object);
				
				// check for self
				if (object == target) {
					if (!includeOwnRect) continue;
					else {
						rect.x = origin.x;
						rect.y = origin.y;
					}
				}
				
				// offset rectangle to global space
				if (useGlobalSpace) {
					offset = CoordsUtil.localToGlobal(object, new Point(rect.x, rect.y));
					rect.x = offset.x
					rect.y = offset.y;
				}
				
				if (direction == Direction.ALL || direction == Direction.VERTICAL) {
					//if (isNaN(nearestLeft) || Math.abs(rect.left - targetRect.left) < Math.abs(nearestLeft - targetRect.left)) nearestLeft = rect.left;
					//if (isNaN(nearestLeft) || Math.abs(rect.right - targetRect.left) < Math.abs(nearestLeft - targetRect.left)) nearestLeft = rect.right;
					//if (isNaN(nearestRight) || Math.abs(rect.left - targetRect.right) < Math.abs(nearestRight - targetRect.right)) nearestRight = rect.left;
					//if (isNaN(nearestRight) || Math.abs(rect.right - targetRect.right) < Math.abs(nearestRight - targetRect.right)) nearestRight = rect.right;
					
					if (!leftResult.object || Math.abs(rect.left - targetRect.left) < Math.abs(leftResult.value - targetRect.left)) {
						leftResult.setResult(object, rect, SnapResult.LEFT);
					}
					if (!leftResult.object || Math.abs(rect.right - targetRect.left) < Math.abs(leftResult.value - targetRect.left)) {
						leftResult.setResult(object, rect, SnapResult.RIGHT);
					}
					if (!rightResult.object || Math.abs(rect.left - targetRect.right) < Math.abs(rightResult.value - targetRect.right)) {
						rightResult.setResult(object, rect, SnapResult.LEFT);
					}
					if (!rightResult.object || Math.abs(rect.right - targetRect.right) < Math.abs(rightResult.value - targetRect.right)) {
						rightResult.setResult(object, rect, SnapResult.RIGHT);
					}
					
				}
				if (direction == Direction.ALL || direction == Direction.HORIZONTAL) {
					//if (isNaN(nearestTop) || Math.abs(rect.top - targetRect.top) < Math.abs(nearestTop - targetRect.top)) nearestTop = rect.top;
					//if (isNaN(nearestTop) || Math.abs(rect.bottom - targetRect.top) < Math.abs(nearestTop - targetRect.top)) nearestTop = rect.bottom;
					//if (isNaN(nearestBottom) || Math.abs(rect.top - targetRect.bottom) < Math.abs(nearestBottom - targetRect.bottom)) nearestBottom = rect.top;
					//if (isNaN(nearestBottom) || Math.abs(rect.bottom - targetRect.bottom) < Math.abs(nearestBottom - targetRect.bottom)) nearestBottom = rect.bottom;
					
					if (!topResult.object || Math.abs(rect.top - targetRect.top) < Math.abs(topResult.value - targetRect.top)) {
						topResult.setResult(object, rect, SnapResult.TOP);
					}
					if (!topResult.object || Math.abs(rect.bottom - targetRect.top) < Math.abs(topResult.value - targetRect.top)) {
						topResult.setResult(object, rect, SnapResult.BOTTOM);
					}
					if (!bottomResult.object || Math.abs(rect.top - targetRect.bottom) < Math.abs(bottomResult.value - targetRect.bottom)) {
						bottomResult.setResult(object, rect, SnapResult.TOP);
					}
					if (!bottomResult.object || Math.abs(rect.bottom - targetRect.bottom) < Math.abs(bottomResult.value - targetRect.bottom)) {
						bottomResult.setResult(object, rect, SnapResult.BOTTOM);
					}
					
				}
				
			}
			
			var result:Point = new Point();
			
			/*if (Math.abs(nearestLeft - targetRect.left) < Math.abs(nearestRight - targetRect.right)) {
				result.x = nearestLeft;
			} else {
				result.x = nearestRight - targetRect.width;
			}
			
			if (Math.abs(nearestTop - targetRect.top) < Math.abs(nearestBottom - targetRect.bottom)) {
				result.y = nearestTop;
			} else {
				result.y = nearestBottom - targetRect.height;
			}*/
			
			if (Math.abs(leftResult.value - targetRect.left) < Math.abs(rightResult.value - targetRect.right)) {
				result.x = leftResult.value;
			} else {
				result.x = rightResult.value - targetRect.width;
			}
			
			if (Math.abs(topResult.value - targetRect.top) < Math.abs(bottomResult.value - targetRect.bottom)) {
				result.y = topResult.value;
			} else {
				result.y = bottomResult.value - targetRect.height;
			}
			
			return result;
		}
		
	}
}
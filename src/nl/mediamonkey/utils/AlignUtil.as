package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class AlignUtil {
		
		// ---- public static constants ----
		
		public static const NONE			:String = "none";
		
		// horizontal
		public static const LEFT			:String = "left";
		public static const CENTER			:String = "center";
		public static const RIGHT			:String = "right";
		
		// vertical
		public static const TOP				:String = "top";
		public static const MIDDLE			:String = "middle";
		public static const BOTTOM			:String = "bottom";
		
		// direction
		public static const HORIZONTAL		:String = "horizontal";
		public static const VERTICAL		:String = "vertical";
		
		// ---- public static methods ----
		
		/**
		 * @param array A collection of DisplayObjects.
		 * @param horizontal A String value to align horizontally. Tha value can be "left", "center" or "right".
		 * @param horizontal A String value to align vertically. Tha value can be "top", "middle" or "bottom".
		 * @param stage A DisplayObject of which to include the bounds in the algorithm.
		 */
		public static function align(array:Array, horizontal:String, vertical:String, stage:Object=null):void {
			DebugUtil.expect(horizontal, LEFT, CENTER, RIGHT, NONE);
			DebugUtil.expect(vertical, TOP, MIDDLE, BOTTOM, NONE);
			
			// calulcate bounds with optional stage
			//if (stage) var tempArray:Array = array.concat(stage);
			//var bounds:Rectangle = combineRectangles(tempArray || array);
			
			var bounds:Rectangle;
			if (stage) bounds = combineRectangles([stage]);
			else bounds = combineRectangles(array);
			
			var object:DisplayObject;
			var point:Point = new Point();
			
			for each (object in array) {
				
				// we need the global point since we'll set the x, y or both back to local later
				point = CoordsUtil.globalPosition(object);
				
				switch (horizontal) {
					case LEFT:		point.x = bounds.left; break;
					case CENTER:	point.x = bounds.left + (bounds.width - object.width)/2; break;
					case RIGHT:		point.x = bounds.right - object.width; break;
				}
				
				switch (vertical) {
					case TOP:		point.y = bounds.top; break;
					case MIDDLE:	point.y = bounds.top + (bounds.height - object.height)/2; break;
					case BOTTOM:	point.y = bounds.bottom - object.height; break;
				}
				
				point = CoordsUtil.globalToLocal(object, point);
				object.x = point.x;
				object.y = point.y;
			}
		}
		
		/**
		 * @param array A collection of DisplayObjects.
		 * @param horizontal A String value to distribute horizontally. Tha value can be "left", "center" or "right".
		 * @param horizontal A String value to distribute vertically. Tha value can be "top", "middle" or "bottom".
		 * @param stage A DisplayObject of which to include the bounds in the algorithm.
		 */
		public static function distribute(array:Array, horizontal:String, vertical:String, stage:Object=null):void {
			DebugUtil.expect(horizontal, LEFT, CENTER, RIGHT, NONE);
			DebugUtil.expect(vertical, TOP, MIDDLE, BOTTOM, NONE);
			DebugUtil.assert(!(horizontal == NONE && vertical == NONE),
				"horizontal and vertical arguments can't both be 'none'");
			
			// calulcate bounds with optional stage
			//if (stage) var tempArray:Array = array.concat(stage);
			if (stage) var tempArray:Array = [stage];
			
			var topLeft:Rectangle = measureMinMax(tempArray || array, "top", "left");
			var middleCenter:Rectangle = measureMinMax(tempArray || array, "middle", "center");
			var bottomRight:Rectangle = measureMinMax(tempArray || array, "bottom", "right");
			
			var point:Point = new Point();
			var widthSpacing:Number;
			var heightSpacing:Number;
			
			// TODO: sort on GLOBAL coords
			//array = array.sortOn(["x", "y"], Array.NUMERIC);
			
			var object:DisplayObject;
			for (var i:uint=0; i<array.length; i++) {
				object = array[i] as DisplayObject;
				
				switch (horizontal) {
					case LEFT: {
						widthSpacing = topLeft.width / (array.length - 1);
						point.x = topLeft.x + (widthSpacing * i);
						break;
					}
					case CENTER: {
						widthSpacing = middleCenter.width / (array.length - 1);
						point.x = middleCenter.x - (object.width/2) + (widthSpacing * i);
						break;
					}
					case RIGHT: {
						widthSpacing = bottomRight.width / (array.length - 1);
						point.x = bottomRight.x - object.width + (widthSpacing * i);
						break;
					}
				}
				
				switch (vertical) {
					case TOP: {
						heightSpacing = topLeft.height / (array.length - 1);
						point.y = topLeft.y + (heightSpacing * i);
						break;
					}
					case MIDDLE: {
						heightSpacing = middleCenter.height / (array.length - 1);
						point.y = middleCenter.y - (object.height/2) + (heightSpacing * i);
						break;
					}
					case BOTTOM: {
						heightSpacing = bottomRight.height / (array.length - 1);
						point.y = bottomRight.y - object.height + (heightSpacing * i);
						break;
					}
				}
				
				point = CoordsUtil.globalToLocal(object, point);
				if (horizontal != NONE) object.x = point.x;
				if (vertical != NONE) object.y = point.y;
			}
		}
		
		/**
		 * @param array A collection of DisplayObjects.
		 * @param width Boolean value to match size over width.
		 * @param height Boolean value to match size over height.
		 * @param stage A DisplayObject of which to include the bounds in the algorithm.
		 */
		public static function matchSize(array:Array, width:Boolean, height:Boolean, stage:Object=null):void {
			if (!width && !height) return;
			
			// calulcate bounds with optional stage
			if (stage) var tempArray:Array = array.concat(stage);
			var bounds:Rectangle = getBiggestRect(tempArray || array);
			
			var object:DisplayObject;
			for each (object in array) {
				
				if (width) object.width = bounds.width;
				if (height) object.height = bounds.height;
			}
		}
		
		/**
		 * @param array A collection of DisplayObjects.
		 * @param direction This string value can be either "horizontal" or "vertical".
		 */
		public static function space(array:Array, direction:String, stage:Object=null):void {
			DebugUtil.expect(direction, HORIZONTAL, VERTICAL);
			
			// calulcate bounds with optional stage
			if (stage) var tempArray:Array = array.concat(stage);
			var bounds:Rectangle = combineRectangles(tempArray || array);
			
			// measure combined width and height
			var measuredRect:Rectangle = measureWidthAndHeight(array);
			
			// difference divided by num elements - 1
			var dw:Number = (bounds.width - measuredRect.width) / (array.length-1);
			var dh:Number = (bounds.height - measuredRect.height) / (array.length-1);
			
			var object:DisplayObject;
			var point:Point = new Point();
			var offsetX:Number = 0;
			var offsetY:Number = 0;
			
			// TODO: sort on GLOBAL coords
			//array = array.sortOn(["x", "y"], Array.NUMERIC);
			
			// layout
			for (var i:uint=0; i<array.length; i++) {
				object = array[i] as DisplayObject;
				
				if (direction == HORIZONTAL) {
					point.x = bounds.left + offsetX;
					offsetX += object.width + dw;
					
				} else if (direction == VERTICAL) {
					point.y = bounds.top + offsetY;
					offsetY += object.height + dh;
				}
				
				point = CoordsUtil.globalToLocal(object, point);
				if (direction == HORIZONTAL) object.x = point.x;
				else if (direction == VERTICAL) object.y = point.y;
			}
		}
		
		// ---- calculation methods ----
		
		public static function combineRectangles(array:Array):Rectangle {
			var result:Rectangle;
			var bounds:Rectangle;
			
			var object:DisplayObject;
			var rect:Rectangle;
			
			for (var i:int=0; i<array.length; i++) {
				
				if (array[i] is DisplayObject) {
					object = array[i] as DisplayObject;
					bounds = CoordsUtil.getGlobalBounds(object);
					result = (!result) ? bounds : result.union(bounds);
					
				} else if (array[i] is Rectangle) {
					rect = array[i] as Rectangle;
					result = (!result) ? rect : result.union(rect);
					
				} else {
					throw new Error("element is not of type DisplayObject nor Rectangle");
				}
				
			}
			
			return result;
		}
		
		public static function measureMinMax(array:Array, vertical:String, horizontal:String):Rectangle {
			var bounds:Rectangle;
			
			var minX:Number = Infinity;
			var maxX:Number = 0;
			var minY:Number = Infinity;
			var maxY:Number = 0;
			
			for (var i:int=0; i<array.length; i++) {
				
				if (array[i] is DisplayObject) {
					bounds = CoordsUtil.getGlobalBounds(array[i] as DisplayObject);
					
				} else if (array[i] is Rectangle) {
					bounds = array[i] as Rectangle;
					
				} else {
					throw new Error("element is not of type DisplayObject nor Rectangle");
				}
				
				switch (vertical) {
					case "top": {
						minY = Math.min(bounds.top, minY);
						maxY = Math.max(bounds.top, maxY);
						break;
					}
					case "middle": {
						minY = Math.min(bounds.top + bounds.height/2, minY);
						maxY = Math.max(bounds.top + bounds.height/2, maxY);
						break;
					}
					case "bottom": {
						minY = Math.min(bounds.bottom, minY);
						maxY = Math.max(bounds.bottom, maxY);
						break;
					}
					case "height": {
						minY = Math.min(bounds.top, minY);
						maxY = Math.max(bounds.bottom, maxY);
						break;
					}
				}
				
				switch (horizontal) {
					case "left": {
						minX = Math.min(bounds.left, minX);
						maxX = Math.max(bounds.left, maxX);
						break;
					}
					case "center": {
						minX = Math.min(bounds.left + bounds.width/2, minX);
						maxX = Math.max(bounds.left + bounds.width/2, maxX);
						break;
					}
					case "right": {
						minX = Math.min(bounds.right, minX);
						maxX = Math.max(bounds.right, maxX);
						break;
					}
					case "width": {
						minX = Math.min(bounds.left, minX);
						maxX = Math.max(bounds.right, maxX);
						break;
					}
				}
				
			}
			
			if (minX == Infinity) minX = 0;
			if (minY == Infinity) minY = 0;
			
			return new Rectangle(minX, minY, maxX - minX, maxY - minY);
		}
		
		// measure combined width and height
		public static function measureWidthAndHeight(array:Array):Rectangle {
			var measuredWidth:Number = 0;
			var measuredHeight:Number = 0;
			var rect:Rectangle;
			
			for (var i:int=0; i<array.length; i++) {
				
				if (array[i] is DisplayObject) {
					rect = CoordsUtil.getGlobalBounds(array[i] as DisplayObject);
					
				} else if (array[i] is Rectangle) {
					rect = array[i] as Rectangle;
					
				} else {
					throw new Error("element is not of type DisplayObject nor Rectangle");
				}
				
				measuredWidth += rect.width;
				measuredHeight += rect.height;
			}
			
			return new Rectangle(0, 0, measuredWidth, measuredHeight);
		}
		
		public static function getBiggestRect(array:Array):Rectangle {
			var biggest:Rectangle;
			var bounds:Rectangle;
			
			for (var i:int=0; i<array.length; i++) {
				
				if (array[i] is DisplayObject) {
					bounds = CoordsUtil.getGlobalBounds(array[i] as DisplayObject);
					
				} else if (array[i] is Rectangle) {
					bounds = array[i] as Rectangle;
					
				} else {
					throw new Error("element is not of type DisplayObject nor Rectangle");
				}
				
				if (!biggest) biggest = bounds;
				if (bounds.width > biggest.width) biggest.width = bounds.width;
				if (bounds.height > biggest.height) biggest.height = bounds.height;
			}
			
			return biggest;
		}
		
	}
}
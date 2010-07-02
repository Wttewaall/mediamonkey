package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.FlexGlobals;
	
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
		 * @param alignTo A DisplayObject of which to include the bounds in the algorithm.
		 */
		public static function align(array:Array, horizontal:String, vertical:String, alignTo:DisplayObject=null):void {
			DebugUtil.expect(horizontal, LEFT, CENTER, RIGHT, NONE);
			DebugUtil.expect(vertical, TOP, MIDDLE, BOTTOM, NONE);
			
			// add alignTo object to a NEW array by concatinating, the object will be skipped when setting position
			if (alignTo) array = array.concat(alignTo);
			
			// get the union of all bounds. if alignTo is the container, its bounds will likely be the result
			var rect:Rectangle = combineRectangles(array, true);
			
			var object:DisplayObject;
			var point:Point = new Point();
			
			for each (object in array) {
				
				// filter out the alignTo object
				if (alignTo && object == alignTo) continue;
				
				// we need the global point since we'll set the x, y or both back to local later
				point = CoordsUtil.globalPosition(object);
				
				switch (horizontal) {
					case LEFT:		point.x = rect.left; break;
					case CENTER:	point.x = rect.left + (rect.width - object.width)/2; break;
					case RIGHT:		point.x = rect.right - object.width; break;
				}
				
				switch (vertical) {
					case TOP:		point.y = rect.top; break;
					case MIDDLE:	point.y = rect.top + (rect.height - object.height)/2; break;
					case BOTTOM:	point.y = rect.bottom - object.height; break;
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
		 * @param alignTo A DisplayObject of which to include the bounds in the algorithm.
		 */
		public static function distribute(array:Array, horizontal:String, vertical:String, alignTo:DisplayObject=null):void {
			DebugUtil.expect(horizontal, LEFT, CENTER, RIGHT, NONE);
			DebugUtil.expect(vertical, TOP, MIDDLE, BOTTOM, NONE);
			DebugUtil.assert(!(horizontal == NONE && vertical == NONE),
				"horizontal and vertical arguments can't both be 'none'");
			
			var rect:Rectangle = combineRectangles(array);
			array = array.sortOn(["x", "y"], Array.NUMERIC);
			
			var topLeft:Rectangle = measureMinMax(array, "tl");
			var centerMiddle:Rectangle = measureMinMax(array, "cm");
			var bottomRight:Rectangle = measureMinMax(array, "br");
			
			var widthSpacing:Number;
			var heightSpacing:Number;
			
			var object:DisplayObject;
			for (var i:uint=0; i<array.length; i++) {
				object = array[i] as DisplayObject;
				
				switch (horizontal) {
					case LEFT: {
						widthSpacing = topLeft.width / (array.length - 1);
						object.x = topLeft.x + (widthSpacing * i);
						break;
					}
					case CENTER: {
						widthSpacing = centerMiddle.width / (array.length - 1);
						object.x = centerMiddle.x - (object.width/2) + (widthSpacing * i);
						break;
					}
					case RIGHT: {
						widthSpacing = bottomRight.width / (array.length - 1);
						object.x = bottomRight.x - object.width + (widthSpacing * i);
						break;
					}
				}
				
				switch (vertical) {
					case TOP: {
						heightSpacing = topLeft.height / (array.length - 1);
						object.y = topLeft.y + (heightSpacing * i);
						break;
					}
					case MIDDLE: {
						heightSpacing = centerMiddle.height / (array.length - 1);
						object.y = centerMiddle.y - (object.height/2) + (heightSpacing * i);
						break;
					}
					case BOTTOM: {
						heightSpacing = bottomRight.height / (array.length - 1);
						object.y = bottomRight.y - object.height + (heightSpacing * i);
						break;
					}
				}
				
			}
		}
		
		/**
		 * @param array A collection of DisplayObjects.
		 * @param width Boolean value to match size over width.
		 * @param height Boolean value to match size over height.
		 * @param alignTo A DisplayObject of which to include the bounds in the algorithm.
		 */
		public static function matchSize(array:Array, width:Boolean, height:Boolean, alignTo:DisplayObject=null):void {
			if (!width && !height) return;
			
			var rect:Rectangle = getBiggestRect(array);
			
			var object:DisplayObject;
			for each (object in array) {
				
				if (width) object.width = rect.width;
				if (height) object.height = rect.height;
			}
		}
		
		/**
		 * @param array A collection of DisplayObjects.
		 * @param direction This string value can be either "horizontal" or "vertical".
		 */
		public static function space(array:Array, direction:String):void {
			DebugUtil.expect(direction, HORIZONTAL, VERTICAL);
			
			var rect:Rectangle = combineRectangles(array);
			array = array.sortOn(["x", "y"], Array.NUMERIC);
			
			var topLeft:Rectangle = measureMinMax(array, "tl");
			var bottomRight:Rectangle = measureMinMax(array, "br");
			
			// measure combined width and height
			var measuredWidth:Number = 0;
			var measuredHeight:Number = 0;
			
			var object:DisplayObject;
			for each (object in array) {
				rect = CoordsUtil.getBounds(object);
				measuredWidth += rect.width;
				measuredHeight += rect.height;
			}
			
			var widthSpacing:Number = (bottomRight.right - topLeft.left - measuredWidth) / (array.length - 1);
			var heightSpacing:Number = (bottomRight.bottom - topLeft.top - measuredHeight) / (array.length - 1);
			trace("widthSpacing:", widthSpacing, "heightSpacing:", heightSpacing);
			
			for (var i:uint=0; i<array.length; i++) {
				object = array[i] as DisplayObject;
				
				if (direction == HORIZONTAL) {
					object.x = rect.left + (widthSpacing * i);
					
				} else if (direction == VERTICAL) {
					object.y = rect.top + (heightSpacing * i);
				}
				
			}
		}
		
		// ---- protected static methods ----
		
		protected static function measureMinMax(array:Array, direction:String):Rectangle {
			var rect:Rectangle;
			
			var minX:Number = Infinity;
			var minY:Number = Infinity;
			var maxX:Number = 0;
			var maxY:Number = 0;
			
			var object:DisplayObject;
			for each (object in array) {
				
				rect = CoordsUtil.getBounds(object);
				
				if (direction == "tl") {
					minX = Math.min(rect.left, minX);
					minY = Math.min(rect.top, minY);
					maxX = Math.max(rect.left, maxX);
					maxY = Math.max(rect.top, maxY);
				
				} else if (direction == "cm") {
					minX = Math.min(rect.left + rect.width/2, minX);
					minY = Math.min(rect.top + rect.height/2, minY);
					maxX = Math.max(rect.left + rect.width/2, maxX);
					maxY = Math.max(rect.top + rect.height/2, maxY);
					
				} else if (direction == "br") {
					minX = Math.min(rect.right, minX);
					minY = Math.min(rect.bottom, minY);
					maxX = Math.max(rect.right, maxX);
					maxY = Math.max(rect.bottom, maxY);
				}
			}
			
			return new Rectangle(minX, minY, maxX - minX, maxY - minY);
		}
		
		protected static function combineRectangles(array:Array, useGlobalSpace:Boolean=true):Rectangle {
			var result:Rectangle;
			var rect:Rectangle;
			var boundsFunction:Function = (useGlobalSpace) ? CoordsUtil.getGlobalBounds : CoordsUtil.getBounds;
			
			var object:DisplayObject;
			for each (object in array) {
				
				rect = boundsFunction.apply(null, [object]);
				//rect = (useGlobalSpace) ? CoordsUtil.getGlobalBounds(object) : CoordsUtil.getBounds(object);
				result = (!result) ? rect : result.union(rect);
			}
			
			return result;
		}
		
		protected static function getBiggestRect(array:Array):Rectangle {
			var biggest:Rectangle;
			var rect:Rectangle;
			
			var object:DisplayObject;
			for each (object in array) {
				rect = CoordsUtil.getBounds(object);
				
				if (!biggest) biggest = rect;
				if (rect.width > biggest.width) biggest.width = rect.width;
				if (rect.height > biggest.height) biggest.height = rect.height;
			}
			
			return biggest;
		}
		
	}
}
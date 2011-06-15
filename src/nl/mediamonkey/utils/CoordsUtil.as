package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CoordsUtil {
		
		public static function localToGlobal(object:DisplayObject, point:Point):Point {
			return object.parent.localToGlobal(point);
		}
		
		public static function globalToLocal(object:DisplayObject, point:Point):Point {
			return object.parent.globalToLocal(point);
		}
		
		public static function localToLocal(point:Point, from:DisplayObject, to:DisplayObject):Point {
			return to.parent.globalToLocal(from.parent.localToGlobal(point));
		}
		
		public static function globalPosition(object:DisplayObject):Point {
			return localToGlobal(object, new Point(object.x, object.y));
		}
		
		public static function localPosition(object:DisplayObject, to:DisplayObject):Point {
			return localToLocal(new Point(object.x, object.y), object, to);
		}
		
		public static function localPoint(object:DisplayObject, point:Point):Point {
			trace("CoordsUtil.localPoint() is untested!");
			return globalToLocal(object, point);
		}
		
		public static function getBounds(object:DisplayObject):Rectangle {
			return object.getBounds(object.parent);
		}
		
		public static function getGlobalBounds(object:DisplayObject):Rectangle {
			var p:Point = globalPosition(object);
			var rect:Rectangle = getBounds(object);
			rect.x = p.x; rect.y = p.y;
			return rect;
		}
		
		// untested!
		public static function localRect(object:DisplayObject, rect:Rectangle):Rectangle {
			var p:Point = localPoint(object, new Point(rect.x, rect.y));
			rect.x = p.x; rect.y = p.y;
			return rect;
		}
		
	}
}
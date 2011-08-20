package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class DisplayListUtil {
		
		// recursive algorithm that returns all children in the displaylist as a flat array
		public static function getFlattenedDisplayList(target:DisplayObjectContainer):Array {
			var children:Array = new Array();
			var child:DisplayObject;
			
			for (var i:int=0; i<target.numChildren; i++) {
				child = target.getChildAt(i);
				
				if (child.hasOwnProperty("numChildren") && (child as DisplayObjectContainer).numChildren > 0) {
					children = children.concat( getFlattenedDisplayList(child as DisplayObjectContainer) );
					
				} else {
					children.push(child);
				}
			}
			
			return children;
		}
		
		// from: http://www.kirupa.com/forum/showpost.php?p=1939827&postcount=172
		public static function duplicateDisplayObject(target:DisplayObject, autoAdd:Boolean = false):DisplayObject {
			
			// create duplicate
			var targetClass:Class = Object(target).constructor;
			var duplicate:DisplayObject = new targetClass();
			
			// duplicate properties
			duplicate.transform = target.transform;
			duplicate.filters = target.filters;
			duplicate.cacheAsBitmap = target.cacheAsBitmap;
			duplicate.opaqueBackground = target.opaqueBackground;
			
			if (target.scale9Grid) {
				var rect:Rectangle = target.scale9Grid;
				// WAS Flash 9 bug where returned scale9Grid is 20x larger than assigned
				// rect.x /= 20, rect.y /= 20, rect.width /= 20, rect.height /= 20;
				duplicate.scale9Grid = rect;
			}
			
			// add to target parent's display list
			// if autoAdd was provided as true
			if (autoAdd && target.parent) target.parent.addChild(duplicate);
			
			return duplicate;
		}
		
		public static function getObjectsUnderPoint(target:DisplayObjectContainer, local:Point):Array {
			var global:Point = target.localToGlobal(local);
			var objects:Array = DisplayListUtil.getFlattenedDisplayList(target);
			
			var display:DisplayObject;
			var result:Array = [];
			
			for each (display in objects) {
				local = display.globalToLocal(global);
				
				if (display.getBounds(display.parent).containsPoint(local))
					result.push(display);
			}
			
			return result;
		}
		
		// returns an inverse matrix with which you can position/skew/scale a target displayobject to the visual relative transform when placed in the container
		public static function concatenateMatrixToContainer(target:DisplayObject, container:DisplayObjectContainer):Matrix {
			var matrix:Matrix = target.transform.matrix.clone();
			if (target == container) return matrix;
			
			do {
				matrix.concat(target.parent.transform.matrix);
				target = target.parent;
				
				// if there is no parent, the target is not on the displaylist
				if (target == null) return null;
				
				// if we reach the root and haven't encountered the container, the container is not a (grand)parent of the target
				if (target == target.root && target != container) return null;
				
			} while (target != target.root && target != container);
			
			return matrix;
		}
		
	}
}
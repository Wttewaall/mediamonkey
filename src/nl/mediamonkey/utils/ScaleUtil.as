package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	
	import nl.mediamonkey.enum.ResizeType;
	import nl.mediamonkey.enum.ZoomType;
	
	public class ScaleUtil {
		
		public static function scaleToContainer(target:DisplayObject, container:DisplayObject, zoomMode:String="fitImage", resizeMode:uint=1):void {
			var scale:Number = getScale(target, container.width, container.height, zoomMode, resizeMode);
			target.scaleX = target.scaleY = scale;
		}
		
		public static function scaleToSize(target:DisplayObject, width:uint, height:uint, zoomMode:String="fitImage", resizeMode:uint=1):void {
			var scale:Number = getScale(target, width, height, zoomMode, resizeMode);
			target.scaleX = target.scaleY = scale;
		}
		
		public static function getScale(target:DisplayObject, width:uint, height:uint, zoomMode:String="fitImage", resizeMode:uint=1):Number {
			var sx:Number = width / target.width;
			var sy:Number = height / target.height;
			
			if (resizeMode == (ResizeType.REDUCE | ResizeType.ENLARGE)) {
				// sx = sx; sy = sy;
				
			} else if (resizeMode & ResizeType.REDUCE) {
				sx = Math.min(sx, 1);
				sy = Math.min(sy, 1);
				
			} else if (resizeMode & ResizeType.ENLARGE) {
				sx = Math.max(sx, 1);
				sy = Math.max(sy, 1);
			}
			
			switch (zoomMode) {
				case ZoomType.ACTUAL_SIZE:	return 1;
				case ZoomType.FIT_WIDTH:	return sx;
				case ZoomType.FIT_HEIGHT:	return sy;
				case ZoomType.FIT_IMAGE:	return Math.min(sx, sy);
				default:					return 1;
			}
		}
		
	}
}
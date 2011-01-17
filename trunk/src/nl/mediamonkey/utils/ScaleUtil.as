package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	
	import nl.mediamonkey.utils.enum.ResizeMode;
	import nl.mediamonkey.utils.enum.ZoomMode;
	
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
			
			if (resizeMode == (ResizeMode.REDUCE | ResizeMode.ENLARGE)) {
				// sx = sx; sy = sy;
				
			} else if (resizeMode & ResizeMode.REDUCE) {
				sx = Math.min(sx, 1);
				sy = Math.min(sy, 1);
				
			} else if (resizeMode & ResizeMode.ENLARGE) {
				sx = Math.max(sx, 1);
				sy = Math.max(sy, 1);
			}
			
			switch (zoomMode) {
				case ZoomMode.ACTUAL_SIZE:	return 1;
				case ZoomMode.FIT_WIDTH:	return sx;
				case ZoomMode.FIT_HEIGHT:	return sy;
				case ZoomMode.FIT_IMAGE:	return Math.min(sx, sy);
				default:					return 1;
			}
		}
		
	}
}
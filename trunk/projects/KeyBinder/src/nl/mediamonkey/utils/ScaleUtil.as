package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	
	public class ScaleUtil {
		
		public static const ACTUAL_SIZE		:String = "actualSize";
		public static const FIT_WIDTH		:String = "fitWidth";
		public static const FIT_HEIGHT		:String = "fitHeight";
		public static const FIT_IMAGE		:String = "fitImage";
		
		public static const REDUCE			:uint = 1 << 1;
		public static const ENLARGE			:uint = 1 << 2;
		
		public static function scaleToContainer(target:DisplayObject, container:DisplayObject, zoomMode:String, resizeMode:uint):void {
			var scale:Number = getScale(target, container.width, container.height, zoomMode, resizeMode);
			target.scaleX = target.scaleY = scale;
		}
		
		public static function scaleToSize(target:DisplayObject, width:uint, height:uint, zoomMode:String, resizeMode:uint):void {
			var scale:Number = getScale(target, width, height, zoomMode, resizeMode);
			target.scaleX = target.scaleY = scale;
		}
		
		public static function getScale(target:DisplayObject, width:uint, height:uint, zoomMode:String, resizeMode:uint):Number {
			var sx:Number = width / target.width;
			var sy:Number = height / target.height;
			
			if (resizeMode == (REDUCE | ENLARGE)) {
				// sx = sx; sy = sy;
				
			} else if (resizeMode & REDUCE) {
				sx = Math.min(sx, 1);
				sy = Math.min(sy, 1);
				
			} else if (resizeMode & ENLARGE) {
				sx = Math.max(sx, 1);
				sy = Math.max(sy, 1);
			}
			
			switch (zoomMode) {
				case ACTUAL_SIZE:	return 1;
				case FIT_WIDTH:		return sx;
				case FIT_HEIGHT:	return sy;
				case FIT_IMAGE:		return Math.min(sx, sy);
				default:			return 1;
			}
		}
		
	}
}
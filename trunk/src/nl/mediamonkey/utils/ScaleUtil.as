package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import nl.mediamonkey.enum.ResizeMode;
	import nl.mediamonkey.enum.ZoomMode;
	
	public class ScaleUtil {
		
		public static function getScale(target:DisplayObject, width:uint, height:uint, zoomMode:String="fitImage", resizeMode:uint=3):Number {
			if (!EnumUtil.hasConst(ZoomMode, zoomMode))
				throw new ArgumentError("invalid zoomMode value");
			
			var sx:Number = width / (target.width / target.scaleX);
			var sy:Number = height / (target.height / target.scaleY);
			
			if (resizeMode == (ResizeMode.REDUCE | ResizeMode.ENLARGE)) { // 3
				//sx = sx;
				//sy = sy;
				
			} else if (resizeMode & ResizeMode.REDUCE) { // 1
				sx = Math.min(sx, 1);
				sy = Math.min(sy, 1);
				
			} else if (resizeMode & ResizeMode.ENLARGE) { // 2
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
		
		public static function scaleToContainer(target:DisplayObject, container:DisplayObject, zoomMode:String="fitImage", resizeMode:uint=3):void {
			var scale:Number = getScale(target, container.width, container.height, zoomMode, resizeMode);
			target.scaleX *= scale;
			target.scaleY *= scale;
		}
		
		public static function scaleToSize(target:DisplayObject, width:uint, height:uint, zoomMode:String="fitImage", resizeMode:uint=3):void {
			var scale:Number = getScale(target, width, height, zoomMode, resizeMode);
			target.scaleX *= scale;
			target.scaleY *= scale;
		}
		
	}
}
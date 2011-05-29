package nl.mediamonkey.utils {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import nl.mediamonkey.utils.enum.ResizeMode;
	import nl.mediamonkey.utils.enum.ZoomMode;
	
	public class ScaleUtil {
		
		/** maintainRatio = true */
		public static function scaleToContainer(target:DisplayObject, container:DisplayObjectContainer, zoomMode:String="fit", resizeMode:uint=1):void {
			var scale:Number = getScale(target.width, target.height, container.width, container.height, zoomMode, resizeMode);
			target.scaleX = target.scaleY = scale;
		}
		
		/** maintainRatio = true */
		public static function scaleToSize(target:DisplayObject, width:uint, height:uint, zoomMode:String="fit", resizeMode:uint=1):void {
			var scale:Number = getScale(target.width, target.height, width, height, zoomMode, resizeMode);
			target.scaleX = target.scaleY = scale;
		}
		
		/** maintainRatio = true */
		public static function centerAndFit(target:DisplayObject, container:DisplayObjectContainer, padding:Number=0, flipH:Boolean=false, flipV:Boolean=false):void {
			if (!target) return;
			
			var scale:Number = ScaleUtil.getScale(target.width, target.height, container.width - padding, container.height - padding, ZoomMode.FIT, ResizeMode.ENLARGE | ResizeMode.REDUCE);
			
			// attention: multiply by scale difference, don't assign!
			target.scaleX *= (flipH) ? -scale : scale;
			target.scaleY *= (flipV) ? -scale : scale;
			
			target.x = (container.width - target.width)/2 + (flipH ? target.width : 0);
			target.y = (container.height - target.height)/2 + (flipV ? target.height : 0);
		}
		
		/** maintainRatio = true */
		public static function getScale(targetWidth:Number, targetHeight:Number, width:uint, height:uint, zoomMode:String="fit", resizeMode:uint=1):Number {
			var sx:Number = width / targetWidth;
			var sy:Number = height / targetHeight;
			
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
				case ZoomMode.FIT:			return Math.min(sx, sy);
				case ZoomMode.FILL:			return Math.max(sx, sy);
				default:					return 1;
			}
		}
		
		// ---- zoom functionality ----
		
		public static var zoomSpeed			:Number = 1.25;
		
		public static function zoom(zoomMode:String, target:DisplayObject, container:DisplayObject, horizontalPadding:Number=0, verticalPadding:Number=0, setScale:Boolean=false):Number {
			var value:Number;
			
			switch (zoomMode) {
				case ZoomMode.ZOOM_IN: {
					value = (target.scaleX < 1)
						? target.scaleX * zoomSpeed
						: target.scaleX + (zoomSpeed/2);
					break;
				}
				case ZoomMode.ZOOM_OUT: {
					value = (target.scaleX <= 1)
						? target.scaleX / zoomSpeed
						: target.scaleX - (zoomSpeed/2);
					break;
				}
				case ZoomMode.ZOOM_FIT: {
					value = Math.min(
						(container.width - horizontalPadding) / (target.width / target.scaleX),
						(container.height - verticalPadding) / (target.height / target.scaleY)
					);
					break;
				}
				case ZoomMode.ZOOM_RESET: {
					value = 1;
					break;
				}
			}
			
			if (setScale) target.scaleX = target.scaleY = value;
			return value;
		}
		
	}
}
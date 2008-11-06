package nl.mediamonkey.managers {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.IImageEncoder;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	
	public class ImageManager {
		
		public static const JPG_ENCODER:String = "image/jpg";
		public static const PNG_ENCODER:String = "image/png";
		
		// ---- public methods ----
		
		public static function getEncodedByteArray(bitmapDrawable:IBitmapDrawable, encoderType:String, jpgQuality:int=85, scale:Number=1, 
			clipRect:Rectangle=null, backgroundColor:Number=0xFFFFFFFF, pixelSnapping:String=PixelSnapping.AUTO, smoothing:Boolean=false):ByteArray {
			
			var bitmapdata:BitmapData = getBitmapData(bitmapDrawable, scale, clipRect, backgroundColor, pixelSnapping, smoothing);
			
			var encoder:IImageEncoder;
			var bytearray:ByteArray;
			
			switch (encoderType) {
				
				case PNG_ENCODER: {
					encoder = new PNGEncoder();
					bytearray = encoder.encode(bitmapdata);
					break;
				}
				
				case JPG_ENCODER:
				default: {
					encoder = new JPEGEncoder(jpgQuality);
					bytearray = encoder.encode(bitmapdata);
					break;
				}
			}
			
			return bytearray;
		}
		
		public static function getBitmapData(bitmapDrawable:IBitmapDrawable, scale:Number=1, clipRect:Rectangle=null,
			backgroundColor:Number=0xFFFFFFFF, pixelSnapping:String=PixelSnapping.AUTO, smoothing:Boolean=false):BitmapData {
			
			if (bitmapDrawable is BitmapData) {
				return bitmapDrawable as BitmapData;
				
			} else {
				var displayObject:DisplayObject = bitmapDrawable as DisplayObject;
				var bitmapdata:BitmapData = new BitmapData(displayObject.width * scale, displayObject.height * scale, true, backgroundColor);
				var bitmap:Bitmap = new Bitmap(bitmapdata, pixelSnapping, smoothing);
				
				var matrix:Matrix = new Matrix();
				matrix.scale(scale, scale);
				
				/*if (clipRect == null) { // didn't need this yet...
					var dx:Number = -displayObject.getBounds(bitmap).x + displayObject.x;
					var dy:Number = -displayObject.getBounds(bitmap).y + displayObject.y
					matrix.translate(dx, dy);
				}*/
				
				bitmapdata.draw(displayObject, matrix, null, null, clipRect, smoothing);
				
				return bitmapdata;
			}
		}
		
		/* Flash 10
		public static function saveBitmapDataAs(bitmapData:BitmapData, encoderType:String, fileName:String=null):void {
            var byteArray:ByteArray = getEncodedByteArray(bitmapData, encoderType);
            saveByteArrayAs(byteArray, fileName);
		}
		
		public static function saveByteArrayAs(byteArray:ByteArray, fileName:String=null):void {
			var fileReference:FileReference = new FileReference();
            fileReference.save(byteArray, fileName);
            byteArray.clear();
		}*/
		
	}
	
}
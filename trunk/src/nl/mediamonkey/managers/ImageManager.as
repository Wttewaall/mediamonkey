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
		
		public static function getBitmap(bitmapDrawable:IBitmapDrawable, scale:Number=1, clipRect:Rectangle=null,
			backgroundColor:Number=0xFFFFFFFF, pixelSnapping:String=PixelSnapping.AUTO, smoothing:Boolean=false):Bitmap {
			
			if (bitmapDrawable is Bitmap) {
				return bitmapDrawable as Bitmap;
				
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
				
				return bitmap;
			}
		}
		
		public static function getBitmapData(bitmapDrawable:IBitmapDrawable, scale:Number=1, clipRect:Rectangle=null,
			backgroundColor:Number=0xFFFFFFFF, pixelSnapping:String=PixelSnapping.AUTO, smoothing:Boolean=false):BitmapData {
			
			var bitmap:Bitmap = getBitmap(bitmapDrawable, scale, clipRect, backgroundColor, pixelSnapping, smoothing);
			return bitmap.bitmapData;
		}
		
		public static function getEncodedByteArray(bitmapDrawable:IBitmapDrawable, encoderType:String, jpgQuality:int=85, scale:Number=1, 
			clipRect:Rectangle=null, backgroundColor:Number=0xFFFFFFFF, pixelSnapping:String=PixelSnapping.AUTO, smoothing:Boolean=false):ByteArray {
			
			var bitmapData:BitmapData = getBitmapData(bitmapDrawable, scale, clipRect, backgroundColor, pixelSnapping, smoothing);
			var byteArray:ByteArray = encodeBitmapData(bitmapData, encoderType, jpgQuality);
			
			return byteArray;
		}
		
		public static function encodeBitmapData(bitmapData:BitmapData, encoderType:String, jpgQuality:int=85):ByteArray {
			
			var encoder:IImageEncoder;
			var byteArray:ByteArray;
			
			switch (encoderType) {
				case JPG_ENCODER: {
					encoder = new JPEGEncoder(jpgQuality);
					byteArray = encoder.encode(bitmapData);
					break;
				}
				default:
				case PNG_ENCODER: {
					encoder = new PNGEncoder();
					byteArray = encoder.encode(bitmapData);
					break;
				}
			}
			
			return byteArray;
		}
		
		public static function encodeByteArray(byteArray:ByteArray, width:uint, height:uint, encoderType:String, jpgQuality:int=85, transparent:Boolean=true):ByteArray {
			
			var encoder:IImageEncoder;
			
			switch (encoderType) {
				case JPG_ENCODER: {
					encoder = new JPEGEncoder(jpgQuality);
					byteArray = encoder.encodeByteArray(byteArray, width, height, transparent);
					break;
				}
				default:
				case PNG_ENCODER: {
					encoder = new PNGEncoder();
					byteArray = encoder.encodeByteArray(byteArray, width, height, transparent);
					break;
				}
			}
			
			return byteArray;
		}
		
		/* Flash 10
		public static function saveBitmapDataAs(bitmapData:BitmapData, encoderType:String, fileName:String=null):void {
            var byteArray:ByteArray = getEncodedByteArray(bitmapData, encoderType);
            saveByteArrayAs(byteArray, fileName);
		}
		
		private static function saveByteArrayAs(byteArray:ByteArray, fileName:String=null):void {
			var fileReference:FileReference = new FileReference();
            fileReference.save(byteArray, fileName);
            byteArray.clear();
		}*/
		
	}
	
}
package nl.mediamonkey.utils {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	//import mx.graphics.codec.IImageEncoder;
	//import mx.graphics.codec.JPEGEncoder;
	//import mx.graphics.codec.PNGEncoder;
	
	// use these instead of mx package
	import temple.data.encoding.image.JPGEncoder;
	import temple.data.encoding.image.PNGEncoder;
	
	public class ImageUtil {
		
		public static const JPG_ENCODER:String = "image/jpg";
		public static const PNG_ENCODER:String = "image/png";
		
		// ---- public methods ----
		
		public static function getBitmap(bitmapDrawable:IBitmapDrawable, scale:Number=1, clipRect:Rectangle=null,
			backgroundColor:Number=0x00FFFFFF, pixelSnapping:String="auto", smoothing:Boolean=true):Bitmap {
			
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
			backgroundColor:Number=0x00FFFFFF, pixelSnapping:String="auto", smoothing:Boolean=true):BitmapData {
			
			var bitmap:Bitmap = getBitmap(bitmapDrawable, scale, clipRect, backgroundColor, pixelSnapping, smoothing);
			return bitmap.bitmapData;
		}
		
		public static function getJPGByteArray(bitmapDrawable:IBitmapDrawable, jpgQuality:int=85, scale:Number=1, clipRect:Rectangle=null,
			backgroundColor:Number=0x00FFFFFF, pixelSnapping:String="auto", smoothing:Boolean=true):ByteArray {
			
			var bitmapData:BitmapData = getBitmapData(bitmapDrawable, scale, clipRect, backgroundColor, pixelSnapping, smoothing);
			return encodeBitmapData(bitmapData, JPG_ENCODER, jpgQuality);
		}
		
		public static function getPNGByteArray(bitmapDrawable:IBitmapDrawable, scale:Number=1, clipRect:Rectangle=null,
			backgroundColor:Number=0x00FFFFFF, pixelSnapping:String="auto", smoothing:Boolean=true):ByteArray {
			
			var bitmapData:BitmapData = getBitmapData(bitmapDrawable, scale, clipRect, backgroundColor, pixelSnapping, smoothing);
			return encodeBitmapData(bitmapData, PNG_ENCODER);
		}
		
		public static function encodeBitmapData(bitmapData:BitmapData, encoderType:String, jpgQuality:int=85):ByteArray {
			
			var byteArray:ByteArray;
			
			switch (encoderType) {
				case JPG_ENCODER: {
					var jpgEncoder:JPGEncoder = new JPGEncoder(jpgQuality);
					byteArray = jpgEncoder.encode(bitmapData);
					break;
				}
				default:
				case PNG_ENCODER: {
					byteArray = PNGEncoder.encode(bitmapData);
					break;
				}
			}
			
			return byteArray;
		}
		
		/* Flash 10
		private static function saveAs(image:Object, fileName:String=null, encoderType:String="image/png", jpgQuality:int=85):Boolean {
			if (image is Bitmap) {
				image = (image as Bitmap).bitmapData;
			}
			
			if (image is BitmapData) {
				image = getEncodedByteArray(image as BitmapData, encoderType, jpgQuality);
			}
			
			if (image is ByteArray) {
				var fileReference:FileReference = new FileReference();
            	fileReference.save(byteArray, fileName);
            	byteArray.clear();
            	return true;
            }
            return false;
		}*/
		
	}
	
}
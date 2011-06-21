package nl.mediamonkey.utils {
	
	//import com.adobe.images.JPGEncoder;
	//import com.adobe.images.PNGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	
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
					var jpgEncoder:JPEGEncoder = new JPEGEncoder(jpgQuality);
					byteArray = jpgEncoder.encode(bitmapData);
					break;
				}
				default:
				case PNG_ENCODER: {
					var pngEncoder:PNGEncoder = new PNGEncoder();
					byteArray = pngEncoder.encode(bitmapData);
					break;
				}
			}
			
			return byteArray;
		}
		
		/**
		 * Get the bounds of non-transparent pixels of a (possibly masked) displayobject.
		 * @param display The displayobject you wish to crop to the smallest size without cropping any non-transparent pixels
		 * @return A rectangle of the translate and size of the measured boundary
		 */
		public static function getCropBounds(display:DisplayObject):Rectangle {
			var bmd:BitmapData = new BitmapData(display.width / display.scaleX, display.height / display.scaleY, true, 0x00000000);
			bmd.draw(display);
			var bounds:Rectangle = bmd.getColorBoundsRect(0xFF000000, 0x00000000, false);
			bmd.dispose();
			return bounds;
		}
		
		public static function saveAs(image:Object, fileName:String=null, encoderType:String="image/png", jpgQuality:int=85):Boolean {
			if (image is Bitmap) {
				image = (image as Bitmap).bitmapData;
			}
			
			if (image is BitmapData) {
				image = encodeBitmapData(image as BitmapData, encoderType, jpgQuality);
			}
			
			if (image is ByteArray) {
				var fileReference:FileReference = new FileReference();
            	fileReference.save(image as ByteArray, fileName);
				(image as ByteArray).clear();
            	return true;
            }
            return false;
		}
		
	}
	
}
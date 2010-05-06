package nl.mediamonkey.utils {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.IImageEncoder;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	
	import nl.mediamonkey.enum.FlipDirection;
	
	/**
	 * TODO:
	 * 		. test merge method
	 * 		. test if methods use displayobject instead of a bitmap when resizing to bitmap
	 * 		. test all methods with bitmapdata as input
	 * 
	 */
	
	public class ImageUtil {
		
		public static const JPG_ENCODER:String = "image/jpg";
		public static const PNG_ENCODER:String = "image/png";
		
		// ---- public static methods ----
		
		public static function getBitmap(bitmapDrawable:IBitmapDrawable, scale:Number=1, clipRect:Rectangle=null,
			backgroundColor:Number=0x00FFFFFF, pixelSnapping:String="auto", smoothing:Boolean=true):Bitmap {
			trace("\n----");
			if (!EnumUtil.hasConst(PixelSnapping, pixelSnapping))
				throw new ArgumentError("invalid pixelSnapping value");
			
			var w:Number;
			var h:Number;
			var canvas:BitmapData;
			var bitmap:Bitmap;
			var matrix:Matrix;
			
			if (bitmapDrawable is BitmapData) {
				var bitmapData:BitmapData = bitmapDrawable as BitmapData;
				
				w = bitmapData.width * scale;
				h = bitmapData.height * scale;
				
				canvas = new BitmapData(w, h, true, backgroundColor);
				bitmap = new Bitmap(canvas, pixelSnapping, smoothing);
				
				matrix = new Matrix();
				matrix.scale(scale, scale);
				
				canvas.draw(bitmapData, matrix, null, null, clipRect, smoothing);
				
				return bitmap;
				
			} else {
				var displayObject:DisplayObject = bitmapDrawable as DisplayObject;
				
				w = (displayObject.width / displayObject.scaleX) * scale;
				h = (displayObject.height / displayObject.scaleY) * scale;
				
				canvas = new BitmapData(w, h, true, backgroundColor);
				bitmap = new Bitmap(canvas, pixelSnapping, smoothing);
				
				matrix = new Matrix();
				
				trace("displayObject.getBounds(bitmap): " + (displayObject.getBounds(bitmap)));
				var dx:Number = -displayObject.getBounds(displayObject).x;// + displayObject.x;
				var dy:Number = -displayObject.getBounds(displayObject).y;// + displayObject.y
				matrix.translate(dx, dy);
				trace("matrix: " + (matrix));
				
				matrix.scale(scale, scale);
				trace("matrix: " + (matrix));
				
				canvas.draw(displayObject, matrix, null, null, clipRect, smoothing);
				
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
			var encoder:IImageEncoder;
			
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
		
		public static function crop(bitmapDrawable:IBitmapDrawable, cropRect:Rectangle):Bitmap {
			return getBitmap(bitmapDrawable, 1, cropRect);
		}
		
		public static function rotate(bitmapDrawable:IBitmapDrawable, degrees:Number):Bitmap {
			// TODO
			return null;
		}
		
		public static function flip(bitmapDrawable:IBitmapDrawable, direction:String):Bitmap {
			if (!EnumUtil.hasConst(FlipDirection, direction))
				throw new ArgumentError("invalid direction value");
			
			return null;
		}
		
		/**
		 * creates a bitmap of an enlarged target (resize)
		 * stretching will occur if the width/height ratio isn't 1
		 * no cropping will occur
		 */
		public static function resizeImage(bitmapDrawable:IBitmapDrawable, width:uint, height:uint, maintainRatio:Boolean=true):Bitmap {
			// TODO
			// build matrix with new width, height
			// bitmapdata.draw(bitmapDrawable, matrix);
			
			return null;
		}
		
		/**
		 * creates a new bitmap and draws the target (grow/shrink)
		 * cropping will occur when input width/height are lower then the target's
		 * no stretching will occur
		 */
		public static function resizeCanvas(bitmapDrawable:IBitmapDrawable, width:uint, height:uint, backgroundColor:uint=0x00FFFFFF):Bitmap {
			// TODO
			return null;
		}
		
		public static function size(bitmapDrawable:IBitmapDrawable, width:uint, height:uint):Bitmap {
			
			var scale:Number;
			var bitmap:Bitmap;
			
			if (bitmapDrawable is BitmapData) {
				var bitmapData:BitmapData = bitmapDrawable as BitmapData;
				
				if (bitmapData.width > width || bitmapData.height > height) {
					
					var proxy:DisplayObject = new DisplayObject();
					proxy.width = bitmapData.width;
					proxy.height = bitmapData.height;
					
					scale = ScaleUtil.getScale(proxy, width, height);
					bitmap = getBitmap(bitmapData, scale);
					
				} else {
					bitmap = getBitmap(bitmapData, 1);
				}
				
			} else {
				var displayObject:DisplayObject = bitmapDrawable as DisplayObject;
				
				var w:Number = displayObject.width / displayObject.scaleX;
				var h:Number = displayObject.height / displayObject.scaleY;
				
				if (w > width || h > height) { // scale down if the object is larger then the size
					scale = ScaleUtil.getScale(displayObject, width, height);
					bitmap = getBitmap(displayObject, scale);
					
				} else {
					bitmap = getBitmap(bitmapDrawable, 1);
				}
			}
			
			// difference (center image in canvas)
			var dw:Number = (bitmap.width - width)/2;
			var dh:Number = (bitmap.height - height)/2;
			
			var matrix:Matrix = new Matrix();
			matrix.translate(-dw, -dh);
			
			var canvas:BitmapData = new BitmapData(width, height, true, 0x00FFFFFF);
			canvas.draw(bitmap, matrix, null, BlendMode.NORMAL, null, true);
			return new Bitmap(canvas);
		}
		
		public static function merge(layers:Array, blendMode:String="normal"):Bitmap {
			if (!EnumUtil.hasConst(BlendMode, blendMode))
				throw new ArgumentError("invalid blendMode value");
			
			var rect:Rectangle = getUnionRect(layers);
			var canvas:BitmapData = new BitmapData(rect.width, rect.height);
			
			var bitmapDrawable:IBitmapDrawable;
			for each (bitmapDrawable in layers) {
				canvas.draw(canvas, null, null, blendMode);
			}
			
			return new Bitmap(canvas);
		}
		
		// http://flanture.blogspot.com/2010/05/as3-dynamic-bitmap-split-function.html
		function splitBitmap(data:BitmapData, columns:int, rows:int):void {
		    var _bitmapWidth:int = data.width;
		    var _bitmapHeight:int = data.height;
		    
		    var _onePieceWidth:Number = Math.round(_bitmapWidth / columns);
		    var _onePieceHeight:Number = Math.round(_bitmapWidth / rows);
		    
		    var _copyRect:Rectangle = new Rectangle(0, 0, _onePieceWidth, _onePieceHeight);
		    
		    for(var i:int = 0; i < columns; i++) {
		        var tempArray:Array = new Array();
		        
		        for(var j:int = 0; j < rows; j++) {
		            var _piece:String = "piece"+String(i)+String(j);
		            var temp:* = [_piece];
		            temp = new BitmapData(_onePieceWidth, _onePieceHeight, true, 0xFF0000CC);
		            
		            var newBytes:ByteArray = data.getPixels(_copyRect);
		            newBytes.position = 0;
		            temp.setPixels(_copyRect, newBytes);
		            
		            var _newBitmap:String = "newBitmap"+String(i)+String(j);
		            var tempBitmap:* = [_newBitmap];
		            tempBitmap = new Bitmap(temp);
		            
		            tempBitmap.x = i * (_onePieceWidth) + bm1.x;
		            tempBitmap.y = j * (_onePieceHeight)+ bm1.y;
		            addChild(tempBitmap);
		            
		            tempArray.push(tempBitmap);
		        }
		        bitmapsArray.push(tempArray);
		    }
		}
		
		/* Flash 10
		public static function saveAs(image:Object, fileName:String=null, encoderType:String="image/png", jpgQuality:int=85):Boolean {
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
		
		// ---- protected static methods ----
		
		protected static function getUnionRect(collection:Array):Rectangle {
			var unionRect:Rectangle = new Rectangle();
			
			var item:DisplayObject;
			for each (item in collection) {
				unionRect.union(item.getRect(item.root));
			}
			
			return unionRect;
		}
		
		// old getBitmap
		
		/*var displayObject:DisplayObject = bitmapDrawable as DisplayObject;
		
		var bounds:Rectangle = displayObject.getBounds(displayObject.parent);
		var w:Number = ((bounds.width + bounds.x) / displayObject.scaleX) * scale;
		var h:Number = ((bounds.height + bounds.y) / displayObject.scaleY) * scale;
		
		canvas = new BitmapData(w, h, true, backgroundColor);
		bitmap = new Bitmap(canvas, pixelSnapping, smoothing);
		
		matrix = new Matrix();
		matrix.scale(scale, scale);
		
		canvas.draw(displayObject, matrix, null, null, clipRect, smoothing);
		
		return bitmap;*/
		
	}
	
}
package nl.mediamonkey.utils {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.getQualifiedClassName;
	
	import mx.controls.Button;
	import mx.graphics.ImageSnapshot;
	import mx.utils.DisplayUtil;
	import mx.utils.GraphicsUtil;
	import mx.utils.LoaderUtil;
	
	import nl.elthigrav.model.Model;
	import nl.mediamonkey.utils.enum.ZoomMode;
	
	public class DisplayListUtil {
		
		// recursive algorithm that returns all children in the displaylist as a flat array
		public static function getFlattenedDisplayList(target:DisplayObjectContainer):Array {
			var children:Array = new Array();
			var child:DisplayObject;
			
			for (var i:int=0; i<target.numChildren; i++) {
				child = target.getChildAt(i);
				
				if (child.hasOwnProperty("numChildren") && (child as DisplayObjectContainer).numChildren > 0) {
					children = children.concat( getFlattenedDisplayList(child as DisplayObjectContainer) );
					
				} else {
					children.push(child);
				}
			}
			
			return children;
		}
		
		// from: http://www.kirupa.com/forum/showpost.php?p=1939827&postcount=172
		public static function duplicateDisplayObject(target:DisplayObject, autoAdd:Boolean = false):DisplayObject {
			
			// create duplicate
			var targetClass:Class = Object(target).constructor;
			var duplicate:DisplayObject = new targetClass();
			
			// duplicate properties
			duplicate.transform = target.transform;
			duplicate.filters = target.filters;
			duplicate.cacheAsBitmap = target.cacheAsBitmap;
			duplicate.opaqueBackground = target.opaqueBackground;
			
			if (target.scale9Grid) {
				var rect:Rectangle = target.scale9Grid;
				// WAS Flash 9 bug where returned scale9Grid is 20x larger than assigned
				// rect.x /= 20, rect.y /= 20, rect.width /= 20, rect.height /= 20;
				duplicate.scale9Grid = rect;
			}
			
			// add to target parent's display list
			// if autoAdd was provided as true
			if (autoAdd && target.parent) target.parent.addChild(duplicate);
			
			return duplicate;
		}
		
		public static function getObjectsUnderPoint(target:DisplayObjectContainer, local:Point):Array {
			var global:Point = target.localToGlobal(local);
			var objects:Array = DisplayListUtil.getFlattenedDisplayList(target);
			
			var display:DisplayObject;
			var result:Array = [];
			
			for each (display in objects) {
				local = display.globalToLocal(global);
				
				if (display.getBounds(display.parent).containsPoint(local))
					result.push(display);
			}
			
			return result;
		}
		
		// returns an inverse matrix with which you can position/skew/scale a target displayobject to the visual relative transform when placed in the container
		public static function concatenateMatrixToContainer(target:DisplayObject, container:DisplayObjectContainer):Matrix {
			var m:Matrix = target.transform.matrix.clone();
			if (target == container) return m;
			
			do {
				m.concat(target.parent.transform.matrix);
				target = target.parent;
				
				// if there is no parent, the target is not on the displaylist
				if (target == null) return null;
				
				// if we reach the root and haven't encountered the container, the container is not a (grand)parent of the target
				if (target == target.root && target != container) return null;
				
			} while (target != target.root && target != container);
			
			return m;
		}
		
		/**
		 * Creates a red sprite, masked by the shape of the target object and added to the container.
		 * The container must be a parent of the target, and can be the top level (or root container) of the entire application.
		 *
		 * @param target			The target displayobject from which we build a mask.
		 * @param container			The container where the masked texture should be added. Must be a grandparent of the target.
		 * @param textureSource		The texture source used to draw bitmapdata with. If null, the shape will be drawn in red with an alpha of 0.5.
		 * @param borderThickness	The stroke thickness of the target, if any.
		 * @param fit				Should the texture fit within the shape?
		 * @param repeat			Should the texture repeat within the shape? If fit is true, this parameter won't have any visible effect.
		 */
		public static function createMaskedTexture(target:DisplayObject, container:DisplayObjectContainer, textureSource:*,
												   borderThickness:Number=0, zoomMode:String="fit", resizeMode:uint=1, repeat:Boolean=true):Sprite {
			
			if (textureSource is String || textureSource is URLRequest) {
				loadTexture(textureSource, createMaskedTexture, target, container, textureSource, borderThickness, zoomMode, resizeMode, repeat);
				return null; // TODO: return placeholder
			}
			
			//@param padding Extra spacing around the drawn shape, not sure if it is needed anymore.
			var padding:Number = 0;
			
			// get global pixel bounds plus added padding
			var bounds:Rectangle = target.transform.pixelBounds;
			bounds.x -= padding;
			bounds.y -= padding;
			bounds.width += padding * 2;
			bounds.height += padding * 2;
			
			// get concatenated matrix (= global space)
			var matrix:Matrix = target.transform.concatenatedMatrix;
			
			// solved offset: remove bounds from matrix position
			matrix.tx += borderThickness - bounds.x;
			matrix.ty += borderThickness - bounds.y;
			
			// build and draw bitmapdata, then later re-use the matrix in local space
			var maskBD:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00FFFFFF);
			maskBD.draw(target, matrix);
			
			// invert container matrix scale to correctly size our mask when placing it in the container
			var cm:Matrix = container.transform.concatenatedMatrix;
			matrix.a = 1/cm.a;
			matrix.d = 1/cm.d;
			
			// set container's local position
			var local:Point = container.globalToLocal(new Point(bounds.x, bounds.y));
			matrix.tx = local.x;
			matrix.ty = local.y;
			
			// add bitmap mask to the container
			var maskBitmap:Bitmap = new Bitmap(maskBD);
			maskBitmap.blendMode = BlendMode.ALPHA; // use the alpha channel to mask out the shape
			maskBitmap.cacheAsBitmap = true; // must cache to be able to use it as a mask
			maskBitmap.transform.matrix = matrix;
			
			// get bitmapData from textureSource
			var bitmapData:BitmapData;
			
			if (textureSource is Class) {
				var cls:Class = textureSource as Class;
				textureSource = new cls();
			}
			
			if (textureSource is BitmapData) {
				bitmapData = BitmapData(textureSource);
				
			} else if (textureSource is Bitmap) {
				bitmapData = Bitmap(textureSource).bitmapData;
				
			} else if (textureSource is DisplayObject) {
				var display:DisplayObject = DisplayObject(textureSource);
				bitmapData = ImageSnapshot.captureBitmapData(display);
			}
			
			var drawMatrix:Matrix = new Matrix();
			
			if (bitmapData) {
				//if (fitWidth) drawMatrix.a = bounds.width / bitmapData.width;
				//if (fitHeight) drawMatrix.d = bounds.height / bitmapData.height;
				
				// get scale (maintainRatio = true)
				var scale:Number = ScaleUtil.getScale(bitmapData.width, bitmapData.height, bounds.width, bounds.height, zoomMode, resizeMode);
				drawMatrix.a = drawMatrix.d = scale;
				
				// center texture if it is bigger than the bounds
				if (scale < 1) {
					drawMatrix.tx = (bounds.width - bitmapData.width * scale)/2;
					drawMatrix.ty = (bounds.height - bitmapData.height * scale)/2;
				}
			}
			
			// create sprite and draw the texture, or with a red color
			var drawSprite:Sprite = new Sprite();
			drawSprite.cacheAsBitmap = true; // must cache to be able to use the mask
			drawSprite.transform.matrix = matrix;
			
			if (bitmapData) drawSprite.graphics.beginBitmapFill(bitmapData, drawMatrix, repeat);
			else drawSprite.graphics.beginFill(0xFF0000, 0.5);
			drawSprite.graphics.drawRect(0, 0, bounds.width, bounds.height);
			drawSprite.graphics.endFill();
			
			// add to the provided container and set the mask
			container.addChild(maskBitmap);
			
			if (container != target.parent) container.addChild(drawSprite);
			else container.addChildAt(drawSprite, container.getChildIndex(target)+1);
			
			drawSprite.mask = maskBitmap;
			
			return drawSprite;
		}
		
		private static function loadTexture(source:*, callback:Function, ...params):void {
			var request:URLRequest;
			if (source is URLRequest) request = URLRequest(source);
			else if (source is String) request = new URLRequest(source as String);
			
			// check if the source is also a parameter
			var resultArgumentIndex:int = params.indexOf(source);
			
			var urlLoader:URLLoader = new URLLoader(request);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			urlLoader.addEventListener(Event.COMPLETE,
				function(event:Event):void {
					
					// load the binairy texture in a loader
					var loader:Loader = new Loader();
					
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
						function(event:Event):void {
							
							// get the bitmapdata from the loader and set as parameter
							if (resultArgumentIndex > -1) params[resultArgumentIndex] = ImageSnapshot.captureBitmapData(loader);
							
							switch (params.length) {
								case 0: callback.call(null); break;
								case 1: callback.call(null, params[0]); break;
								case 2: callback.call(null, params[0], params[1]); break;
								case 3: callback.call(null, params[0], params[1], params[2]); break;
								case 4: callback.call(null, params[0], params[1], params[2], params[3]); break;
								case 5: callback.call(null, params[0], params[1], params[2], params[3], params[4]); break;
								case 6: callback.call(null, params[0], params[1], params[2], params[3], params[4], params[5]); break;
								case 7: callback.call(null, params[0], params[1], params[2], params[3], params[4], params[5], params[6]); break;
								case 8: callback.call(null, params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7]); break;
								case 9: callback.call(null, params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8]); break;
								case 10: callback.call(null, params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9]); break;
							}
							
						}
					); // end of loader.contentLoaderInfo.addEventListener
						
					loader.loadBytes(urlLoader.data);
				}
			); // end of urlLoader.addEventListener
		}
		
	}
}
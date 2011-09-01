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
	
	public class DisplayListUtil {
		
		/*public static const NODES	:int = 0;
		public static const LEAFS	:int = 0;
		public static const ALL		:int = 0;*/
		
		// recursive algorithm that returns all children in the displaylist as a flat array
		public static function getFlattenedDisplayList(target:DisplayObjectContainer, leafsOnly:Boolean=false):Array {
			var children:Array = new Array();
			var child:DisplayObject;
			
			for (var i:int=0; i<target.numChildren; i++) {
				child = target.getChildAt(i);
				if (!leafsOnly) children.push(child);
				
				if (child.hasOwnProperty("numChildren") && (child as DisplayObjectContainer).numChildren > 0) {
					children = children.concat( getFlattenedDisplayList(child as DisplayObjectContainer) );
					
				} else if (leafsOnly) {
					children.push(child);
				}
			}
			
			return children;
		}
		
		// breadth-first
		public static function traceDisplayListTree(target:DisplayObjectContainer, tabs:int=0):void {
			var child:DisplayObject;
			
			for (var i:int=0; i<target.numChildren; i++) {
				child = target.getChildAt(i);
				
				var tabString:String = "";
				for (var t:int=0; t<tabs; t++) {
					tabString += (t < tabs-1) ? "  " : "+ ";
				}
				//tabString = tabString.split("  + ").join("|-+ ");
				
				var type:String = getQualifiedClassName(child);
				if (type.indexOf("::") > -1) type = type.split("::")[1];
				trace(tabString + child.name + "("+type+")");
				
				if (child.hasOwnProperty("numChildren") && (child as DisplayObjectContainer).numChildren > 0) {
					traceDisplayListTree(child as DisplayObjectContainer, tabs + 1);
				}
			}
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
			var matrix:Matrix = target.transform.matrix.clone();
			if (target == container) return matrix;
			
			do {
				matrix.concat(target.parent.transform.matrix);
				target = target.parent;
				
				// if there is no parent, the target is not on the displaylist
				if (target == null) return null;
				
				// if we reach the root and haven't encountered the container, the container is not a (grand)parent of the target
				if (target == target.root && target != container) return null;
				
			} while (target != target.root && target != container);
			
			return matrix;
		}
		
		/**
		 * Creates a red sprite, masked by the shape of the target object and added to the container.
		 * The container must be a parent of the target, and can be the top level (or root container) of the entire application.
		 * If the texture must be loaded, a contentHolder sprite will be returned.
		 *
		 * @param target			The target displayobject from which we build a mask.
		 * @param container			The container where the masked texture should be added. Must be a grandparent of the target.
		 * @param textureSource		The texture source used to draw bitmapdata with. If null, the shape will be drawn in red with an alpha of 0.5.
		 * @param borderThickness	The stroke thickness of the target, if any.
		 * @param zoomMode			Resize the texture within the target boundaries
		 * @param resizeMode		Resize up, down or whatever.
		 * @param repeat			Should the texture repeat within the shape? If fit is true, this parameter won't have any visible effect.
		 * @param padding			Extra spacing around the drawn shape; not sure if it is needed anymore (and isn't tested much).
		 */
		public static function createMaskedTexture(target:DisplayObject, container:DisplayObjectContainer, textureSource:*,
			borderThickness:Number=0, zoomMode:String="fit", resizeMode:uint=3, repeat:Boolean=true, padding:int=0):Sprite {
			
			// if we need to load a texture, return a placeholder sprite where the texture will be drawn in 
			if (textureSource is String || textureSource is URLRequest) {
				
				// the contentHolder's transform is irrelevant as the texture will be drawn correctly
				var contentHolder:Sprite = new Sprite();
				
				// place the contentHolder on top
				if (container != target.parent) container.addChild(contentHolder);
				else container.addChildAt(contentHolder, container.getChildIndex(target)+1);
				
				// now load the texture and call back this method with the parameters
				loadTexture(textureSource, createMaskedTexture, target, contentHolder,
					textureSource, borderThickness, zoomMode, resizeMode, repeat, padding);
				
				return contentHolder;
			}
			
			// get global pixel bounds plus added padding
			var bounds:Rectangle = target.transform.pixelBounds;
			bounds.x -= padding;
			bounds.y -= padding;
			bounds.width += padding * 2;
			bounds.height += padding * 2;
			
			// get concatenated matrix (= global space)
			var matrix:Matrix = target.transform.concatenatedMatrix;
			matrix.tx += -bounds.x + borderThickness;
			matrix.ty += -bounds.y + borderThickness;
			
			// build and draw bitmapdata, then later re-use the matrix in local space
			var maskBD:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00FFFFFF);
			maskBD.draw(target, matrix);
			
			// invert container matrix scale to correctly size our mask when placing it in the container
			var transformMatrix:Matrix = new Matrix();
			var cm:Matrix = container.transform.concatenatedMatrix;
			transformMatrix.a = 1/cm.a;
			transformMatrix.d = 1/cm.d;
			
			// set container's local position
			var local:Point = container.globalToLocal(new Point(bounds.x, bounds.y));
			transformMatrix.tx = local.x;
			transformMatrix.ty = local.y;
			
			// add bitmap mask to the container
			var maskBitmap:Bitmap = new Bitmap(maskBD);
			maskBitmap.cacheAsBitmap = true; // must cache to be able to use it as a mask
			maskBitmap.blendMode = BlendMode.ALPHA; // use the alpha channel to mask out the shape
			maskBitmap.transform.matrix = transformMatrix;
			
			// get bitmapData from textureSource
			var bitmapData:BitmapData = getBitmapData(textureSource);
			
			var drawMatrix:Matrix = new Matrix();
			
			if (bitmapData) {
				
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
			drawSprite.transform.matrix = transformMatrix;
			
			// draw bitmapdata or a solid half transparent red shape
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
		
		public static function getBitmapData(source:*):BitmapData {
			var bitmapData:BitmapData;
			
			if (source is Class) {
				var cls:Class = source as Class;
				source = new cls();
			}
			
			if (source is BitmapData) {
				bitmapData = BitmapData(source);
				
			} else if (source is Bitmap) {
				bitmapData = Bitmap(source).bitmapData;
				
			} else if (source is DisplayObject) {
				var display:DisplayObject = DisplayObject(source);
				bitmapData = ImageSnapshot.captureBitmapData(display);
			}
			
			return bitmapData;
		}
		
		// ---- private methods ----
		
		private static function loadTexture(source:*, callback:Function, ...params):void {
			var request:URLRequest;
			
			if (source is URLRequest) request = URLRequest(source);
			else if (source is String) request = new URLRequest(source as String);
			else throw new TypeError("source must be of type String or URLRequest");
			
			// check if the source is also a parameter
			var resultArgumentIndex:int = params.indexOf(source);
			
			var urlLoader:URLLoader = new URLLoader(request);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			urlLoader.addEventListener(Event.COMPLETE,
				function(event:Event):void {
					
					// load the binairy texture in a loader
					var loader:Loader = new Loader();
					loader.loadBytes(urlLoader.data);
					
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
						function(event:Event):void {
							
							// get the bitmapdata from the loader and set as parameter
							if (resultArgumentIndex > -1)
								params[resultArgumentIndex] = ImageSnapshot.captureBitmapData(loader);
							
							callback.apply(null, params);
						}
					); // end of loader.contentLoaderInfo.addEventListener
				}
			); // end of urlLoader.addEventListener
		}
		
	}
}
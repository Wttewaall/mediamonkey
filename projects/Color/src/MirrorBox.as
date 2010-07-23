package {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Box;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.events.ChildExistenceChangedEvent;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	
	public class MirrorBox extends Box {
		
		// ---- variables ----
		
		public var mirrorColor			:uint = 0xFFFFFF;
		public var mirrorColorStrength	:Number = 0;
		public var mirrorHeight			:Number = 20;
		public var mirrorAlpha			:Number = 0.5;
		public var mirrorOffsetX		:Number = 0;
		public var mirrorOffsetY		:Number = 0;
		
		protected var children			:Array;
		protected var mirror			:Bitmap;
		protected var mirrorData		:BitmapData;
		protected var childChanged		:Boolean;
		
		protected var cache				:BitmapDataCache;
		protected var USE_CACHE			:Boolean = false; // TO FIX
		
		// ---- getters & setters ----
		
		// ---- constructor ----
		
		public function MirrorBox() {
			super();
			
			children = new Array();
			cache = new BitmapDataCache(20);
			
			addEventListener(ChildExistenceChangedEvent.CHILD_ADD, childAddHandler);
			addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE, childRemoveHandler);
			addEventListener(IndexChangedEvent.CHILD_INDEX_CHANGE, childIndexChangeHandler);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			mirror = new Bitmap();
			rawChildren.addChild(mirror);
		}
		
		protected function childAddHandler(event:ChildExistenceChangedEvent):void {
			var child:DisplayObject = event.relatedObject;
			
			child.removeEventListener(Event.ADDED_TO_STAGE, childAddedToStage);
			child.addEventListener(Event.ADDED_TO_STAGE, childAddedToStage);
			
			if (child is UIComponent) {
				UIComponent(child).removeEventListener(FlexEvent.UPDATE_COMPLETE, childRenderHandler);
				UIComponent(child).addEventListener(FlexEvent.UPDATE_COMPLETE, childRenderHandler);
				
			} else {
				child.removeEventListener(Event.RENDER, childRenderHandler);
				child.addEventListener(Event.RENDER, childRenderHandler);
			}
			children.push(child);
		}
		
		protected function childRemoveHandler(event:ChildExistenceChangedEvent):void {
			var child:DisplayObject = event.relatedObject;
			
			if (child is UIComponent)
				UIComponent(child).removeEventListener(FlexEvent.UPDATE_COMPLETE, childRenderHandler);
			
			child.removeEventListener(Event.RENDER, childRenderHandler);
			
			var index:int = children.indexOf(child);
			if (index > -1) children.splice(index, 1);
			
			childChanged = true;
			invalidateDisplayList();
		}
		
		protected function childIndexChangeHandler(event:IndexChangedEvent):void {
			// keep mirror at the bottom index
			rawChildren.setChildIndex(mirror, 0);
		}
		
		protected function childAddedToStage(event:Event):void {
			event.currentTarget.removeEventListener(Event.ADDED_TO_STAGE, childAddedToStage);
			childChanged = true;
			invalidateDisplayList();
		}
		
		protected function childRenderHandler(event:Event):void {
			if (stage) updateMirror();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (stage && childChanged) {
				childChanged = false;
				updateMirror();
			}
		}
		
		protected function updateMirror():void {
			// without a stage we can't calculate the bounds of children
			if (!stage) return;
			
			// without children we can't calculate the bounds of those children
			if (numChildren == 0) return;
			
			// get bounds, resize mirror bitmap accordingly
			var bounds:Rectangle = combineRectangles(children);
			var br:Rectangle = measureMinMax(children, "br");
			bounds.y = br.top;
			bounds.height = br.height + mirrorHeight;
			
			if (bounds.height > 2048) { // TO FIX
				trace("Fatal error averted", bounds.height);
				return;
			}
			
			if (USE_CACHE) {
				mirrorData = cache.getBitmapData(bounds.width, bounds.height);
				
				if (!mirrorData) {
					mirrorData = new BitmapData(bounds.width, bounds.height, true, 0x00FFFFFF);
					cache.addCache(bounds.width, bounds.height, mirrorData, true);
					
				} else {
					mirrorData.fillRect(new Rectangle(0, 0, mirrorData.width, mirrorData.height), 0x00FFFFFF);
				}
			
			} else {
				// simple: create new bitmapdata every time
				mirrorData = new BitmapData(bounds.width, bounds.height, true, 0x00FFFFFF);
			}
			
			// draw all child reflections
			for (var i:uint=0; i<numChildren; i++) {
				drawReflection(getChildAt(i), -bounds.x, -bounds.y);
			}
			
			// move mirror to bounds position
			mirror.x = bounds.x;
			mirror.y = bounds.y;
			
			mirror.bitmapData = mirrorData;
			rawChildren.setChildIndex(mirror, 0);
		}
		
		protected function combineRectangles(array:Array):Rectangle {
			var result:Rectangle;
			var bounds:Rectangle;
			
			var object:DisplayObject;
			for each (object in array) {
				
				bounds = object.getBounds(object.parent);
				result = (!result) ? bounds : result.union(bounds);
			}
			
			return result;
		}
		
		public function measureMinMax(array:Array, direction:String):Rectangle {
			var bounds:Rectangle;
			
			var minX:Number = Infinity;
			var minY:Number = Infinity;
			var maxX:Number = 0;
			var maxY:Number = 0;
			
			var object:DisplayObject;
			for each (object in array) {
				
				bounds = object.getBounds(object.parent);
				
				if (direction == "tl") {
					minX = Math.min(bounds.left, minX);
					minY = Math.min(bounds.top, minY);
					maxX = Math.max(bounds.left, maxX);
					maxY = Math.max(bounds.top, maxY);
					
				} else if (direction == "cm") {
					minX = Math.min(bounds.left + bounds.width/2, minX);
					minY = Math.min(bounds.top + bounds.height/2, minY);
					maxX = Math.max(bounds.left + bounds.width/2, maxX);
					maxY = Math.max(bounds.top + bounds.height/2, maxY);
					
				} else if (direction == "br") {
					minX = Math.min(bounds.right, minX);
					minY = Math.min(bounds.bottom, minY);
					maxX = Math.max(bounds.right, maxX);
					maxY = Math.max(bounds.bottom, maxY);
				}
			}
			
			if (minX == Infinity) minX = 0;
			if (minY == Infinity) minY = 0;
			
			return new Rectangle(minX, minY, maxX - minX, maxY - minY);
		}
		
		protected function drawReflection(object:DisplayObject, offsetX:Number, offsetY:Number):void {
			
			var bounds:Rectangle = object.getBounds(object.parent);
			bounds.offset(offsetX + mirrorOffsetX, offsetY + mirrorOffsetY);
			
			// no need to draw invisible objects
			if (bounds.width == 0 || bounds.height == 0) return;
			
			// flip horizontally, then offset by bounds.height
			var matrix:Matrix = new Matrix();
			matrix.scale(1, -1);
			matrix.translate(0, bounds.height);
			
			// use mirrorColorStrength as a multiplier
			var s:Number = Math.max(0, Math.min(mirrorColorStrength, 1));
			var i:Number = (1-s);
			
			// calculate color offsets on mirrorColor
			var r:Number = Math.round(s * (mirrorColor >> 16 & 0xFF));
			var g:Number = Math.round(s * (mirrorColor >> 8 & 0xFF));
			var b:Number = Math.round(s * (mirrorColor & 0xFF));
			
			// set up the colorTransform
			var colorTransform:ColorTransform = new ColorTransform(i, i, i, 1, r, g, b, 0);
			
			// copy bitmapdata with flipped matrix and colortransform
			var copy:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00FFFFFF);
			copy.draw(object, matrix, colorTransform);
			
			var sourceRect:Rectangle = new Rectangle(0, 0, bounds.width, mirrorHeight);
			var bottom:Point = new Point(bounds.x, bounds.bottom);
			
			// draw a portion into mirrorData with an alpha BitmapData
			var abd:BitmapData = createAlphaBitmapData(bounds.width, mirrorHeight, mirrorAlpha);
			mirrorData.copyPixels(copy, sourceRect, bottom, abd, null, true);
		}
		
		protected function createAlphaBitmapData(w:Number, h:Number, a:Number):BitmapData {
			
			if (USE_CACHE) {
				// if a gradient with equal width and height is already in cache, use that one 
				var bd:BitmapData = cache.getBitmapData(w, h);
				if (bd) return bd;
			}
			
			// rotate 90 degrees
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(w, h, 90 * (Math.PI/180));
			
			// draw alpha gradient (color doesn't matter)
			var shape:Shape = new Shape();
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0, 0], [a, 0], [0, 255], matrix);
			shape.graphics.drawRect(0, 0, w, h);
			shape.graphics.endFill();
			
			var abd:BitmapData = new BitmapData(w, h, true, 0x00FFFFFF);
			abd.draw(shape);
			
			// add to cache
			if (USE_CACHE) cache.addCache(w, h, abd);
			
			return abd;
		}
		
	}
}
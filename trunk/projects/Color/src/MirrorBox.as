package {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Box;
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
		public var mirrorBlurX			:Number = 0;
		public var mirrorBlurY			:Number = 0;
		
		protected var children			:Array;
		protected var mirror			:Bitmap;
		protected var mirrorData		:BitmapData;
		protected var blur				:BlurFilter;
		protected var lastWidth			:Number = 0;
		protected var lastHeight		:Number = 0;
		protected var colorTransform	:ColorTransform;
		
		protected var cache				:BitmapDataCache;
		public var cacheSize			:uint = 20;
		public var useCache				:Boolean = false; // FIX
		
		// ---- getters & setters ----
		
		// ---- constructor ----
		
		public function MirrorBox() {
			super();
			
			addEventListener(ChildExistenceChangedEvent.CHILD_ADD, childAddHandler);
			addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE, childRemoveHandler);
			addEventListener(IndexChangedEvent.CHILD_INDEX_CHANGE, childIndexChangeHandler);
			
			// when used as an itemrenderer listen for updateComplete event
			addEventListener(FlexEvent.UPDATE_COMPLETE, updateHandler);
			
			children = new Array();
			cache = new BitmapDataCache(cacheSize);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			mirror = new Bitmap();
			rawChildren.addChild(mirror);
			
			blur = new BlurFilter(mirrorBlurX, mirrorBlurY, 1);
			mirror.filters = [blur];
		}
		
		protected function childAddHandler(event:ChildExistenceChangedEvent):void {
			var child:DisplayObject = event.relatedObject;
			
			child.removeEventListener(Event.ADDED_TO_STAGE, childAddedToStage);
			child.addEventListener(Event.ADDED_TO_STAGE, childAddedToStage);
			
			if (child is UIComponent) {
				UIComponent(child).removeEventListener(FlexEvent.UPDATE_COMPLETE, childUpdateHandler);
				UIComponent(child).addEventListener(FlexEvent.UPDATE_COMPLETE, childUpdateHandler);
				
			} else {
				child.removeEventListener(Event.RENDER, childUpdateHandler);
				child.addEventListener(Event.RENDER, childUpdateHandler);
			}
			children.push(child);
		}
		
		protected function childRemoveHandler(event:ChildExistenceChangedEvent):void {
			var child:DisplayObject = event.relatedObject;
			
			if (child is UIComponent)
				UIComponent(child).removeEventListener(FlexEvent.UPDATE_COMPLETE, childUpdateHandler);
			
			child.removeEventListener(Event.RENDER, childUpdateHandler);
			
			var index:int = children.indexOf(child);
			if (index > -1) children.splice(index, 1);
			
			invalidateDisplayList();
		}
		
		protected function childIndexChangeHandler(event:IndexChangedEvent):void {
			// keep mirror at the bottom index
			rawChildren.setChildIndex(mirror, 0);
		}
		
		protected function childAddedToStage(event:Event):void {
			event.currentTarget.removeEventListener(Event.ADDED_TO_STAGE, childAddedToStage);
			
			invalidateDisplayList();
		}
		
		protected function childUpdateHandler(event:Event):void {
			// do it immediately, don't wait a frame or it will look choppy
			updateMirror();
			invalidateDisplayListFlag = false;
		}
		
		protected var timesUpdated:uint;
		
		// for when this component is used as an itemrenderer:
		// first update is when it is added to its parent container
		// second when children are added and it is measured, maybe..
		// third when the parent gets scrollbars
		protected function updateHandler(event:Event):void {
			timesUpdated++;
			if (timesUpdated >= 3) removeEventListener(FlexEvent.UPDATE_COMPLETE, updateHandler);
			updateMirror();
			invalidateDisplayListFlag = false;
		}
		
		// use our own flag, not UIComponent#mx_internal::invalidateDisplayListFlag
		protected var invalidateDisplayListFlag:Boolean;
		
		override public function validateDisplayList():void {
			super.validateDisplayList();
			invalidateDisplayListFlag = true;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (stage && invalidateDisplayListFlag) {
				updateMirror();
				invalidateDisplayListFlag = false;
			}
		}
		
		protected function updateMirror():void {
			// without a stage we can't calculate the bounds of children
			// and without children there's no use to continue
			if (!stage || numChildren == 0) return;
			
			// get bounds, resize mirror bitmap accordingly
			var bounds:Rectangle = measureMinMax(children, "width", "bottom");
			bounds.height += mirrorHeight;
			
			/*
			// create new bitmapdata only of the dimensions have changed
			if (bounds.width > lastWidth || bounds.height > lastHeight) {
				mirrorData = new BitmapData(bounds.width, bounds.height, true, 0x00FFFFFF);
				
				lastWidth = bounds.width;
				lastHeight = bounds.height;
				
			} else {
				// clear
				mirrorData.fillRect(new Rectangle(0, 0, mirrorData.width, mirrorData.height), 0x00FFFFFF);
			}
			*/
			
			mirrorData = new BitmapData(bounds.width, bounds.height, true, 0x00FFFFFF);
			
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
		
		protected function drawReflection(object:DisplayObject, offsetX:Number, offsetY:Number):void {
			
			var bounds:Rectangle = object.getBounds(object.parent);
			bounds.offset(offsetX + mirrorOffsetX, offsetY + mirrorOffsetY);
			
			// no need to draw invisible objects
			if (bounds.width == 0 || bounds.height == 0) return;
			
			// flip horizontally, then offset by bounds.height
			var matrix:Matrix = new Matrix();
			matrix.scale(1, -1);
			matrix.translate(0, bounds.height);
			
			colorTransform = (mirrorColorStrength > 0)  ? createColorTransform(mirrorColor, mirrorColorStrength) : null;
			
			// copy bitmapdata with flipped matrix and colortransform
			var copy:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00FFFFFF);
			copy.draw(object, matrix, colorTransform);
			
			var sourceRect:Rectangle = new Rectangle(0, 0, bounds.width, mirrorHeight);
			var bottom:Point = new Point(bounds.x, bounds.bottom);
			
			// draw a portion into mirrorData with an alpha BitmapData
			var abd:BitmapData = createAlphaBitmapData(bounds.width, mirrorHeight, mirrorAlpha);
			
			/**
			 * HERE'S THE ERROR: ADDING THE ALPHAMAP THROWS AN ERROR, sometimes.. ಠ_ಠ
			 * FIX: bounds/displayList problem?
			 * adb's getters sometime throw an exception, not correctly returned from cache?
			 * mirrorData.copyPixels(copy, sourceRect, bottom); works correctly 
			 */
			
			try {
				mirrorData.copyPixels(copy, sourceRect, bottom, abd);
				
			} catch (e:Error) {
				trace(e.message);
				trace("mirrorData dimensions:", mirrorData.width, mirrorData.height);
				trace("alphamap dimensions:", abd.width, abd.height);
			}
		}
		
		// create a colorTransform that tints to a color
		protected function createColorTransform(color:uint, strength:Number):ColorTransform {
			var s:Number = Math.max(0, Math.min(strength, 1));
			var i:Number = (1-s);
			
			// calculate color offsets
			var r:Number = Math.round(s * (color >> 16 & 0xFF));
			var g:Number = Math.round(s * (color >> 8 & 0xFF));
			var b:Number = Math.round(s * (color & 0xFF));
			
			return new ColorTransform(i, i, i, 1, r, g, b, 0);
		}
		
		protected function createAlphaBitmapData(w:Number, h:Number, a:Number):BitmapData {
			
			if (useCache) {
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
			if (useCache) cache.addCache(w, h, abd);
			
			return abd;
		}
		
		// ---- utils ----
		
		protected function measureMinMax(array:Array, horizontal:String, vertical:String):Rectangle {
			var bounds:Rectangle;
			
			var minX:Number = Infinity;
			var maxX:Number = 0;
			var minY:Number = Infinity;
			var maxY:Number = 0;
			
			var object:DisplayObject;
			for each (object in array) {
				
				bounds = object.getBounds(object.parent);
				
				switch (horizontal) {
					case "left": {
						minX = Math.min(bounds.left, minX);
						maxX = Math.max(bounds.left, maxX);
						break;
					}
					case "center": {
						minX = Math.min(bounds.left + bounds.width/2, minX);
						maxX = Math.max(bounds.left + bounds.width/2, maxX);
						break;
					}
					case "right": {
						minX = Math.min(bounds.right, minX);
						maxX = Math.max(bounds.right, maxX);
						break;
					}
					case "width": {
						minX = Math.min(bounds.left, minX);
						maxX = Math.max(bounds.right, maxX);
						break;
					}
					default: {
						break;
					}
				}
				
				switch (vertical) {
					case "top": {
						minY = Math.min(bounds.top, minY);
						maxY = Math.max(bounds.top, maxY);
						break;
					}
					case "middle": {
						minY = Math.min(bounds.top + bounds.height/2, minY);
						maxY = Math.max(bounds.top + bounds.height/2, maxY);
						break;
					}
					case "bottom": {
						minY = Math.min(bounds.bottom, minY);
						maxY = Math.max(bounds.bottom, maxY);
						break;
					}
					case "height": {
						minY = Math.min(bounds.top, minY);
						maxY = Math.max(bounds.bottom, maxY);
						break;
					}
					default: {
						break;
					}
				}
				
			}
			
			if (minX == Infinity) minX = 0;
			if (minY == Infinity) minY = 0;
			
			return new Rectangle(minX, minY, maxX - minX, maxY - minY);
		}
		
	}
}
package view.components {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import nl.mediamonkey.color.Gradient;
	import nl.mediamonkey.color.HSVColor;
	
	public class ColorPicker extends UIComponent {
		
		// ---- variables ----
		
		[Bindable] public var previousColor		:uint;
		[Bindable] public var selectedColor		:uint;
		
		protected var downPoint			:Point;
		protected var bitmap			:Bitmap;
		protected var colorData			:BitmapData;
		protected var shadowData		:BitmapData;
		
		protected var colorSprite		:Sprite;
		protected var shadowSprite		:Sprite;
		protected var borderSprite		:Sprite;
		
		protected var hsvColor			:HSVColor;
		protected var hueChangedFlag	:Boolean;
		
		// ---- getters & setters ----
		
		[Bindable]
		public function get hue():Number {
			return hsvColor.h;
		}
		
		public function set hue(value:Number):void {
			if (hsvColor.h != value) {
				hsvColor.h = value;
				
				hueChangedFlag = true;
				invalidateProperties();
				
				selectedColor = getColorAtDownPoint();
			}
		}
		
		public function set color(value:Number):void {
			if (hsvColor.colorValue != value) {
				hsvColor.colorValue = value;
				hsvColor.s = HSVColor.MAX_S;
				hsvColor.v = HSVColor.MAX_V;
				
				hueChangedFlag = true;
				invalidateProperties();
				
				selectedColor = getColorAtDownPoint();
			}
		}
		
		// ---- constructor ----
		
		public function ColorPicker() {
			super();
			
			hsvColor = HSVColor.fromDecimal(0xFF0000);
			downPoint = new Point();
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		override protected function createChildren():void {
			
			colorSprite = new Sprite();
			shadowSprite = new Sprite();
			
			bitmap = new Bitmap(colorData);
			addChild(bitmap);
			
			// border on top
			borderSprite = new Sprite();
			addChild(borderSprite);
		}
		
		protected function init(event:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			hueChangedFlag = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if (!stage) return;
				
			if (hueChangedFlag) {
				hueChangedFlag = false;
				
				// draw in sprites
				drawHue(unscaledWidth, unscaledHeight, hsvColor.colorValue);
				drawShadow(unscaledWidth, unscaledHeight);
				
				// fill bitmapData
				
				if (!colorData || colorData.width != unscaledWidth || colorData.height != unscaledHeight)
					colorData = new BitmapData(unscaledWidth, unscaledHeight, false, 0);
				
				if (!shadowData || shadowData.width != unscaledWidth || shadowData.height != unscaledHeight) {
					shadowData = new BitmapData(unscaledWidth, unscaledHeight, true, 0x00FFFFFF);
					shadowData.draw(shadowSprite);
				}
				
				colorData.draw(colorSprite);
				colorData.copyPixels(shadowData, new Rectangle(0, 0, shadowData.width, shadowData.height), new Point());
				bitmap.bitmapData = colorData;
				
				// draw border
				borderSprite.graphics.clear();
				borderSprite.graphics.lineStyle(1);
				borderSprite.graphics.drawRect(0, 0, unscaledWidth-1, unscaledHeight-1);
			}
		}
		
		protected function drawHue(w:uint, h:uint, color:uint):void {
			
			var gradient:Gradient = Gradient.createColorAlphaRange(0xFFFFFF, color);
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(w, h, 0 * (Math.PI/180), 0, 0);
			
			colorSprite.graphics.clear();
			colorSprite.graphics.beginGradientFill(
				GradientType.LINEAR,
				gradient.colors,
				gradient.alphas,
				gradient.ratios,
				matrix
			);
			
			colorSprite.graphics.drawRect(0, 0, w, h);
		}
		
		protected function drawShadow(w:uint, h:uint):void {
			
			var gradient:Gradient = Gradient.createColorAlphaRange(0x000000, 0x000000, 0, 1);
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(w, h, 90 * (Math.PI/180), 0, 0);
			
			shadowSprite.graphics.clear();
			shadowSprite.graphics.beginGradientFill(
				GradientType.LINEAR,
				gradient.colors,
				gradient.alphas,
				gradient.ratios,
				matrix
			);
			
			shadowSprite.graphics.drawRect(0, 0, w, h);
		}
		
		protected function getColorAtDownPoint():uint {
			return colorData.getPixel(downPoint.x, downPoint.y);
		}
		
		// ---- event handlers ----
		
		protected var mouseDown:Boolean;
		
		protected function mouseDownHandler(event:MouseEvent):void {
			mouseDown = true;
			downPoint.x = event.localX;
			downPoint.y = event.localY;
			
			previousColor = selectedColor;
			selectedColor = getColorAtDownPoint();
			
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		protected function mouseMoveHandler(event:MouseEvent):void {
			downPoint.x = event.localX;
			downPoint.y = event.localY;
			selectedColor = getColorAtDownPoint();
		}
		
		protected function mouseUpHandler(event:MouseEvent):void {
			mouseDown = false;
			downPoint.x = event.localX;
			downPoint.y = event.localY;
			selectedColor = getColorAtDownPoint();
			
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
	}
}
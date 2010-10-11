package nl.mediamonkey.graphics {
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class ButtonStateDrawUtil {
		
		public static const UP		:String = "up";
		public static const OVER	:String = "over";
		public static const DOWN	:String = "down";
		
		public static function drawButtonState(target:Sprite, buttonState:String = "up", focus:Boolean = false, selected:Boolean = false):void {
			target.graphics.clear();
			
			var obColor		:uint;
			var ibColor		:uint;
			var bgColors	:Array;
			
			var obAlpha		:Number = 1;
			var ibAlpha		:Number = 1;
			var bgAlphas	:Array = [1, 1];
			
			/**
			 * Todo: calculate color tints (and alpha) from a few themecolors
			 */
			
			switch (buttonState) {
				case UP: {
					obColor = (focus) ? 0x7DA2CE : (selected) ? 0x7DA2CE : 0xFFFFFF;
					obAlpha = (focus) ? 1 : 0;
					ibColor = (selected) ? 0xE0EEFD : 0xFFFFFF;
					ibAlpha = (selected) ? 1 : 0;
					bgColors = (selected) ? [0xC6DEFC, 0xC6DEFC] : [0xFFFFFF, 0xFFFFFF];
					bgAlphas = (selected) ? [1, 1] : [0, 0];
					break;
				}
				case OVER: {
					obColor = (focus) ? 0x7DA2CE : (selected) ? 0x7DA2CE : 0xB8D6FB;
					ibColor = (selected) ? 0xFFFFFF : 0xE0EEFD;
					bgColors = (selected) ? [0xC6DEFC, 0xC6DEFC] : [0xFAFBFD, 0xEBF3FD];
					break;
				}
				case DOWN: {
					obColor = (focus) ? 0x7DA2CE : (selected) ? 0x7DA2CE : 0x7DA2CE;
					ibColor = (selected) ? 0xE0EEFD : 0xE0EEFD;
					bgColors = (selected) ? [0xC6DEFC, 0xC6DEFC] : [0xC6DEFC, 0xC6DEFC];
					break;
				}
				default: return;
			}
			
			// outer border
			target.graphics.lineStyle(1, obColor, obAlpha, true);
			target.graphics.drawRoundRectComplex(0, 0, target.width, target.height, 4, 3, 3, 3);
			
			// inner border with background
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(target.width, target.height, Math.PI/2);
			target.graphics.lineStyle(1, ibColor, ibAlpha, true);
			target.graphics.beginGradientFill(GradientType.LINEAR, bgColors, bgAlphas, [0, 0xFF], matrix);
			target.graphics.drawRoundRectComplex(1, 1, target.width-2, target.height-2, 3, 2, 2, 2);
			target.graphics.endFill();
		}
		
	}
}
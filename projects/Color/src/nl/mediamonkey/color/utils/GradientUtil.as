package nl.mediamonkey.color.utils {
	
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import nl.mediamonkey.color.Gradient;
	
	public class GradientUtil {
		
		public static function createSquare(w:uint, h:uint, color:uint):Sprite {
			
			var gradient:Gradient = Gradient.createColorAlphaRange(0xFFFFFF, color);
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(w, h, 0 * (Math.PI/180), 0, 0);
			
			var colorShape:Shape = new Shape();
			colorShape.graphics.beginGradientFill(
				GradientType.LINEAR,
				gradient.colors,
				gradient.alphas,
				gradient.ratios,
				matrix
			);
			colorShape.graphics.drawRect(0, 0, w, h);
			
			gradient = Gradient.createColorAlphaRange(0x000000, 0x000000, 0, 1);
			matrix.createGradientBox(w, h, 90 * (Math.PI/180), 0, 0);
			
			var shadowShape:Shape = new Shape();
			shadowShape.graphics.beginGradientFill(
				GradientType.LINEAR,
				gradient.colors,
				gradient.alphas,
				gradient.ratios,
				matrix
			);
			shadowShape.graphics.drawRect(0, 0, w, h);
			
			var sprite:Sprite = new Sprite();
			sprite.addChild(colorShape);
			sprite.addChild(shadowShape);
			
			return sprite;
		}
		
		public static function createShape(w:uint, h:uint, colors:Array, alphas:Array, ratios:Array):Shape {
			var type:String = GradientType.LINEAR;
			var spreadMethod:String = SpreadMethod.PAD;
			var interp:String = InterpolationMethod.RGB;
			var focalPtRatio:Number = 0;
			
			var matrix:Matrix = new Matrix();
			var boxRotation:Number = 0 * (Math.PI/180); // degrees to radials
			var tx:Number = 0;
			var ty:Number = 0;
			matrix.createGradientBox(w, h, boxRotation, tx, ty);
			
			var square:Shape = new Shape;
			square.graphics.beginGradientFill(
				type,
				colors,
				alphas,
				ratios,
				matrix,
				spreadMethod,
				interp,
				focalPtRatio
			);
			square.graphics.drawRect(0, 0, w, h);
			
			return square;
		}
		
	}
}
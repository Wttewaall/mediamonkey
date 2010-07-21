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
		
		/**
		 * Returns a color array of given size that ranges from one
		 * given color to the other.
		 */
		/*public static function getInterpolatedPalette(size:int,color1:uint, color2:uint):Array{
			var colorMap:Array =[];
			for(var i:int=0; i<size; i++ ) {
				var t:Number = (i/(size-1));
				colorMap.push(interpolate(color1,color2,t));
			}
			return colorMap;
		}*/
		
		/**
		 * Returns a color palette that uses a "cool", blue-heavy color scheme.
		 */
		/*public static function getCoolPalette(size:int):Array{
			var colorMap:Array =[];
			for(var i:int=0; i<size; i++ ) {
				var r:Number = i / Math.max(size-1,1.0);
				colorMap.push(rgbaFloat(r,1-r,1.0,1.0));
			}
			return colorMap;
		}*/
		
		/**
		 * Returns a color palette that moves from black to red to yellow
		 * to white.
		 */
		/*public static function getHotPalette(size:int):Array {
			var colorMap:Array =[];
			for (var i:int=0; i<size; i++) {
				var n:int = (3*size)/8;
				var r:Number = ( i<n ? ((i+1))/n : 1.0 );
				var g:Number = ( i<n ? 0.0 : ( i<2*n ? ((i-n))/n : 1.0 ));
				var b:Number = ( i<2*n ? 0.0 : ((i-2*n))/(size-2*n) );
				
				colorMap.push(rgbaFloat(r,g,b,1.0));
				
			}
			return colorMap;
		}*/
		
		/**
		 * Returns a color palette of specified size that ranges from white to
		 * black through shades of gray.
		 */
		/*public static function getGreyScalePalette(size:int):Array {
			var colorMap:Array =[];
			for (var i:int=0; i<size; i++) {
				var g:int = Math.round(255*(0.2 + 0.6*i)/(size-1));
				colorMap.push(Math.abs(grey(g)));
			}
			return colorMap;
		}*/
		
		/**
		 * Returns a color palette of given size tries to provide colors
		 * appropriate as category labels. There are 12 basic color hues
		 * (red, orange, yellow, olive, green, cyan, blue, purple, magenta,
		 * and pink). If the size is greater than 12, these colors will be
		 * continually repeated, but with varying saturation levels.
		 * @param size the size of the color palette
		 * @param s1 the initial saturation to use
		 * @param s2 the final (most distant) saturation to use
		 * @param b the brightness value to use
		 * @param a the alpha value to use
		 */
		/*public static function getCategoryPalette(size:int,s1:Number, s2:Number, b:Number,a:int):Array{       
			var colorMap:Array = new Array();
			var s:Number = s1;
			var j:int;
			for (var i:int=0; i<size; i++ ){
				j = i % CATEGORY_HUES.length;
				if (j == 0)
					s = s1 + ((i)/size)*(s2-s1);    
				colorMap.push(PaletteUtils.hsba(CATEGORY_HUES[j]*360,s,b,a));
			}
			return colorMap;
		}*/
		
		/**
		 * Returns a color palette of given size that cycles through
		 * the hues of the HSB (Hue/Saturation/Brightness) color space.
		 * @param size the size of the color palette
		 * @param s the saturation value to use
		 * @param b the brightness value to use
		 * @return the color palette
		 */
		/*public static function getHSBPalette(size:int, s:Number, b:Number):Array{
			var colorMap:Array = new Array();
			var h:Number;
			for (var i:int=0; i<size; i++)
			{
				h = (i)/(size-1) * 360;
				colorMap.push( PaletteUtils.hsb(h,s,b) );
			}
			return colorMap;
		}*/
		
	}
}
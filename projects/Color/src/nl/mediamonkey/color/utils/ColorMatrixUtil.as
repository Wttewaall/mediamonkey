package nl.mediamonkey.color.utils {
	
	public class ColorMatrixUtil {
		
		// ---- 3x3 Convolution matrices ----
		
		public static const IDENTITY		:Array = [	 0,  0,  0,
													 	 0,  1,  0,
													 	 0,  0,  0	];
		
		public static const EMBOSS			:Array = [	-2, -1,  0,
														-1,  1,  1,
														 0,  1,  2	];
		
		public static const BLUR			:Array = [	 0,  1,  0,
														 1,  1,  1,
														 0,  1,  0	];
		
		public static const SHARPEN			:Array = [	 0, -1,  0
														-1,  5, -1
														 0, -1,  0	];
		
		public static const EDGE_DETECT		:Array = [	 0, -1,  0
														-1,  4, -1
														 0, -1,  0	];
		
		public static const EXTRUDE			:Array = [	-30, 30, 0
														-30, 30, 0
														-30, 30, 0	];
		
		// ---- 5x4 ColorFilter matrices ----
		
		public static function getBrightness(value:Number):Array {
				//  R  G  B  A  Offset
			return [1, 0, 0, 0, value,		/* red */
					0, 1, 0, 0, value,		/* green */
					0, 0, 1, 0, value,		/* blue */
					0, 0, 0, 1, 0];			/* alpha */
		}
		
		public static function getSaturation(value:Number):Array {
			var x:Number = 1 + ((value > 0) ? 3 * value/100 : value/100);
			var lumR:Number = 0.3086;
			var lumG:Number = 0.6094;
			var lumB:Number = 0.0820;
			
			var m:Array = [	1, 0, 0, 0, 0,
							0, 1, 0, 0, 0,
							0, 0, 1, 0, 0,
							0, 0, 0, 1, 0];
			
			return multiplyMatrices(m, [
				lumR*(1-x)+x,	lumG*(1-x),		lumB*(1-x),		0,	0,
				lumR*(1-x),		lumG*(1-x)+x,	lumB*(1-x),		0,	0,
				lumR*(1-x),		lumG*(1-x),		lumB*(1-x)+x,	0,	0,
				0,				0,				0,				1,	0,
				0,				0,				0,				0,	1
			]);
		}
		
		public static function getGrayscale():Array {
			var b:Number = 1 / 3;
			var c:Number = 1 - (b * 2);
				//  R  G  B  A  Offset
			return [c, b, b, 0, 0,		/* red */
					b, c, b, 0, 0,		/* green */
					b, b, c, 0, 0,		/* blue */
					0, 0, 0, 1, 0];		/* alpha */
		}
		
		public static function getAlpha(value:Number):Array {
				//  R  G  B  A  Offset
			return [1, 0, 0, 0, 0,			/* red */
					0, 1, 0, 0, 0,			/* green */
					0, 0, 1, 0, 0,			/* blue */
					0, 0, 0, value, 0];		/* alpha */
		}
		
		// ----
		
		// multiplies one matrix against another:
		public static function multiplyMatrices(matrix1:Array, matrix2:Array):Array {
			var result:Array = matrix1.concat();
			var col:Array = [];
			
			for (var i:int=0; i<5; i++) {
				
				for (var j:int=0; j<5; j++) {
					col[j] = matrix1[j+i*5];
				}
				
				for (j=0; j<5; j++) {
					var value:Number=0;
					
					for (var k:int=0; k<5; k++) {
						value += matrix2[j+k*5] * col[k];
					}
					
					result[j+i*5] = value;
				}
			}
			
			return result;
		}
		
	}
}
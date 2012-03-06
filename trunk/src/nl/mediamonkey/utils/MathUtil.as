package nl.mediamonkey.utils {
	
	public class MathUtil {
		
		public static function multiplyArray(mA:Array, mB:Array):void {
			var result:Array = new Array ();
			
			var mAHeight:uint = mA.length;
			var mAWidth:uint = mA[0].length;
			var mBWidth:uint = mB[0].length;
			
			var y:Number;
			var x:Number;
			var e:Number;
			
			for (y = 0; y < mAHeight; y++) {
				
				for (x = 0; x < mBWidth; x++) {
					result[x + mAHeight * y] = 0;
					
					for (e = 0; e < mAWidth; e++) {
						result[x + mAHeight * y] += mA[(y * mAWidth) + e] * mB[x + (e * mBWidth)];
					}
				}
			} 
		}
		
		/**
		 * Applies the given transformation matrix to the rectangle and returns
		 * a new bounding box to the transformed rectangle.
		 */
		public static function getBoundsAfterTransformation(bounds:Rectangle, m:Matrix):Rectangle {
			if (m == null) return bounds;
			
			var topLeft:Point = m.transformPoint(bounds.topLeft);
			var topRight:Point = m.transformPoint(new Point(bounds.right, bounds.top));
			var bottomRight:Point = m.transformPoint(bounds.bottomRight);
			var bottomLeft:Point = m.transformPoint(new Point(bounds.left, bounds.bottom));
			
			var left:Number = Math.min(topLeft.x, topRight.x, bottomRight.x, bottomLeft.x);
			var top:Number = Math.min(topLeft.y, topRight.y, bottomRight.y, bottomLeft.y);
			var right:Number = Math.max(topLeft.x, topRight.x, bottomRight.x, bottomLeft.x);
			var bottom:Number = Math.max(topLeft.y, topRight.y, bottomRight.y, bottomLeft.y);
			return new Rectangle(left, top, right - left, bottom - top);
		}
		
	}
}
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
		
	}
}
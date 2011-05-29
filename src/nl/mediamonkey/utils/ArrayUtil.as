package nl.mediamonkey.utils {
	
	public class ArrayUtil {
		
		public static function reverseElements(array:Array, numElements:uint=0):void {
			// copy a subset of elements and reverse in order
			var reversed:Array = array.slice(0, numElements).reverse();
			// assign elements in reversed order back to the original array
			for (var i:int=0; i<numElements; i++) array[i] = reversed[i];
		}
		
		public static function multiplyArrays(a1:Array, a2:Array):void {
			var result:Array = new Array ();
			
			var a1Height:uint = a1.length;
			var a1Width:uint = a1[0].length;
			var a2Width:uint = a2[0].length;
			
			var y:Number;
			var x:Number;
			var e:Number;
			
			for (y = 0; y < a1Height; y++) {
				
				for (x = 0; x < a2Width; x++) {
					result[x + a1Height * y] = 0;
					
					for (e = 0; e < a1Width; e++) {
						result[x + a1Height * y] += a1[(y * a1Width) + e] * a2[x + (e * a2Width)];
					}
				}
			} 
		}
		
	}
}
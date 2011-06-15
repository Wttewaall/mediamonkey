package nl.mediamonkey.utils.enum {
	
	public final class ResizeMode {
		
		public static const REDUCE		:uint = 1 << 0;
		public static const ENLARGE		:uint = 1 << 1;
		public static const EITHER		:uint = REDUCE | ENLARGE;
		
	}
}
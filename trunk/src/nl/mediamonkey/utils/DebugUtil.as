package nl.mediamonkey.utils {
	
	public class DebugUtil {
		
		public static var enabled:Boolean = true;
		
		public static function expect(value:Object, ...options):void {
			if (!enabled) return;
			
			if (options.indexOf(value) == -1) {
				throw new ArgumentError(value+" is an incorrect value, expected: ["+options.join("|")+"]");
			}
		}
		
		public static function assert(value:*, message:String=""):void {
			if (!enabled || value is Function || value is Class) return;
			
			var invalid:Boolean = false;
			
			// returns true if something goes wrong
			invalid ||= (value == undefined);
			invalid ||= (value is Object && value == null);
			invalid ||= (value is Number && isNaN(value));
			invalid ||= (value is Boolean && (value as Boolean) == false);
			invalid ||= (value is String && (value as String).length == 0);
			invalid ||= (value is Array && (value as Array).length == 0);
			
			if (invalid) throw new AssertionError(message);
		}
		
	}
}

class AssertionError extends Error {
	
	public function AssertionError(message:*="", id:*=0) {
		super(message, id);
		name = "AssertionError";
	}
}
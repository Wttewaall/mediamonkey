package nl.mediamonkey.utils {
	
	import flash.system.Capabilities;
	
	public class FlashPlayerUtil {
		
		public static function get inFlashIDE():Boolean {
			return Capabilities.playerType == "External";
		}
		
		public static function get inAIR():Boolean {
			return Capabilities.playerType == "Desktop";
		}
		
		public static function get inProjector():Boolean {
			return Capabilities.playerType == "StandAlone";
		}
		
		public static function get inBrowser():Boolean {
			return Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX";
		}
		
	}
	
}

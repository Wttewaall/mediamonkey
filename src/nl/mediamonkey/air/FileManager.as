package nl.mediamonkey.air {
	
	import flash.events.Event;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	import nl.mediamonkey.log.Logger;
	
	/* Usage:
	
	private function clickHandler(event:MouseEvent):void {
		var path:String = "myPDF.pdf";
		var fileName:String = path.substr(path.lastIndexOf("/")+1);
		var bytes:ByteArray = loadFile(path);
		if (bytes.length) saveBytesAs(bytes, fileName);
	}
	*/
	
	public class FileManager {
		
		private static const _instance:FileManager = new FileManager(SingletonLock);
		public static function get instance():FileManager { return _instance; }
		
		private var buffer:ByteArray;
		
		public function FileManager(lock:Class) {
			if (lock == SingletonLock) {
				init();
			} else {
				throw new Error("You cannot instantiate a singleton, use FileManager.instance");
			}
		}
		
		public function init():void {
			buffer = new ByteArray();
		}
		
		public static function loadFile(path:String):ByteArray {
			var file:File = File.applicationDirectory;
			file = file.resolvePath(path);
			Logger.info("loading file: "+file.name);
			
			if (file.exists) {
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				stream.readBytes(instance.buffer);
				stream.close();
			}
			
			return instance.buffer;
		}
		
		public static function saveBytesAs(bytes:ByteArray, path:String):void {
			var desktop:File = File.desktopDirectory;
			var file:File = desktop.resolvePath(path);
			
			try {
				file.browseForSave("Save As");
				file.addEventListener(Event.SELECT, instance.saveFileAsSelectedHandler);
				
			} catch (error:Error) {
				Logger.warn(error.message);
			}
		}
		
		public function saveFileAsSelectedHandler(event:Event):void {
			var stream:FileStream = new FileStream();
			stream.open(event.target as File, FileMode.WRITE);
			stream.writeBytes(buffer);
			stream.close();
			
			// clean buffer
			buffer = new ByteArray();
		}
		
	}
}

internal class SingletonLock {
}
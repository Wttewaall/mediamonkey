package nl.mediamonkey.events {
	
	import flash.events.Event;
	import flash.media.SoundTransform;
	
	public class SoundExtendedEvent extends Event {
		
		public static const TRANSFORM_CHANGE	:String = "transformChange";
		public static const LOAD_PROGRESS		:String = "loadProgress";
		public static const PLAY_PROGRESS		:String = "playProgress";
		
		public static const FADE_START			:String = "fadeStart";
		public static const FADE_COMPLETE		:String = "fadeComplete";
		
		public var soundTransform				:SoundTransform;
		public var bytesLoaded					:int;
		public var bytesTotal					:int;
		
		public function SoundExtendedEvent(type:String, soundTransform:SoundTransform=null, bytesLoaded:int=0, bytesTotal:int=0) {
			super(type);
			
			this.soundTransform = soundTransform;
			this.bytesLoaded = bytesLoaded;
			this.bytesTotal = bytesTotal;
		}
		
		override public function clone():Event {
			return new SoundExtendedEvent(type, soundTransform, bytesLoaded, bytesTotal);
		}
		
	}
	
}
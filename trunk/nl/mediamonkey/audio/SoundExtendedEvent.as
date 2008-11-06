package nl.mediamonkey.audio {
	
	import flash.events.Event;
	import flash.media.SoundTransform;
	
	public class SoundExtendedEvent extends Event {
		
		public static const SOUND_UPDATE	:String = "soundUpdate";
		public static const PLAY_PROGRESS	:String = "play_progress";
		
		public var soundTransform:SoundTransform;
		public var bytesLoaded:Number;
		public var bytesTotal:Number;
		
		public function SoundExtendedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,
										   soundTransform:SoundTransform=null, bytesLoaded:Number=0, bytesTotal:Number=0) {
			super(type, bubbles, cancelable);
			this.soundTransform = soundTransform;
			this.bytesLoaded = bytesLoaded;
			this.bytesTotal = bytesTotal;
		}
		
		override public function clone():Event {
			return new SoundExtendedEvent(type, bubbles, cancelable, soundTransform);
		}
		
	}
	
}
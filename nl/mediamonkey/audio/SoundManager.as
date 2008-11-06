/*
SoundManager dient als controller voor een of meerdere sounds, overal aan te roepen vanwege Singleton

To do:
	. crossfade inbouwen tussen 2 channels > fadeToChannel(channel, time)
*/

package nl.mediamonkey.audio {
	
	import flash.events.*;
	import flash.media.SoundMixer;
	import flash.utils.Dictionary;
	
	import mx.utils.NameUtil;

	public class SoundManager extends EventDispatcher {
		
		// singleton
		private static const _instance:SoundManager = new SoundManager(SingletonLock);
		public static function get instance():SoundManager { return _instance; }
		
		private var channels:Dictionary = new Dictionary(true);
		private var _sound:SoundExtended;// = new SoundExtended(null);
		private var _source:String;
		
		// ---- getters & setters ----
		
		public function get globalSound():SoundExtended {
			return _sound;
		}
		
		// ---- constructor & config ----
		
		public function SoundManager(lock:Class) {
			if (lock == SingletonLock) init();
			else throw new Error("SoundManager is a singleton, use SoundManager.instance");
		}
		
		public function init():void {
		}
		
		// ---- public methods ----
		
		public function createSoundChannel(soundUrl:String, autoLoad:Boolean = true, autoPlay:Boolean = true, streaming:Boolean = true, bufferTime:int = -1):SoundExtended {
			var sound:SoundExtended = new SoundExtended(soundUrl, autoLoad, autoPlay, streaming, bufferTime);
			sound.id = NameUtil.createUniqueName(sound);
			channels[sound.id] = sound;
			return sound;
		}
		
		public function removeSoundChannel(sound:SoundExtended):void {
			delete channels[sound.id];
		}
		
		public function createGlobalSoundChannel(soundUrl:String, autoLoad:Boolean = true, autoPlay:Boolean = true, streaming:Boolean = true, bufferTime:int = -1):SoundExtended {
			if (_sound) _sound.stop();
			_sound = new SoundExtended(soundUrl, autoLoad, autoPlay, false, bufferTime);
			_sound.id = NameUtil.createUniqueName(_sound);
			return _sound;
		}
		
		public function stopAll():void {
			SoundMixer.stopAll();
		}
		
		// ---- private methods ----
	    
	    private function getItemIndex(arr:Array, item:Object):int {
	    	for (var i:uint=0; i<arr.length; i++) {
	    		if (arr[i] === item) return i;
	    	}
	    	return -1;
	    }
	    
	    // ---- event handlers ----
	    
	}
}

internal class SingletonLock {
}
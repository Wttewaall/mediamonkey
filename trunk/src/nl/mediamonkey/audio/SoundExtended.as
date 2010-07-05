/*

To do:
	. echo simuleren door een dubbele sound af te spelen met delay en lager volume
		> is het mogelijk om meerdere sounds te mergen tot 1 spoor en die te laten echoën? scheelt enorm!
	. reverb != echo
	. alle properties, methods en events van de Sound class toevoegen
	. length, position in nette format (gebruik TimeFormatter)
	. test op hergebruik en op destructie van het object (doorspelen terwijl hij niet meer hort te bestaan e.d.)
*/

package nl.mediamonkey.audio {
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import nl.mediamonkey.audio.events.SoundExtendedEvent;

	/**
	 * This class was originally Adobe's podcastplayer example.
	 * It provides a simpler interface to the sound-related classes in the 
	 * flash.media package. Dispatches "playProgress" ProgressEvents and adds 
	 * pause and resume functionality.
	 */
	 
	[Event(name="complete",			type="flash.events.Event")]
	[Event(name="id3",				type="flash.events.Event")]
	[Event(name="ioError",			type="flash.events.IOErrorEvent")]
	[Event(name="open",				type="flash.events.Event")]
	[Event(name="playProgress",		type="nl.mediamonkey.audio.SoundExtendedEvent")]
	[Event(name="progress",			type="flash.events.ProgressEvent")]
	[Event(name="securityError",	type="flash.events.SecurityErrorEvent")]
	[Event(name="soundUpdate",		type="nl.mediamonkey.audio.SoundExtendedEvent")]
	
	[Bindable]
	public class SoundExtended extends EventDispatcher {
		
		public static const FORWARD				:String = "forward";
		public static const BACKWARDS			:String = "backwards";
		
		public static var PROGRESS_INTERVAL		:uint = 32; // in milliseconds
		public static var DELAY_INTERVAL		:uint = 10; // in milliseconds
		
		public var id							:String;
		public var autoLoad						:Boolean = true;
		public var autoPlay						:Boolean = true;
		public var bufferTime					:int = -1;
		
		protected var sound						:Sound;
		protected var channel					:SoundChannel;
		protected var transform					:SoundTransform;
		protected var progressTimer				:Timer;
		protected var fadeTimer					:Timer;
		protected var playTimer					:Timer;
		protected var playDirection				:String;
		protected var playSpeed					:Number;
		protected var pausePosition				:uint;
		protected var loopCount					:uint;
		protected var fadeFrom					:Number;
		protected var fadeTo					:Number;
		protected var fadeDuration				:Number;
		protected var fadeAutoStop				:Boolean;
		
		// ---- getters & setters ----
		
		private var _url						:String;
		private var _source						:*;
		private var _loop						:int = 0;
		private var _volume						:Number = 1;
		private var _pan						:Number;
		private var _mute						:Boolean = false;
		private var _delay						:Number = 0;
		private var _leftToLeft					:Number;
		private var _leftToRight				:Number;
		private var _rightToLeft				:Number;
		private var _rightToRight				:Number;
		
		/* private var echoes					:Array = new Array();
		private var _echo						:Boolean = false;
		private var _echoAmount					:int = 0;
		private var _echoDelay					:Number = 50;
		private var _echoDecay					:Number = 0.5; */
		
		// get only
		private var _length						:Number = 0;
		private var _isEmbedded					:Boolean = false;
		private var _isLoaded					:Boolean = false;
		private var _isReadyToPlay				:Boolean = false;
		private var _isPlaying					:Boolean = false;
		private var _isStreaming				:Boolean = false;
		/* private var _isEcho					:Boolean = false; */
		
		public function get url():String {
			return _url;
		}
		
		public function set url(value:String):void {
			if (_url != value) {
				_url = value;
			}
		}
		
		public function get source():* {
			return _source;
		}
		
		public function set source(value:*):void {
			if (_source != value) {
				setSource(value);
			}
		}
		
		public function get position():Number {
			return (channel != null) ? channel.position : 0;
		}
		
		public function set position(value:Number):void {
			seek(value);
		}
		
		public function get loop():int {
			return _loop;
		}
		
		/**
		 * -1 = infinitely, 0 = no loop, 1+ = loop
		 */
		public function set loop(value:int):void {
			_loop = value;
		}
		
		public function get volume():Number {
			return _volume;
		}
		
		public function set volume(value:Number):void {
			_volume = value;
			updateSoundTransform();
		}
		
		public function get pan():Number {
			if (isNaN(_pan)) return 0;
			return _pan;
		}
		
		public function set pan(value:Number):void {
			_pan = value;
			updateSoundTransform();
		}
		
		public function get mute():Boolean {
			return _mute;
		}
		
		public function set mute(value:Boolean):void {
			_mute = value;
			updateSoundTransform();
			
		}
		
		public function get delay():Number {
			return _delay;
		}
		
		public function set delay(value:Number):void {
			if (_delay != value) {
				_delay = value;
				/* updateEchoes(); */
			}
		}
		
		public function get leftToLeft():Number {
			return (!isNaN(_leftToLeft)) ? _leftToLeft : 1;
		}
		
		public function set leftToLeft(value:Number):void {
			_leftToLeft = value;
			updateSoundTransform();
		}
		
		public function get leftToRight():Number {
			return (!isNaN(_leftToRight)) ? _leftToRight : 0;
		}
		
		public function set leftToRight(value:Number):void {
			_leftToRight = value;
			updateSoundTransform();
		}
		
		public function get rightToLeft():Number {
			return (!isNaN(_rightToLeft)) ? _rightToLeft : 0;
		}
		
		public function set rightToLeft(value:Number):void {
			_rightToLeft = value;
			updateSoundTransform();
		}
		
		public function get rightToRight():Number {
			return (!isNaN(_rightToRight)) ? _rightToRight : 1;
		}
		
		public function set rightToRight(value:Number):void {
			_rightToRight = value;
			updateSoundTransform();
		}
		
		/* public function get echo():Boolean {
			return _echo;
		}
		
		public function set echo(value:Boolean):void {
			if (_echo != value) {
				_echo = value;
				
				if (value) {
					buildEchoes(echoAmount);
					updateEchoes();
				}
			}
		}
		
		public function get echoAmount():int {
			return _echoAmount;
		}
		
		public function set echoAmount(value:int):void {
			if (_echoAmount != value) {
				_echoAmount = value;
				
				if (echo) {
					buildEchoes(value);
					updateEchoes();
				}
			}
		}
		
		public function get echoDelay():Number {
			return _echoDelay;
		}
		
		public function set echoDelay(value:Number):void {
			if (_echoDelay != value) {
				_echoDelay = value;
				updateEchoes()
			}
		}
		
		public function get echoDecay():Number {
			return _echoDecay;
		}
		
		public function set echoDecay(value:Number):void {
			if (_echoDecay != value) {
				_echoDecay = value;
				updateEchoes()
			}
		} */
		
		// ---- getters only ----
		
		public function get fileName():String {
			if (!url)  return null;
			
			var forwardSlash:int = url.lastIndexOf("/");
			var backSlash:int = url.lastIndexOf("\\");
			var index:int = (forwardSlash != -1) ? forwardSlash : backSlash; // index can be -1
			return url.substr(index+1);
		}
		
		public function get hasValidURL():Boolean {
			return (url != null && url != "");
		}
		
		public function get length():Number {
			return _length;
		}
		
		public function get isEmbedded():Boolean {
			return _isEmbedded;
		}
		
		public function get isLoaded():Boolean {
			return _isLoaded;
		}
		
		public function get isReadyToPlay():Boolean {
			return _isReadyToPlay;
		}
		
		public function get isPlaying():Boolean {
			return _isPlaying;
		}
		
		public function get isStreaming():Boolean {
			return _isStreaming;
		}
		
		/* public function get isEcho():Boolean {
			return _isEcho;
		} */
		
		public function get isPaused():Boolean {
			return (pausePosition > 0)
		}
		
		public function get id3():ID3Info {
			return (sound) ? sound.id3 : null;
		}
		
		public function get leftPeak():Number {
			return (channel) ? channel.leftPeak : 0;
		}
		
		public function get rightPeak():Number {
			return (channel) ? channel.rightPeak : 0;
		}
		
		// ---- constructor ----
		
		public function SoundExtended(source:*=null, autoLoad:Boolean=true, autoPlay:Boolean=false, streaming:Boolean=false, bufferTime:int=-1, isEcho:Boolean=false) {
			// sets boolean values that determine the behavior of this object
			this.autoLoad = autoLoad;
			this.autoPlay = autoPlay;
			this._isStreaming = streaming;
			/* this._isEcho = isEcho; */
			
			// defaults to the global bufferTime value
			if (bufferTime < 0) this.bufferTime = SoundMixer.bufferTime;
			
			// keeps buffer time reasonable, between 0 and 30 seconds
			this.bufferTime = Math.min(Math.max(0, bufferTime), 30);
			
			progressTimer = new Timer(PROGRESS_INTERVAL);
			progressTimer.addEventListener(TimerEvent.TIMER, progressTimerHandler);
			
			playTimer = new Timer(DELAY_INTERVAL);
			playTimer.addEventListener(TimerEvent.TIMER, playTimerHandler);
			
			fadeTimer = new Timer(10);
			fadeTimer.addEventListener(TimerEvent.TIMER, fadeTimerHandler);
			
			if (source) setSource(source);
		}
		
		// ---- public methods ----
				
		public function load():void {
			
			if (isPlaying) {
				stop();
				if (isStreaming) close();
				pausePosition = 0;
			}
			
			// unload before loading
			if (sound) unload();
			
			if (isEmbedded) {
				
				sound = new this.source() as Sound;
				
				dispatchEvent(new Event(Event.OPEN));
				dispatchEvent(new Event(Event.COMPLETE));
				dispatchEvent(new Event(Event.ID3));
				
			} else {
				
				sound = new Sound();
				
				sound.addEventListener(ProgressEvent.PROGRESS, soundProgressHandler, false, 0, true);
				sound.addEventListener(Event.OPEN, soundOpenHandler, false, 0, true);
				sound.addEventListener(Event.COMPLETE, soundCompleteHandler, false, 0, true);
				sound.addEventListener(Event.ID3, soundID3Handler, false, 0, true);
				sound.addEventListener(IOErrorEvent.IO_ERROR, soundIOErrorHandler, false, 0, true);
				sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, soundSecurityErrorHandler, false, 0, true);
				
				var request:URLRequest = new URLRequest(url);
				var context:SoundLoaderContext = new SoundLoaderContext(bufferTime, true);
				sound.load(request, context);
			}
		}
		
		public function play(pos:int=0, loop:int=0):void {
			if (!isPlaying) {
				this.loop = loop;
				
				if (isReadyToPlay /* || isEcho */) {
					//trace((isEcho ? "echo" : "master")+".echoDecay = "+echoDecay);
					if (delay > 0) setTimeout(doPlay, delay, pos);
					else doPlay(pos);
					
				} else if (isStreaming && !isLoaded) {
					// start loading again and play when ready
					// it appears to resume loading from the spot where it left off...cool
					load();
				}
				
				// update echoes regardless of any changes
				/* updateEchoes(); */
			}
		}
		
		protected function doPlay(pos:int=0):void {
			//trace((isEcho ? "echo" : "master")+".doPlay()");
			if (!sound) return;
			
			if (channel)
				channel.removeEventListener(Event.SOUND_COMPLETE, channelCompleteHandler);
			
			channel = sound.play(pos);
			channel.addEventListener(Event.SOUND_COMPLETE, channelCompleteHandler, false, 0, true);
			
			// set transform properties on sound
			updateSoundTransform();
			
			_isPlaying = true;
			loopCount++;
			
			progressTimer.start();
		}
		
		public function seek(pos:int = 0):void {
			stop(pos);
			play(pos);
		}
		
		public function stop(pos:int = 0):void {
			if (pos == 0) {
				playTimer.reset();
				loopCount = 0;
			}
			
			if (isPlaying) {
				pausePosition = pos;
				channel.stop();
				progressTimer.stop();
				
				if (fadeTimer.running) {
					fadeTimer.stop();
					volume = fadeFrom;
				}
				 
				_isPlaying = false;
			}
			
			if (isStreaming && !isLoaded) {
				// stop streaming
				close();
				_isReadyToPlay = false;
			}
			
			/* updateEchoes(); */
		}
		
		public function pause():void {
			//trace("pause at "+position);
			stop(position);
		}
		
		public function resume():void {
			play(pausePosition);
			pausePosition = 0;
		}
		
		public function forward(speed:Number=1):void {
			playDirection = FORWARD;
			playSpeed = Math.max(1, speed);
			
			if (speed == 1) {
				playTimer.reset();
				doPlay(position);
				
			} else playTimer.start();
		}
		
		public function backwards(speed:Number=1):void {
			playDirection = BACKWARDS;
			playSpeed = Math.max(1, speed);
			
			if (speed == 1) playTimer.reset();
			else playTimer.start();
		}
		
		public function unload():void {
			stop();
			
			if (sound) {
				sound.removeEventListener(ProgressEvent.PROGRESS, soundProgressHandler);
				sound.removeEventListener(Event.OPEN, soundOpenHandler);
				sound.removeEventListener(Event.COMPLETE, soundCompleteHandler);
				sound.removeEventListener(Event.ID3, soundID3Handler);
				sound.removeEventListener(IOErrorEvent.IO_ERROR, soundIOErrorHandler);
				sound.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, soundSecurityErrorHandler);
			}
			
			if (channel) {
				channel.removeEventListener(Event.SOUND_COMPLETE, channelCompleteHandler);
			}
			
			sound = null;
			channel = null;
			transform = null;
		}
		
		public function destruct():void {
			progressTimer.reset();
			progressTimer.removeEventListener(TimerEvent.TIMER, progressTimerHandler);
			progressTimer = null;
			
			playTimer.reset();
			playTimer.removeEventListener(TimerEvent.TIMER, playTimerHandler);
			playTimer = null;
			
			fadeTimer.reset();
			fadeTimer.removeEventListener(TimerEvent.TIMER, fadeTimerHandler);
			fadeTimer = null;
			
			unload();
		}
		
		public function fadeIn(duration:Number=2000, autoPlay:Boolean=true):void {
			fadeFrom = 0;
			fadeTo = 1;
			fadeDuration = duration;
			
			fadeTimer.start();
			fadeTimerHandler(null); // start manually
			
			if (autoPlay && !isPlaying) play();
		}
		
		public function fadeOut(duration:Number=2000, autoStop:Boolean=true):void {
			fadeFrom = volume;
			fadeTo = 0;
			fadeDuration = duration;
			fadeAutoStop = autoStop;
			fadeTimer.start();
		}
		
		public function crossfade(sound:SoundExtended, duration:Number=2000, autoStop:Boolean=true):void {
			sound.fadeIn(duration);
			fadeOut(duration, autoStop);
		}
		
		override public function toString():String {
			return "[SoundExtended {id:"+id+", file:"+fileName+"}]";
		}
		
		// ---- protected methods ----
		
		protected function setSource(value:*):void {
			if (value == null) unload();
			
			// use an embedded sound as source
			if (value is Class) {
				_isEmbedded = true;
				_isStreaming = false;
				_isLoaded = true;
				_isReadyToPlay = true;
				
				_source = value as Class;
				if (autoLoad) load();
				
			} else if (value is String && url != value) {
				_isEmbedded = false;
				_isLoaded = false;
				_isReadyToPlay = false;
				
				_source = url = value;
				if (autoLoad && hasValidURL) load();
				
			} else {
				_isEmbedded = false;
				_isStreaming = false;
				_isLoaded = false;
				_isReadyToPlay = false;
			}
		}
		
		protected function updateSoundTransform():void {
			transform = new SoundTransform();
			
			if (_leftToLeft) transform.leftToLeft = leftToLeft;
			if (_leftToRight) transform.leftToRight = leftToRight;
			if (_rightToLeft) transform.rightToLeft = rightToLeft;
			if (_rightToRight) transform.rightToRight = rightToRight;
			
			if (_pan) transform.pan = pan; // pan comes AFTER ltl,ltr,rtl,rtr
			
			transform.volume = (mute) ? 0 : volume;
			
			if (sound && channel)  {
				channel.soundTransform = transform;
				dispatchEvent(new SoundExtendedEvent(SoundExtendedEvent.TRANSFORM_CHANGE, transform));
			}
		}
		
		protected function close():void {
			if (!sound) return;
			
			try {
				sound.close();
				
			} catch (e:IOError) {
				// Ignore these
			}
		}
		
		/* protected function buildEchoes(value:int):void {
			if (value == echoes.length) return;
			
			var i:uint;
			var echo:SoundExtended;
			var diff:int = value - echoes.length;
			
			if (diff > 0) {
				for (i=0; i<diff; i++) {
					// no autoLoad, already in cache or being loaded
					// no autoPlay, we take care of that manually
					echo = new SoundExtended(url, true, false, isStreaming, bufferTime, true);
					echoes.push(echo);
				}
			} else {
				for (i=diff; i>0; i--) {
					echo = echoes.pop() as SoundExtended;
					if (echo.isPlaying) echo.stop();
					echo = null;
				}
			}
		}
		
		// put this method only in start, stop and the echo properties
		protected function updateEchoes():void {
			if (echoDecay > 1) trace("BUG: echoDecay = "+echoDecay, isEcho);
			
			for (var i:uint=0; i<echoes.length; i++) {
				var echo:SoundExtended = echoes[i] as SoundExtended;
				echoDecay = 0.5; // bug
				echo.volume = volume * Math.pow(echoDecay, (i+1));
				echo.delay = echoDelay * (i+1);
				
				if (isPlaying) {
					if (position > echo.delay) {
						echo.seek(position - echo.delay);
						//trace(i+" echo.seek()");
					} else {
						echo.play();
						//trace(i+" echo.play()");
					}
					
				} else {
					echo.stop();
					//trace(i+" echo.stop()");
				}
			}
		} */
		
		// ---- event handlers ----
		
		protected function soundOpenHandler(event:Event):void {
			if (isStreaming) {
				_isReadyToPlay = true;
				if (autoPlay) play();
			}
			dispatchEvent(event.clone());
		}
		
		protected function soundProgressHandler(event:ProgressEvent):void {
			dispatchEvent(event.clone());
		}
		
		
		protected function soundCompleteHandler(event:Event):void {
			_isReadyToPlay = true;
			_isLoaded = true;
			dispatchEvent(event.clone());
			
			// if the sound hasn't started playing yet, start it now
			if (autoPlay && !isPlaying) play();
		}
		
		protected function channelCompleteHandler(event:Event):void {
			pausePosition = 0;
			progressTimer.stop();
			_isPlaying = false;
			
			if (loop == -1 || loop >= loopCount) {
				doPlay();
			}
			
			dispatchEvent(event.clone());
		}
		
		protected function soundID3Handler(event:Event):void {
			try {
				var id3:ID3Info = event.target.id3;
				
				for (var propName:String in id3) {
					//trace(propName + " = " + id3[propName]);
				}
				
			} catch (err:SecurityError) {
				//trace("Could not retrieve ID3 data.");
			}
			dispatchEvent(event.clone());
		}
	
		protected function soundIOErrorHandler(event:IOErrorEvent):void {
			//trace("** IOERROR **", event.text);
			dispatchEvent(event.clone());
		}
		
		protected function soundSecurityErrorHandler(event:SecurityErrorEvent):void {
			//trace("** SECURITY ERROR **", event.text);
			dispatchEvent(event.clone());
		}
		
		// TODO fix: length (in ms) / loaded ratio? wtf?
		protected function progressTimerHandler(event:TimerEvent):void {
			_length = Math.ceil(sound.length / (sound.bytesLoaded / sound.bytesTotal));
			
			dispatchEvent(new SoundExtendedEvent(SoundExtendedEvent.PLAY_PROGRESS, transform, position, length));
			
			if (position >= length) {
				progressTimer.stop();
				//trace("progress playback is complete");
			} else {
				//trace("busy");
			}
		}
		
		protected function fadeTimerHandler(event:TimerEvent=null):void {
			var timer:Timer = event.target as Timer;
			var time:uint = timer.currentCount * timer.delay;
			
			if (timer.currentCount == 0) dispatchEvent(new SoundExtendedEvent(SoundExtendedEvent.FADE_START));
			
			volume = easeNone(time, fadeFrom, fadeTo-fadeFrom, fadeDuration);
			
			if (volume == fadeTo) {
				timer.reset();
				dispatchEvent(new SoundExtendedEvent(SoundExtendedEvent.FADE_COMPLETE));
				if (fadeAutoStop && volume == 0) stop();
			}
		}
		
		protected function playTimerHandler(event:TimerEvent):void {
			var speed:Number = event.target.delay * playSpeed;
			
			if (playDirection == FORWARD) {
				seek(position + speed);
				
			} else if (playDirection == BACKWARDS) {
				seek(position - speed);
			}
		}
		
		// ---- protected methods ----
		
		protected function easeNone(time:Number, beginValue:Number, change:Number, duration:Number):Number {
			return change * time/duration + beginValue;
		}
		
	}
}
/*

To do:
	. echo simuleren door een dubbele sound af te spelen met delay en lager volume
		> is het mogelijk om meerdere sounds te mergen tot 1 spoor en die te laten echoën? scheelt enorm!
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

	/**
	 * This class was originally Adobe's podcastplayer example.
	 * It provides a simpler interface to the sound-related classes in the 
	 * flash.media package. Dispatches "playProgress" ProgressEvents and adds 
	 * pause and resume functionality.
	 */
	
	[Bindable]
	public class SoundExtended extends EventDispatcher {
		
		public static const FORWARD:String = "forward";
		public static const BACKWARDS:String = "backwards";
		
		public var id:String;
		public var autoLoad:Boolean = true;
		public var autoPlay:Boolean = true;
		public var bufferTime:int = -1;
		
		private var pausePosition:int = 0;
		private var progressInterval:int = 32;
		private var loopCount:int = 0;
		
		private var sound:Sound;
		private var soundChannel:SoundChannel;
		private var soundTransform:SoundTransform;
		private var progressTimer:Timer;
		private var playTimer:Timer;
		private var playDirection:String;
		private var playSpeed:Number;
		
		// get & set
		private var _url:String;
		private var _source:*;
		private var _loop:int = 0;
		private var _volume:Number = 1;
		private var _pan:Number = 0;
		private var _mute:Boolean = false;
		private var _delay:Number = 0;
		private var _leftToLeft:Number = 1;
		private var _leftToRight:Number = 0;
		private var _rightToLeft:Number = 0;
		private var _rightToRight:Number = 1;
		
		private var echoes:Array = new Array();
		private var _echo:Boolean = false;
		private var _echoAmount:int = 0;
		private var _echoDelay:Number = 50;
		private var _echoDecay:Number = 0.5;
		
		// get only
		private var _length:Number = 0;
		private var _isEmbedded:Boolean = false;
		private var _isLoaded:Boolean = false;
		private var _isReadyToPlay:Boolean = false;
		private var _isPlaying:Boolean = false;
		private var _isStreaming:Boolean = true;
		private var _isEcho:Boolean = false;
		
		// ---- getters & setters ----
		
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
			setSource(value);
			if (url != null && url != "" && autoLoad) load();
		}
		
		public function get fileName():String {
			if (url) {
				var forwardSlash:int = url.lastIndexOf("/");
				var backSlash:int = url.lastIndexOf("\\");
				var index:int = (forwardSlash != -1) ? forwardSlash : backSlash;
				
				return url.substr(index+1);
				
			} else {
				return "";
			}
		}
		
		public function set fileName(value:String):void {
			url = value;
		}
		
		public function get position():Number {
			return (soundChannel != null) ? soundChannel.position : 0;
		}
		
		public function set position(value:Number):void {
			seek(value);
		}
		
		public function get loop():int {
			return _loop;
		}
		
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
				updateEchoes();
			}
		}
		
		public function get leftToLeft():Number {
			return _leftToLeft;
		}
		
		public function set leftToLeft(value:Number):void {
			_leftToLeft = value;
			updateSoundTransform();
		}
		
		public function get leftToRight():Number {
			return _leftToRight;
		}
		
		public function set leftToRight(value:Number):void {
			_leftToRight = value;
			updateSoundTransform();
		}
		
		public function get rightToLeft():Number {
			return _rightToLeft;
		}
		
		public function set rightToLeft(value:Number):void {
			_rightToLeft = value;
			updateSoundTransform();
		}
		
		public function get rightToRight():Number {
			return _rightToRight;
		}
		
		public function set rightToRight(value:Number):void {
			_rightToRight = value;
			updateSoundTransform();
		}
		
		public function get echo():Boolean {
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
		
		private function buildEchoes(value:int):void {
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
		private function updateEchoes():void {
			if (echoDecay > 1) trace("BUG: echoDecay = "+echoDecay, isEcho);
			
			for (var i:uint=0; i<echoes.length; i++) {
				var echo:SoundExtended = echoes[i] as SoundExtended;
				echoDecay = 0.5; // bug
				echo.volume = volume * Math.pow(echoDecay, (i+1));
				echo.delay = echoDelay * (i+1);
				
				if (isPlaying) {
					if (position > echo.delay) {
						echo.seek(position - echo.delay);
						trace(i+" echo.seek()");
					} else {
						echo.play();
						trace(i+" echo.play()");
					}
					
				} else {
					echo.stop();
					trace(i+" echo.stop()");
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
		}
		
		// ---- getters only ----
		
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
		
		public function get isEcho():Boolean {
			return _isEcho;
		}
		
		public function get isPaused():Boolean {
			return (pausePosition > 0)
		}
		
		public function get id3():ID3Info {
			return sound.id3;
		}
		
		public function get leftPeak():Number {
			return soundChannel.leftPeak;
		}
		
		public function get rightPeak():Number {
			return soundChannel.rightPeak;
		}
		
		// ---- constructor ----
		
		public function SoundExtended(source:*=null, autoLoad:Boolean=true, autoPlay:Boolean=true, streaming:Boolean=true, bufferTime:int=-1, isEcho:Boolean=false) {
			
			setSource(source);
			
			// sets boolean values that determine the behavior of this object
			this.autoLoad = autoLoad;
			this.autoPlay = autoPlay;
			this._isStreaming = streaming;
			this._isEcho = isEcho;
			
			// defaults to the global bufferTime value
			if (bufferTime < 0) this.bufferTime = SoundMixer.bufferTime;
			
			// keeps buffer time reasonable, between 0 and 30 seconds
			this.bufferTime = Math.min(Math.max(0, bufferTime), 30);
			
			progressTimer = new Timer(progressInterval);
			progressTimer.addEventListener(TimerEvent.TIMER, progressTimerHandler);
			
			playTimer = new Timer(100);
			playTimer.addEventListener(TimerEvent.TIMER, playTimerHandler);
			
			if (url != null && url != "" && autoLoad) load();
		}
		
		// ---- public methods ----
				
		public function load():void {
			
			if (isPlaying) {
				stop();
				close();
				pausePosition = 0;
			}
			
			if (isEmbedded) {
				_isLoaded = true;
				
				sound = new source();
				dispatchEvent(new Event(Event.OPEN));
				dispatchEvent(new Event(Event.COMPLETE));
				dispatchEvent(new Event(Event.ID3));
				
			} else {
				_isLoaded = false;
				
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
		
		private function embeddedEventHandler(event:*):void {
			trace("** "+event.type);
		}
		
		public function play(pos:int=0, loop:int=0):void {
			if (!isPlaying) {
				this.loop = loop;
				
				if (isReadyToPlay || isEcho) {
					//trace((isEcho ? "echo" : "master")+".echoDecay = "+echoDecay);
					if (delay > 0) setTimeout(doPlay, delay, pos);
					else doPlay(pos);
					
				} else if (isStreaming && !isLoaded) {
					// start loading again and play when ready
					// it appears to resume loading from the spot where it left off...cool
					load();
				}
				
				// update echoes regardless of any changes
				updateEchoes();
			}
		}
		
		private function doPlay(pos:int=0):void {
			//trace((isEcho ? "echo" : "master")+".doPlay()");
			if (!sound) {
				trace("sound = null");
				return;
			}
			
			soundChannel = sound.play(pos);
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, channelPlayCompleteHandler);
			soundChannel.addEventListener(Event.SOUND_COMPLETE, channelPlayCompleteHandler, false, 0, true);
			
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
				soundChannel.stop();
				progressTimer.stop();
				_isPlaying = false;
			}
			
			if (isStreaming && !isLoaded) {
				// stop streaming
				close();
				_isReadyToPlay = false;
			}
			
			updateEchoes();
		}
		
		public function pause():void {
			trace("pause at "+position);
			stop(position);
		}
		
		public function resume():void {
			play(pausePosition);
			pausePosition = 0;
		}
		
		public function forward(speed:Number=1):void {
			playDirection = FORWARD;
			playSpeed = Math.max(1, speed);
			
			if (speed == 1) playTimer.reset();
			else playTimer.start();
		}
		
		public function backwards(speed:Number=1):void {
			playDirection = BACKWARDS;
			playSpeed = Math.max(1, speed);
			
			if (speed == 1) playTimer.reset();
			else playTimer.start();
		}
		
		override public function toString():String {
			return "[SoundExtended {file:"+fileName+"}]";
		}
		
		// ---- private methods ----
		
		private function setSource(value:*):void {
			
			// use an embedded sound as source
			if (value is Class) {
				_source = value;
				_url = value.toString();
				_isEmbedded = true;
				_isStreaming = false;
				_isLoaded = true;
				_isReadyToPlay = true;
			}
			
			// use an url as source
			if (value is String && url != value) {
				_source = url = value;
				_isEmbedded = false;
			}
		}
		
		private function close():void {
			try {
				sound.close();
				
			} catch (e:IOError) {
				// Ignore these
			}
		}
		
		private function updateSoundTransform():void {
			soundTransform = new SoundTransform();
			soundTransform.leftToLeft = leftToLeft;
			soundTransform.leftToRight = leftToRight;
			soundTransform.pan = pan;
			soundTransform.rightToLeft = rightToLeft;
			soundTransform.rightToRight = rightToRight;
			soundTransform.volume = (mute) ? 0 : volume;
			
			if (sound && soundChannel)  {
				soundChannel.soundTransform = soundTransform;
				dispatchEvent(new SoundExtendedEvent(SoundExtendedEvent.SOUND_UPDATE, false, false, soundTransform));
			}
		}
		
		// ---- event handlers ----
		
		private function soundOpenHandler(event:Event):void {
			if (isStreaming) {
				_isReadyToPlay = true;
				if (autoPlay) play();
			}
			dispatchEvent(event.clone());
		}
		
		private function soundProgressHandler(event:ProgressEvent):void {
			dispatchEvent(event.clone());
		}
		
		
		private function soundCompleteHandler(event:Event):void {
			trace("loading is complete");
			_isReadyToPlay = true;
			_isLoaded = true;
			dispatchEvent(event.clone());
			
			// if the sound hasn't started playing yet, start it now
			if (autoPlay && !isPlaying) play();
		}
		
		private function channelPlayCompleteHandler(event:Event):void {
			trace("playback is complete");
			pausePosition = 0;
			progressTimer.stop();
			_isPlaying = false;
			
			if (loop == -1 || loop < loopCount) {
				doPlay();
			}
			
			dispatchEvent(event.clone());
		}
		
		private function soundID3Handler(event:Event):void {
			try {
				var id3:ID3Info = event.target.id3;
				
				for (var propName:String in id3) {
					trace(propName + " = " + id3[propName]);
				}
				
			} catch (err:SecurityError) {
				trace("Could not retrieve ID3 data.");
			}
			dispatchEvent(event.clone());
		}
	
		private function soundIOErrorHandler(event:IOErrorEvent):void {
			//trace("** IOERROR **", event.text);
			dispatchEvent(event.clone());
		}
		
		private function soundSecurityErrorHandler(event:SecurityErrorEvent):void {
			//trace("** SECURITY ERROR **", event.text);
			dispatchEvent(event.clone());
		}
		
		private function progressTimerHandler(event:TimerEvent):void {
			_length = Math.ceil(sound.length / (sound.bytesLoaded / sound.bytesTotal));
			
			dispatchEvent(new SoundExtendedEvent(SoundExtendedEvent.PLAY_PROGRESS, false, false, soundTransform, position, length));
			//dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, position, length));
			
			if (position >= length) {
				progressTimer.stop();
				//trace("progress playback is complete");
			} else {
				//trace("busy");
			}
		}
		
		private function playTimerHandler(event:TimerEvent):void {
			var speed:Number = event.target.delay * playSpeed;
			
			if (playDirection == FORWARD) {
				seek(position + speed);
				
			} else if (playDirection == BACKWARDS) {
				seek(position - speed);
			}
		}
		
	}
}
package nl.mediamonkey.behaviors.animationBehaviors {
	
	import flash.events.Event;
	import flash.display.InteractiveObject;
	
	import nl.mediamonkey.behaviors.Behavior;
	import nl.mediamonkey.math.PerlinNoise;
	
	public class WindBehavior extends Behavior {
		
		public var strength		:Number;
		public var property		:String;
		
		protected var base		:Number;
		
		// ---- getters & setters ----
		
		private var _perlin		:PerlinNoise;
		
		public function get perlin():PerlinNoise {
			return _perlin;
		}
		
		// ---- constructor ----
		
		public function WindBehavior(target:InteractiveObject, property:String, strength:Number) {
			super(target);
			
			if (!target.hasOwnProperty(property) || (target[property] is Number) == false) {
				throw new TypeError("invalid property");
			}
			
			this.property = property;
			this.strength = strength;
			this.base = Number(target[property]);
			
			_perlin = new PerlinNoise(300);
			_perlin.base = 10;
			_perlin.minValue = 0;
			_perlin.maxValue = 1;
		}
		
		// ---- event handlers ----
		
		override protected function addListeners(target:InteractiveObject):void {
			super.addListeners(target);
			target.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
		}
		
		override protected function removeListeners(target:InteractiveObject):void {
			super.removeListeners(target);
			target.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function enterFrameHandler(event:Event):void {
			target[property] = base + perlin.nextValue * strength;
		}

	}
	
}

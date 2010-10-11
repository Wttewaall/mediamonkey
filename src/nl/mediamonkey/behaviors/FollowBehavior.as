package nl.mediamonkey.behaviors {
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	[Event(name="click", type="flash.events.MouseEvent")]
	
	public class FollowBehavior extends Behavior {
		
		protected static const RAD_TO_DEG:Number = 180/Math.PI;
		protected static const DEG_TO_RAD:Number = Math.PI/180;
		
		public static const NORMAL	:String = "normal";
		public static const EASE	:String = "ease";
		public static const SPRING	:String = "spring";
		public static const SWARM	:String = "swarm";
		
		public var point		:Point; //optional goal point
		public var offset		:Point; //optional offset point
		
		public var ease			:Number = 0.25;
		public var spring		:Number = 0.7;
		public var speed		:Number = 10; //Speed the target can travel
		public var turnEase		:Number = 0.2; //Percentage the target can rotate toward it's goal in a given step
		public var twitch		:Number = 0; //Angular range of a random "twitch" added to each movement
		
		protected var velocity:Point = new Point();
		
		// ---- getter & setters ----
		
		private var _type			:String;
		private var _targetPoint	:Point;
		
		public function get type():String {
			return _type;
		}
		
		public function set type(value:String):void {
			if (_type != value) {
				_type = value;
				
				velocity.x = velocity.y = 0;
			}
		}
		
		protected function get targetPoint():Point {
			if (point) {
				_targetPoint = point;
				
			} else {
				if (!_targetPoint) _targetPoint = new Point();
				if (!target.stage) return _targetPoint = new Point(0, 0);
				
				_targetPoint.x = target.stage.mouseX + (offset ? offset.x : 0);
				_targetPoint.y = target.stage.mouseY + (offset ? offset.y : 0);
			}
			
			return _targetPoint;
		}
		
		// ---- contructor ----
		
		public function FollowBehavior(target:InteractiveObject=null, type:String="normal") {
			super(target);
			this.type = type;
		}
		
		override protected function addListeners(target:InteractiveObject):void {
			removeListeners(target);
			
			if (type == NORMAL) {
				target.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				
			} else {
				target.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		override protected function removeListeners(target:InteractiveObject):void {
			target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			target.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function mouseMoveHandler(event:MouseEvent):void {
			normalFollow();
		}
		
		protected function enterFrameHandler(event:Event):void {
			switch (type) {
				case SWARM: swarmFollow(); break;
				case EASE: easeFollow(); break;
				case SPRING: springFollow(); break;
				default: normalFollow();
			}
		}
		
		// ---- public methods ----
		
		protected function normalFollow():void {
			target.x = targetPoint.x;
			target.y = targetPoint.y;
		}
		
		protected function easeFollow():void {
			velocity.x = (targetPoint.x - target.x) * ease;
			velocity.y = (targetPoint.y - target.y) * ease;
			
			target.x += velocity.x;
			target.y += velocity.y;
		}
		
		protected function springFollow():void {
			velocity.x = (velocity.x * spring) + (targetPoint.x - target.x) * ease;
			velocity.y = (velocity.y * spring) + (targetPoint.y - target.y) * ease;
			
			target.x += velocity.x;
			target.y += velocity.y;
		}
		
		protected function swarmFollow():void {
			var angle:Number = Math.atan2(targetPoint.y - target.y, targetPoint.x - target.x) * RAD_TO_DEG;
			
			var delta:Number = (angle - target.rotation) * DEG_TO_RAD;
			var deltaAngle:Number = Math.atan2(Math.sin(delta), Math.cos(delta)) * RAD_TO_DEG;
			
			target.rotation += deltaAngle * turnEase + (Math.random() * twitch * 2) - twitch;
			target.x += Math.cos(target.rotation * DEG_TO_RAD) * speed;
			target.y += Math.sin(target.rotation * DEG_TO_RAD) * speed;
		}
		
	}
}
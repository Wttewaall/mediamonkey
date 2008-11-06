package nl.mediamonkey.effects {
	
	import flash.events.EventDispatcher;
	
	import mx.core.mx_internal;
	import mx.effects.Effect;
	import mx.effects.IEffectInstance;
	import mx.events.TweenEvent;
	
	import nl.mediamonkey.effects.effectClasses.MaskEffectInstance;
	
	[Event(name="tweenStart", type="mx.events.TweenEvent")]
	[Event(name="tweenUpdate", type="mx.events.TweenEvent")]
	[Event(name="tweenEnd", type="mx.events.TweenEvent")]
	
	use namespace mx_internal;
	
	public class MaskEffect extends Effect {
		
		private static var AFFECTED_PROPERTIES:Array = [ "visible" ];
		
		public function MaskEffect(target:Object = null) {
			super(target);
	
			instanceClass = MaskEffectInstance;
			hideFocusRing = true;
		}
		
		public var createMaskFunction:Function;	 
		public var moveEasingFunction:Function;
		
		[Inspectable(category="General", format="Boolean", defaultValue="false")]
		mx_internal var persistAfterEnd:Boolean = false;
		 
		public var scaleEasingFunction:Function;
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var scaleXFrom:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var scaleXTo:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var scaleYFrom:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var scaleYTo:Number;
		
		private var _showTarget:Boolean = true;
		private var _showExplicitlySet:Boolean = false;
	
		[Inspectable(category="General", defaultValue="true")]
		public function get showTarget():Boolean {
			return _showTarget;
		}
		
		public function set showTarget(value:Boolean):void {
			_showTarget = value;
			_showExplicitlySet = true;
		}
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var xFrom:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var xTo:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var yFrom:Number;
		
		[Inspectable(category="General", defaultValue="NaN")]
		public var yTo:Number;
		
		override public function set hideFocusRing(value:Boolean):void {
			super.hideFocusRing = value;
		}
		
		override public function get hideFocusRing():Boolean {
			return super.hideFocusRing;
		}
		
		override public function getAffectedProperties():Array {
			return AFFECTED_PROPERTIES;
		}
		
		override protected function initInstance(instance:IEffectInstance):void {
			super.initInstance(instance);
	
			var maskEffectInstance:MaskEffectInstance = MaskEffectInstance(instance);
			
			if (_showExplicitlySet)
				maskEffectInstance.showTarget = showTarget;
			maskEffectInstance.xFrom = xFrom;
			maskEffectInstance.yFrom = yFrom;
			maskEffectInstance.xTo = xTo;
			maskEffectInstance.yTo = yTo;
			maskEffectInstance.scaleXFrom = scaleXFrom;
			maskEffectInstance.scaleXTo = scaleXTo;
			maskEffectInstance.scaleYFrom = scaleYFrom;
			maskEffectInstance.scaleYTo = scaleYTo;
			maskEffectInstance.moveEasingFunction = moveEasingFunction;
			maskEffectInstance.scaleEasingFunction = scaleEasingFunction;
			maskEffectInstance.createMaskFunction = createMaskFunction;
			maskEffectInstance.mx_internal::persistAfterEnd = mx_internal::persistAfterEnd;
			
			EventDispatcher(maskEffectInstance).addEventListener(TweenEvent.TWEEN_START, tweenEventHandler);	
			EventDispatcher(maskEffectInstance).addEventListener(TweenEvent.TWEEN_UPDATE, tweenEventHandler);	   
			EventDispatcher(maskEffectInstance).addEventListener(TweenEvent.TWEEN_END, tweenEventHandler);
		}
		
		protected function tweenEventHandler(event:TweenEvent):void {
			dispatchEvent(event);
		}
	}
	
}

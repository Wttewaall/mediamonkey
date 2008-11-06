package nl.mediamonkey.effects.effectClasses {
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import mx.controls.SWFLoader;
	import mx.core.Container;
	import mx.core.FlexShape;
	import mx.core.IInvalidating;
	import mx.core.IUIComponent;
	import mx.core.mx_internal;
	import mx.effects.EffectInstance;
	import mx.effects.EffectManager;
	import mx.effects.Tween;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.events.TweenEvent;
	
	use namespace mx_internal;
	  
	public class MaskEffectInstance extends EffectInstance {
		
		public function MaskEffectInstance(target:Object) {
			super(target);
		}
		
		protected var effectMask:Shape;
		protected var targetVisualBounds:Rectangle;
		private var effectMaskRefCount:Number = 0;
		private var invalidateBorder:Boolean = false;
		private var moveTween:Tween;
		private var origMask:DisplayObject;
		private var origScrollRect:Rectangle;
		private var scaleTween:Tween;
		private var tweenCount:int = 0;
		private var currentMoveTweenValue:Object;
		private var currentScaleTweenValue:Object;
		private var MASK_NAME:String = "_maskEffectMask";	
		private var dispatchedStartEvent:Boolean = false;	
		private var useSnapshotBounds:Boolean = true;	
		private var stoppedEarly:Boolean = false;
		
		mx_internal var persistAfterEnd:Boolean = false;
		
		private var _createMaskFunction:Function;
		
		public function get createMaskFunction():Function {
			return _createMaskFunction != null ?
				   _createMaskFunction :
				   defaultCreateMask;
		}
		
		public function set createMaskFunction(value:Function):void {
			_createMaskFunction = value;
		}
				
		public var moveEasingFunction:Function;
		
		override public function get playheadTime():Number {
			var value:Number;
			
			if (moveTween)
				value = moveTween.mx_internal::playheadTime;
			
			else if (scaleTween)
				value = scaleTween.mx_internal::playheadTime;
			
			else
				return 0;
				
			return value + super.playheadTime;
		}
		
		override mx_internal function set playReversed(value:Boolean):void {
			if (moveTween)
				moveTween.playReversed = value;
			
			if (scaleTween)
				scaleTween.playReversed = value;
			
			super.playReversed = value;	
		}
		
		public var scaleEasingFunction:Function;
		public var scaleXFrom:Number;
		public var scaleXTo:Number;
		public var scaleYFrom:Number;
		public var scaleYTo:Number;
		
		[Inspectable(category="General", defaultValue="true")]
		private var _showTarget:Boolean = true;
		
		private var _showExplicitlySet:Boolean = false;
		
		public function get showTarget():Boolean {
			return _showTarget;
		}
		
		public function set showTarget(value:Boolean):void {
			_showTarget = value;
			_showExplicitlySet = true;
		}
		
		public var targetArea:Rectangle;
		public var xFrom:Number;
		public var xTo:Number;
		public var yFrom:Number;
		public var yTo:Number;
		
		override public function initEffect(event:Event):void {
			super.initEffect(event);
	
			switch (event.type) {	
				case "childrenCreationComplete":
				case FlexEvent.CREATION_COMPLETE:
				case FlexEvent.SHOW:
				case Event.ADDED:
				case "resizeEnd": {
					showTarget = true;
					break;
				}
			
				case FlexEvent.HIDE:
				case Event.REMOVED:
				case "resizeStart": {
					showTarget = false;
					break;
				}
				case Event.RESIZE: {
					// don't use the snapshot because it will be the wrong size
					useSnapshotBounds = false; 
					break;
				}
			}
		}
		
		override public function startEffect():void {
			// Init the mask only once when the effect is played.
			initMask();
			
			// Register to be notified if the target object is resized.
			target.addEventListener(ResizeEvent.RESIZE, eventHandler);
	
			// This will call playEffect eventually.
			super.startEffect();
		}
		
		override public function play():void {		
			super.play();
			
			// This allows the MaskEffect subclass to set the effect properties.
			initMaskEffect();
			
			EffectManager.mx_internal::startVectorEffect(IUIComponent(target));
					
			//EffectManager.mx_internal::startBitmapEffect(target);
	
			// Move Tween
			
			if (!isNaN(xFrom) &&
				!isNaN(yFrom) &&
				!isNaN(xTo) &&
				!isNaN(yTo))
			{ 
				tweenCount++;
				
				moveTween = new Tween(this, [ xFrom, yFrom ],
									  [ xTo, yTo ], duration, 
									  -1, onMoveTweenUpdate, onMoveTweenEnd);
		
				moveTween.playReversed = playReversed;
		
				// If the caller supplied their own easing equation, override the
				// one that's baked into Tween.
				if (moveEasingFunction != null)
					moveTween.easingFunction = moveEasingFunction;
			}
			
			// Scale Tween
			
			if (!isNaN(scaleXFrom) &&
				!isNaN(scaleYFrom) &&
				!isNaN(scaleXTo) &&
				!isNaN(scaleYTo))
			{ 
				tweenCount++;
				
				scaleTween = new Tween(this, [ scaleXFrom, scaleYFrom ],
									   [ scaleXTo, scaleYTo ], duration,
									   -1, onScaleTweenUpdate, onScaleTweenEnd);
		
				scaleTween.playReversed = playReversed;
		
				// If the caller supplied their own easing equation, override the
				// one that's baked into Tween.
				if (scaleEasingFunction != null)
					scaleTween.easingFunction = scaleEasingFunction;
			}
			
			dispatchedStartEvent = false;
			
			// Call these after tween creation so that saveTweenValues knows which values to dispatch
			if (moveTween) {
				// Set the animation to the initial value
				// before the screen refreshes.
				onMoveTweenUpdate(moveTween.mx_internal::getCurrentValue(0));
			}
			
			if (scaleTween) {
				// Set the animation to the initial value
				// before the screen refreshes.
				onScaleTweenUpdate(scaleTween.mx_internal::getCurrentValue(0));
			}
		}
		
		override public function pause():void {
			super.pause();
		
			if (moveTween)
				moveTween.pause();
	
			if (scaleTween)
				scaleTween.pause();
		}
		
		override public function stop():void {
			stoppedEarly = true;
			super.stop();
			
			if (moveTween)
				moveTween.stop();
			
			if (scaleTween)
				scaleTween.stop();
		}	
		
		override public function resume():void {
			super.resume();
		
			if (moveTween)
				moveTween.resume();
	
			if (scaleTween)
				scaleTween.resume();
		}
		
		override public function reverse():void {
			super.reverse();
			
			if (moveTween)
				moveTween.reverse();
	
			if (scaleTween)
				scaleTween.reverse();
				
			super.playReversed = !playReversed;
		}
		
		override public function end():void {
			stopRepeat = true;
			
			if (moveTween)
				moveTween.endTween();
	
			if (scaleTween)
				scaleTween.endTween();
		}
		
		override public function finishEffect():void {
			target.removeEventListener(ResizeEvent.RESIZE, eventHandler);
			
			if (!persistAfterEnd && !stoppedEarly)
				removeMask();
			
			super.finishEffect();
		}
		
		protected function initMask():void {
			if (!effectMask) {
				if (useSnapshotBounds)
					targetVisualBounds = getVisibleBounds(DisplayObject(target));
				else
					targetVisualBounds = new Rectangle(0, 0, target.width, target.height);
				effectMask = createMaskFunction(target, targetVisualBounds);
	
				// For Containers we need to add the mask
				// to the "allChildren" collection so it doesn't get
				// treated as a content child.
				if (target is Container)
					target.rawChildren.addChild(effectMask); 
				else
					target.addChild(effectMask); 
	
				effectMask.name = MASK_NAME;	
				effectMaskRefCount = 0;
			}
	
			effectMask.x = 0;
			effectMask.y = 0;
			effectMask.alpha = .3;
			effectMask.visible = false;
	
			// If this object already had a transparency mask, then save off
			// the original mask, so that we can restore it when we're done.
			if (effectMaskRefCount++ == 0) {
				if (target.mask)
					origMask = target.mask;	
	
				target.mask = effectMask;	
					
				if (target.scrollRect) {
					origScrollRect = target.scrollRect;
					target.scrollRect = null;
				}		
			}
			
			invalidateBorder = target is Container && 
							   Container(target).border != null &&
							   Container(target).border is IInvalidating && 
							   DisplayObject(Container(target).border).filters != null;
		}
		
		protected function defaultCreateMask(targ:Object, bounds:Rectangle):Shape {
			// By default, create a mask that is the shape of the target.		
			var targetWidth:Number = bounds.width / Math.abs(targ.scaleX);
			var targetHeight:Number = bounds.height / Math.abs(targ.scaleY);
			
			if (targ is SWFLoader) {
				// Make sure the loader's content has been sized
				targ.validateDisplayList(); 
				if (targ.content) {
					targetWidth = targ.contentWidth;
					targetHeight = targ.contentHeight;
				}
			}
			
			var newMask:Shape = new FlexShape();
					
			var g:Graphics = newMask.graphics;
			g.beginFill(0xFFFF00);
			g.drawRect(0, 0, targetWidth, targetHeight);
			g.endFill();
		
			if (target.rotation == 0) {
				newMask.width = targetWidth;
				newMask.height = targetHeight;
				
			} else {
				var angle:Number = targ.rotation * Math.PI / 180;
				
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);
				
				newMask.width =  Math.abs(targetWidth * cos - targetHeight * sin);
				newMask.height = Math.abs(targetWidth * sin + targetHeight * cos);
			}
			
			return newMask;
		}
		
		protected function initMaskEffect():void {
			if (!_showExplicitlySet &&
				propertyChanges &&
				propertyChanges.start["visible"] !== undefined)
			{
				_showTarget = !propertyChanges.start["visible"];
			}
		}
		
		private function getVisibleBounds(targ:DisplayObject):Rectangle {	
			var bitmap:BitmapData = new BitmapData(targ.width + 200, targ.height + 200, true, 0x00000000);
			var m:Matrix = new Matrix();
			m.translate(100, 100);
			bitmap.draw(targ, m);
			var actualBounds:Rectangle = bitmap.getColorBoundsRect(0xFF000000, 0x00000000, false);
			
			actualBounds.x = actualBounds.x - 100;
			actualBounds.y = actualBounds.y - 100;
	
			bitmap.dispose();
			
			if (actualBounds.width < targ.width) {
				actualBounds.width = targ.width;
				actualBounds.x = 0;
			}
			
			if (actualBounds.height < targ.height) {
				actualBounds.height = targ.height;
				actualBounds.y = 0;
			}
			
			return actualBounds;
		}
		
		protected function onMoveTweenUpdate(value:Object):void {
			saveTweenValue(value,null);
		
			if (effectMask) {
				effectMask.x = value[0];
				effectMask.y = value[1];
			}
	
			if (invalidateBorder)
				IInvalidating(Container(target).border).invalidateDisplayList();
		}
		
		protected function onMoveTweenEnd(value:Object):void {
			onMoveTweenUpdate(value);
	
			finishTween();
		}
		
		protected function onScaleTweenUpdate(value:Object):void {
			saveTweenValue(null, value);
		
			if (effectMask) {
				effectMask.scaleX = value[0];
				effectMask.scaleY = value[1];
			}
		}
		
		protected function onScaleTweenEnd(value:Object):void {
			onScaleTweenUpdate(value);
			
			finishTween();
		}
		
		private function finishTween():void {
			if (tweenCount == 0 || --tweenCount == 0) {
				EffectManager.mx_internal::endVectorEffect(IUIComponent(target));
				
				var values:Array = [];
				var value:Object;
				if (moveTween) {
					value = moveTween.getCurrentValue(duration);
					values.push(value[0]);
					values.push(value[1]);
					
				} else {
					values.push(null);
					values.push(null);
				}
				
				if (scaleTween) {
					value = scaleTween.getCurrentValue(duration);
					values.push(value[0]);
					values.push(value[1]);
					
				} else {
					values.push(null);
					values.push(null);
				}
				
				dispatchEvent(new TweenEvent(TweenEvent.TWEEN_END, false, false, values));
						
				finishRepeat();
			}
		}
		
		private function removeMask():void {
			// Although it wasn't the original intended design, it turns out that
			// two mask effects can play simultaneously inside a <parallel> effect.
			// The only gotcha is that we shouldn't clear the mask until both
			// effects are done.  The solution: a reference count.
			if (--effectMaskRefCount == 0) {
				if (origMask == null || (origMask && origMask.name != MASK_NAME))
					target.mask = origMask;
				
				if (origScrollRect) {
					target.scrollRect = origScrollRect;
				}
						
				if (target is Container)
					target.rawChildren.removeChild(effectMask); 
				else
					target.removeChild(effectMask); 	
					
				effectMask = null;	
			}
		}
			
		private function saveTweenValue(moveValue:Object, scaleValue:Object):void {
			if (moveValue != null) {
				currentMoveTweenValue = moveValue;
				
			} else if (scaleValue != null) {
				currentScaleTweenValue = scaleValue;
			}
			
			if ((moveTween == null || currentMoveTweenValue != null)
				&& (scaleTween == null || currentScaleTweenValue != null))
			{
				var values:Array = [];
				if (currentMoveTweenValue) {
					values.push(currentMoveTweenValue[0]);
					values.push(currentMoveTweenValue[1]);
					
				} else {
					values.push(null);
					values.push(null);
				}
				
				if (currentScaleTweenValue) {
					values.push(currentScaleTweenValue[0]);
					values.push(currentScaleTweenValue[1]);
					
				} else {
					values.push(null);
					values.push(null);
				}
				
				if (!dispatchedStartEvent) {
					dispatchEvent(new TweenEvent(TweenEvent.TWEEN_START));
					dispatchedStartEvent = true;
				}
				
				dispatchEvent(new TweenEvent(TweenEvent.TWEEN_UPDATE, false, false, values));
	
				currentMoveTweenValue = null;
				currentScaleTweenValue = null;
			}
		}
		
		override mx_internal function eventHandler(event:Event):void {
			super.eventHandler(event);
	
			// This function is called if the target object is resized.
			if (event.type == ResizeEvent.RESIZE) {	
				var tween:Tween = moveTween;
				if (!tween && scaleTween)
					tween = scaleTween;
				
				if (tween) {
					// Remember the amount of the effect that has already been
					// played.
					var elapsed:Number = getTimer() - tween.mx_internal::startTime;
		
					// Destroy the old tween object. Set its listener to a dummy 
					// object, so that the onTweenEnd function is not called.
					if (moveTween)
						Tween.mx_internal::removeTween(moveTween);
					
					if (scaleTween)
						Tween.mx_internal::removeTween(scaleTween);
					
					// Reset the tween count
					tweenCount = 0;
					removeMask();
					
					// The onTweenEnd function wasn't called, so decrement the 
					// effectMaskRefCount here to keep it in balance.
					//effectMaskRefCount--;		
					// Restart the effect and create a new mask.  This is necessary
					// so that the mask's size matches the target object's new size.
					initMask();
					play();
			
					// Set the tween's clock, so that it thinks 'elapsed'
					// milliseconds of the animation have already played.
					if (moveTween) {
						moveTween.mx_internal::startTime -= elapsed;
						// Update the screen before a repaint occurs
						moveTween.mx_internal::doInterval();
					}
					
					if (scaleTween) {
						scaleTween.mx_internal::startTime -= elapsed;
						// Update the screen before a repaint occurs
						scaleTween.mx_internal::doInterval();
					} 
				}
			}
		}
	}

}
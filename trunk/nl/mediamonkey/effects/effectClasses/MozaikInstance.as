package nl.mediamonkey.effects.effectClasses {
	
	/* PLAN
	
	. MaskEffect kopieren in eigen map, ombouwen zodat effectMask een Loader of MovieClip kan zijn
	. SWFMaskEffect
		- swf in effectMask:Loader inladen en afspelen met play() -> gotoAndStop(frame++)
		- reverse met gotoAndStop(frame--)
	. MovieClipMaskEffect
		- binnen effectMask:MovieClip meerdere children aanmaken
		- animatie programmeren/afspelen met Tweener, onComplete een EffectEvent.EFFECT_END dispatchen
	
	*/
	
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import mx.controls.SWFLoader;
	import mx.core.FlexMovieClip;
	import mx.core.mx_internal;
	import mx.effects.effectClasses.MaskEffectInstance;
	
	use namespace mx_internal;
	
	public class MozaikInstance extends MaskEffectInstance {
		
		protected var effectMCMask:MovieClip;
		
		public function MozaikInstance(target:Object) {
			super(target);
			
			createMaskFunction = createMozaikMask;
		}
		
		protected function createMozaikMask(targ:Object, bounds:Rectangle):MovieClip
		{
			// By default, create a mask that is the shape of the target.		
			var targetWidth:Number = bounds.width / Math.abs(targ.scaleX);
			var targetHeight:Number = bounds.height / Math.abs(targ.scaleY);
			
			if (targ is SWFLoader)
			{
				// Make sure the loader's content has been sized
				targ.validateDisplayList(); 
				if (targ.content)
				{
					targetWidth = targ.contentWidth;
					targetHeight = targ.contentHeight;
				}
			}
			
			var newMask:MovieClip = new FlexMovieClip();
					
			var g:Graphics = newMask.graphics;
			g.beginFill(0xFFFF00);
			g.drawRect(0, 0, targetWidth, targetHeight);
			g.endFill();
		
			if (target.rotation == 0)
			{
				newMask.width = targetWidth;
				newMask.height = targetHeight;
			}
			else
			{
				var angle:Number = targ.rotation * Math.PI / 180;
				
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);
				
				newMask.width =  Math.abs(targetWidth * cos - targetHeight * sin);
				newMask.height = Math.abs(targetWidth * sin + targetHeight * cos);
			}
			
			return newMask;
		}
		
		override protected function initMaskEffect():void
		{
			super.initMaskEffect();
				
			var targetWidth:Number = target is SWFLoader && target.content ?
									 SWFLoader(target).contentWidth :
									 targetVisualBounds.width / Math.abs(target.scaleX);
	
			if (target.rotation != 0)
			{
				// The target.width and target.height are expressed in terms of
				// rotated coordinates, but we need to get the object's height 
				// in terms of unrotated coordinates.
	
				var angle:Number = target.rotation * Math.PI / 180;
				targetWidth = Math.abs(targetVisualBounds.width * Math.cos(angle) -	
									   targetVisualBounds.height * Math.sin(angle));
			}
			
			if (showTarget)
			{
				xFrom = -effectMask.width + targetVisualBounds.x;
				yFrom = targetVisualBounds.y;
				// Line up the right edges of the mask and target
				xTo = effectMask.width <= targetWidth ?
					  targetWidth - effectMask.width + targetVisualBounds.x:
					  targetVisualBounds.x;
				yTo = targetVisualBounds.y;
			}
			else
			{
				// Line up the right edges of the mask and target if mask is wider than target
				xFrom = effectMask.width <= targetWidth ?
						targetVisualBounds.x :
						targetWidth - effectMask.width + targetVisualBounds.x;
				yFrom = targetVisualBounds.y;
				xTo = targetWidth + targetVisualBounds.x;
				yTo = targetVisualBounds.y;
			}
		}
		
	}
}
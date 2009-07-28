package nl.mediamonkey.utils {
	
	/**
	 * @Author:		Bart Wttewaall
	 * @Company:	Mediamonkey
	 * @Website:	http://www.mediamonkey.nl
	 * @Version:	1.3
	 * @Date:		april 30, 2008
	 * 
	 * Description:
	 * This static class will create a popup (TitleWindow) from any Container inheriting class
	 * (Accordion, Box, Canvas, Form, FormItem, LayoutContainer, Panel, Tile, ViewStack).
	 * It will fill the popup with the given item, set effects to the popup and adds listeners.
	 * When no target is given (null), the target will be set to Application.application per default.
	 * 
	 * Known limitations:
	 * . The created TitleWindow's data property will be used for storage of the initObject.
	 *   It may be overwritten, but then the popup will not be centered on resize.
	 * . Removal of the popup's content is not tested (sound or video objects may continue to exist).
	 * . Resizing the popup after dragging will center it on the stage (to do)
	 * 
	 * Tips:
	 * . Register your contentClass instance to PopUpEvent.CLOSE to stop and remove any processes like
	 *   playing sounds or videos.
	 * 
	 * Example:
	 * 
	 * import mx.core.IFlexDisplayObject;
	 * import nl.mediamonkey.events.PopUpEvent;
	 * import nl.mediamonkey.utils.PopUpUtil;
	 * 
	 * var initObject:Object = new Object();
	 * initObject.width = 300;
	 * initObject.height = null; // if null, this property will be set automatically
	 * initObject.title = "PopUp";
	 * initObject.titleIcon = null;
	 * initObject.showCloseButton = true;
	 * initObject.modal = true;
	 * initObject.center = true;
	 * initObject.data = {message:"test"};
	 * 
	 * var popup:IFlexDisplayObject = PopUpUtil.createPopUpFrom(MyPopUpForm, initObject);
	 * popup.addEventListener(PopUpEvent.SUBMIT, popupSubmitHandler);
	 * 
	 * private function popupSubmitHandler(event:PopUpEvent):void {
	 * 		// do something
	 * }
	 * 
	 * Example form:
	 * 
	 * (to do)
	 */
	
	/* To do:
		. fix centering popup on resize/move/fade effect
		. test correct removal of assets in popup on close
		. test popup with other targets & childLists than null
		. test if window.width/height are calculated correctly
		. keep track of all open popups (see PopUpManager.popupInfo which holds PopUpData instances)
	*/
	
	import flash.display.DisplayObject;
	
	import mx.containers.TitleWindow;
	import mx.core.Application;
	import mx.core.Container;
	import mx.core.IFlexDisplayObject;
	import mx.core.IUIComponent;
	import mx.effects.*;
	import mx.effects.easing.*;
	import mx.events.CloseEvent;
	import mx.events.EffectEvent;
	import mx.events.TweenEvent;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import nl.mediamonkey.events.PopUpEvent;
	
	public class PopUpUtil {
		
		public static const STYLE_NAME				:String = "popUpWindowStyle";
		public static const CONTENT_NAME			:String = "content";
		
		public static var showEffectDuration		:Number = 200;
		public static var hideEffectDuration		:Number = 200;
		public static var resizeEffectDuration		:Number = 200;
		
		// ---- public static methods ----
		
		/**
		 * @param target:DisplayObject = null
		 * If the target is null, target will be set to Application.application
		 */
		
		public static function createPopUpFrom(className:Class, initObject:Object=null, target:DisplayObject=null, childList:String=null):IFlexDisplayObject {
			if (className == null) throw new ArgumentError("className cannot be null");
			return addPopUp(new className() as IUIComponent, initObject, target, childList);
		}
		
		public static function addPopUp(content:IUIComponent, initObject:Object=null, target:DisplayObject=null, childList:String=null):IFlexDisplayObject {
			if (content == null) throw new ArgumentError("content cannot be null");
			
			var contentWidth:Number = content.width;
			var contentHeight:Number = content.height;
			
			content.name = CONTENT_NAME;
			content.percentWidth = 100;
			content.percentHeight = 100;
			
			// delegate data from initObject
			if (initObject === null) initObject = new PopUpVO();
			if (initObject.data) (content as Container).data = initObject.data;
			
			// create new TitleWindow
			var window:TitleWindow = new TitleWindow();
			window.addEventListener(CloseEvent.CLOSE, windowCloseHandler)
			window.addEventListener(PopUpEvent.CANCEL, eventHandler);
			window.addEventListener(PopUpEvent.CLOSE, eventHandler);
			window.addEventListener(PopUpEvent.NO, eventHandler);
			window.addEventListener(PopUpEvent.OK, eventHandler);
			window.addEventListener(PopUpEvent.SUBMIT, eventHandler);
			window.addEventListener(PopUpEvent.YES, eventHandler);
			
			// set properties from initObject
			if (initObject != null) {
				window.title = initObject.title;
				window.titleIcon = initObject.titleIcon;
				window.showCloseButton = initObject.showCloseButton;
				window.minWidth = initObject.minWidth;
				window.maxWidth = initObject.maxWidth;
				window.minHeight = initObject.minHeight;
				window.maxHeight = initObject.maxHeight;
				window.data = {center:initObject.center}; // used to center on resize
			}
			
			// add styles & effects
			window.styleName = STYLE_NAME;
			window.setStyle("addedEffect", getShowEffect());
			window.setStyle("removedEffect", getHideEffect());
			window.setStyle("resizeEffect", getResizeEffect());
			
			// add content to TitleWindow
			window.addChild(content as DisplayObject);
			
			// create popup through PopUpManager and add listeners
			if (target == null) {
				target = Application.application as DisplayObject;
				if (childList == null) childList = PopUpManagerChildList.APPLICATION
			}
			
			var modal:Boolean = (initObject) ? initObject.modal : false;
			PopUpManager.addPopUp(window, target, modal, childList);
			
			// overrule isPopUp, set by PopUpManager, if we don't want the window to be draggable
			window.isPopUp = initObject.draggable;
			
			// remove header after creation if there are no headeritems to be shown
			if (!window.showCloseButton && !window.title && !window.titleIcon) {
				window.setStyle("headerHeight", 0);
				window.setStyle("borderThicknessTop", window.getStyle("borderThicknessBottom"));
			}
			
			var w:Number = 0;
			w += window.getStyle("borderThicknessLeft") || 0;
			w += window.getStyle("paddingLeft") || 0;
			w += (initObject && initObject.width > -1) ? initObject.width : contentWidth;
			w += window.getStyle("paddingRight") || 0;
			w += window.getStyle("borderThicknessRight") || 0;
			
			var h:Number = 0;
			h += window.getStyle("headerHeight") || 0;
			h += window.getStyle("borderThicknessTop") || 0;
			h += window.getStyle("paddingTop") || 0;
			h += (initObject && initObject.height > -1) ? initObject.height : contentHeight;
			h += window.getStyle("paddingBottom") || 0;
			h += window.getStyle("borderThicknessBottom") || 0;
			
			// after creation, set the width, height and center the popup
			if ((initObject && initObject.width > -1) || (contentWidth > 0)) window.width = w;
			if ((initObject && initObject.height > -1) || (contentHeight > 0)) window.height = h;
			
			if (initObject) {	
				if (initObject.x || initObject.y) {
					window.x = initObject.x;
					window.y = initObject.y;
					
				} else if (initObject.center) {
					centerPopUp(window);
				}
			}
			
			return window;
		}
		
		public static function centerPopUp(popUp:IFlexDisplayObject):void {
			// todo: calculate the center ourself, we may need it when resizing the content
			PopUpManager.centerPopUp(popUp);
		}
		
		public static function removePopUp(popUp:IFlexDisplayObject):void {
			// todo: test for correct destruction of content
			PopUpManager.removePopUp(popUp);
		}
		
		// ---- effects ----
		
		protected static function getShowEffect():IEffect {
			var showEffect:Parallel = new Parallel();
			
			var blur:Blur = new Blur();
			blur.blurXFrom = 10;
			blur.blurXTo = 0;
			blur.blurYFrom = 10;
			blur.blurYTo = 0;
			blur.duration = showEffectDuration;
						
			var fade:Fade = new Fade();
			fade.alphaFrom = 0;
			fade.alphaTo = 1;
			fade.duration = showEffectDuration;
			
			showEffect.addChild(blur);
			showEffect.addChild(fade);
			
			return showEffect as IEffect;
		}
		
		protected static function getHideEffect():IEffect {
			var hideEffect:Parallel = new Parallel();
			hideEffect.addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
			
			var blur:Blur = new Blur();
			blur.blurXFrom = 0;
			blur.blurXTo = 10;
			blur.blurYFrom = 0;
			blur.blurYTo = 10;
			blur.duration = hideEffectDuration;
			
			var fade:Fade = new Fade();
			fade.alphaFrom = 1;
			fade.alphaTo = 0;
			fade.duration = hideEffectDuration;
			
			hideEffect.addChild(blur);
			hideEffect.addChild(fade);
			
			return hideEffect as IEffect;
		}
		
		protected static function getResizeEffect():IEffect {
			var resizeEffect:Resize = new Resize();
			resizeEffect.addEventListener(TweenEvent.TWEEN_UPDATE, resizeTweenUpdateHandler);
			resizeEffect.duration = resizeEffectDuration;
			resizeEffect.easingFunction = Cubic.easeOut;
			
			return resizeEffect as IEffect;
		}
		
		// ---- event handlers ----
		
		protected static function windowCloseHandler(event:CloseEvent):void {
			var contentChild:DisplayObject = TitleWindow(event.target).getChildByName(CONTENT_NAME);
			contentChild.dispatchEvent(new PopUpEvent(PopUpEvent.CLOSE));
		}
		
		protected static function eventHandler(event:PopUpEvent):void {
			if (event.closeOnEvent) {
				if (event.type != PopUpEvent.CLOSE) {
					// always dispatch close event when closeOnEvent is true, and the type isn't already CLOSE
					event.target.dispatchEvent(new PopUpEvent(PopUpEvent.CLOSE));
				}
				removePopUp(event.currentTarget as IFlexDisplayObject);
			}
			
			// events bubble upwards by default, so they don't need to be delegated
		}
		
		protected static function effectEndHandler(event:EffectEvent):void {
			var window:TitleWindow = event.currentTarget.target as TitleWindow;
			window.removeAllChildren();
		}
		
		protected static function resizeTweenUpdateHandler(event:TweenEvent):void {
			var window:TitleWindow = event.currentTarget.target as TitleWindow;
			
			if (window.data && window.data.center) {
				centerPopUp(window);
				
			} else {
				// move the popup by Move effect to a calculated position
				// problem: no width or height available through anonymous Effect
				// sollution: get width/height on Effect.EFFECT_START ?
				
				/*var nextWidth:Number = Resize(event.target).widthTo;
				var nextHeight:Number = Resize(event.target).heightTo;
				window.x = window.x + (window.width - nextWidth);
				window.y = window.y + (window.height - nextHeight);*/
			}
		}
	}
}
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
	 * . The created TitleWindow's data property will be used for storage of the settings.
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
	 * var settings:Object = new Object();
	 * settings.width = 300;
	 * settings.height = null; // if null, this property will be set automatically
	 * settings.title = "PopUp";
	 * settings.titleIcon = null;
	 * settings.showCloseButton = true;
	 * settings.modal = true;
	 * settings.center = true;
	 * settings.data = {message:"test"};
	 * 
	 * var popup:IFlexDisplayObject = PopUpUtil.createPopUpFrom(MyPopUpForm, settings);
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
	import flash.events.Event;
	
	import mx.containers.TitleWindow;
	import mx.core.Application;
	import mx.core.Container;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.effects.*;
	import mx.effects.easing.*;
	import mx.events.CloseEvent;
	import mx.events.EffectEvent;
	import mx.events.TweenEvent;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import nl.mediamonkey.events.PopUpEvent;
	
	import view.components.DraggableTitleWindow;
	
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
		
		public static function createPopUpFrom(className:Class, settings:Object=null, target:DisplayObject=null, childList:String=null):IFlexDisplayObject {
			if (className == null) throw new ArgumentError("className cannot be null");
			return addPopUp(new className() as UIComponent, settings, target, childList);
		}
		
		public static function addPopUp(content:UIComponent, settings:Object=null, target:DisplayObject=null, childList:String=null):IFlexDisplayObject {
			if (content == null) throw new ArgumentError("content cannot be null");
			
			var contentWidth:Number = content.width;
			var contentHeight:Number = content.height;
			
			content.name = CONTENT_NAME;
			content.percentWidth = 100;
			content.percentHeight = 100;
			content.addEventListener(Event.RESIZE, contentResizeHandler, false, 0, true);
			
			// delegate data from settings
			if (settings === null) settings = new PopUpSettings();
			if (settings.data) (content as Container).data = settings.data;
			
			// create new TitleWindow
			var window:TitleWindow = new TitleWindow();
			//var window:DraggableTitleWindow = new DraggableTitleWindow();
			
			window.addEventListener(CloseEvent.CLOSE, windowCloseHandler)
			window.addEventListener(PopUpEvent.CANCEL, eventHandler);
			window.addEventListener(PopUpEvent.CLOSE, eventHandler);
			window.addEventListener(PopUpEvent.NO, eventHandler);
			window.addEventListener(PopUpEvent.OK, eventHandler);
			window.addEventListener(PopUpEvent.SUBMIT, eventHandler);
			window.addEventListener(PopUpEvent.YES, eventHandler);
			
			// set properties from settings
			if (settings != null) {
				window.title = settings.title;
				window.titleIcon = settings.titleIcon;
				window.showCloseButton = settings.showCloseButton;
				window.minWidth = settings.minWidth;
				window.maxWidth = settings.maxWidth;
				window.minHeight = settings.minHeight;
				window.maxHeight = settings.maxHeight;
				window.data = {center:settings.center}; // used to center on resize
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
			
			var modal:Boolean = (settings) ? settings.modal : false;
			PopUpManager.addPopUp(window, target, modal, childList);
			
			// overrule isPopUp, set by PopUpManager, if we don't want the window to be draggable
			window.isPopUp = settings.draggable;
			
			// remove header after creation if there are no headeritems to be shown
			if (!window.showCloseButton && !window.title && !window.titleIcon && !settings.draggable) {
				window.setStyle("headerHeight", 0);
				window.setStyle("borderThicknessTop", window.getStyle("borderThicknessBottom"));
			}
			
			if (settings.headerHeight) window.setStyle("headerHeight", settings.headerHeight);
			
			var w:Number = 0;
			w += window.getStyle("borderThicknessLeft") || 0;
			w += window.getStyle("paddingLeft") || 0;
			w += (settings && settings.width > -1) ? settings.width : contentWidth;
			w += window.getStyle("paddingRight") || 0;
			w += window.getStyle("borderThicknessRight") || 0;
			
			var h:Number = 0;
			h += window.getStyle("headerHeight") || 0;
			h += window.getStyle("borderThicknessTop") || 0;
			h += window.getStyle("paddingTop") || 0;
			h += (settings && settings.height > -1) ? settings.height : contentHeight;
			h += window.getStyle("paddingBottom") || 0;
			h += window.getStyle("borderThicknessBottom") || 0;
			
			// after creation, set the width, height and center the popup
			if ((settings && settings.width > -1) || (contentWidth > 0)) window.width = w;
			if ((settings && settings.height > -1) || (contentHeight > 0)) window.height = h;
			
			if (settings) {	
				if (settings.x || settings.y) {
					window.x = settings.x;
					window.y = settings.y;
					
				} else if (settings.center) {
					centerPopUp(window);
				}
			}
			
			return window;
		}
		
		public static function centerPopUp(popUp:IFlexDisplayObject):void {
			// todo: calculate the center ourself, we may need it when resizing the content
			try {
				PopUpManager.centerPopUp(popUp);
				
			} catch (e:Error) {
				if (popUp.parent) centerPopUp(popUp.parent as IFlexDisplayObject);
			}
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
		
		protected static function contentResizeHandler(event:Event):void {
			var window:TitleWindow = event.currentTarget.parent as TitleWindow;
			if (!window) return;
			
			var content:UIComponent = window.getChildAt(0) as UIComponent;
			if (!content) return;
			
			var w:Number = 0;
			w += window.getStyle("borderThicknessLeft") || 0;
			w += window.getStyle("paddingLeft") || 0;
			w += content.width;
			w += window.getStyle("paddingRight") || 0;
			w += window.getStyle("borderThicknessRight") || 0;
			
			var h:Number = 0;
			h += window.getStyle("headerHeight") || 0;
			h += window.getStyle("borderThicknessTop") || 0;
			h += window.getStyle("paddingTop") || 0;
			h += content.height;
			h += window.getStyle("paddingBottom") || 0;
			h += window.getStyle("borderThicknessBottom") || 0;
			
			window.width = w;
			window.height = h;
		}
		
	}
}
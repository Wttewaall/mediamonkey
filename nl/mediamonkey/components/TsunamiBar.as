/*
BUSY:
.	animation on selectedItem and prevSelectedItem in resizeChildrenOverX()

TO DO:
.	overflow:Boolean = true;
	> when set to false, lower the minWidth or minHeight to keep everything within the container.
.	add a lensHead: een plat stukje op de lens, ná de lensFunction
*/

package nl.mediamonkey.components {
	
	import caurina.transitions.Equations;
	import caurina.transitions.Tweener;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	[Bindable]
	public class TsunamiBar extends UIComponent {
		
		[DefaultProperty("dataProvider")]
		
		// public static vars
		public static var HORIZONTAL:String = "horizontal";
		public static var VERTICAL:String = "vertical";
		
		// private vars
		private var container:MovieClip;
		private var children:ArrayCollection = new ArrayCollection();
		private var _items:ArrayCollection = new ArrayCollection();
		private var _pendingItems:ArrayCollection;
		private var focusItem:DisplayObject;
		private var prevSelectedDisplayItem:DisplayObject;
		private var animateDown:Boolean = false;
		private var animateUp:Boolean = false;
		private var itemsChanged:Boolean = false;
		
		// getters & setters
		private var _selectedIndex:int = -1;
		
		// public vars
		public var iconField:String = "icon";
		public var labelField:String = "label";
		public var effectPercentage:Number = 0;
		public var rangeX:Number = 200;
		public var rangeY:Number = 200;
		public var spacing:Number = 4; // cap on 0: no negative spacing
		public var selectedWidth:int = 50;
		public var selectedHeight:int = 50;
		public var horizontalAlignPercentage:Number = 0;
		public var verticalAlignPercentage:Number = 0;
		public var direction:String = HORIZONTAL;
		public var lensFunction:Object = Equations.easeOutSine;
		
		// ---- getters & setters ----
		
		public function set dataProvider(value:ArrayCollection):void {
			trace("DP set: "+value.length);
			_items = value;
			//trace("itemsChanged: "+equalItems(_items, value));
			//itemsChanged = equalItems(_items, value);
			
			/*if (itemsChanged) {
				_pendingItems = value;
				invalidateProperties();
			}*/
		}
		
		public function get dataProvider():ArrayCollection {
			return children;
		}
		
		public function get horizontalAlign():String {
			if (horizontalAlignPercentage != 0 && horizontalAlignPercentage != 0.5 && horizontalAlignPercentage != 1) return null;
			return (horizontalAlignPercentage == 0) ? "left" : (horizontalAlignPercentage == 0.5) ? "center" : "right";
		}
		
		public function set horizontalAlign(value:String):void {
			horizontalAlignPercentage = 0;
			if (value == "center") horizontalAlignPercentage = 0.5;
			if (value == "right") horizontalAlignPercentage = 1;
		}
		
		public function get verticalAlign():String {
			if (verticalAlignPercentage != 0 && verticalAlignPercentage != 0.5 && verticalAlignPercentage != 1) return null;
			return (verticalAlignPercentage == 0) ? "top" : (verticalAlignPercentage == 0.5) ? "middle" : "bottom";
		}
		
		public function set verticalAlign(value:String):void {
			verticalAlignPercentage = 0;
			if (value == "middle") verticalAlignPercentage = 0.5;
			if (value == "bottom") verticalAlignPercentage = 1;
		}
		
		public function get selectedIndex():int {
			return _selectedIndex;
		}
		
		public function set selectedIndex(value:int):void {
			value = Math.max(-1, Math.min(value, children.length - 1));
			
			if (_selectedIndex != value) {
				
				prevSelectedDisplayItem = selectedDisplayItem;
				_selectedIndex = value;
				
				Tweener.addTween(prevSelectedDisplayItem, {width:minWidth, height:minHeight, time:0.2, transition:Equations.easeInCubic, onStart:animateDownStart, onUpdate:update, onComplete:animateDownComplete});
				Tweener.addTween(selectedDisplayItem, {width:selectedWidth, height:selectedHeight, time:0.2, transition:Equations.easeInCubic, onStart:animateUpStart, onUpdate:update, onComplete:animateUpComplete});
				
				update();
			}
		}
		
		public function get selectedItem():Object {
			return (_items.length > 0) ? _items.getItemAt(selectedIndex) : null;
		}
		
		public function set selectedItem(value:Object):void {
			selectedIndex = _items.getItemIndex(value);
		}
		
		public function get selectedDisplayItem():DisplayObject {
			return (children.length > 0) ? children.getItemAt(selectedIndex) as DisplayObject : null;
		}
		
		public function set selectedDisplayItem(value:DisplayObject):void {
			selectedIndex = children.getItemIndex(value);
		}
		
		// ---- constructor ----
		
		public function TsunamiBar() {
			super();
			init();
		}
		
		private function init():void {
			configUI();
			
			maxWidth = 50;
			maxHeight = 50;
			
			update();
		}
		
		private function configUI():void {
			
			var maskShape:Sprite = new Sprite();
			maskShape.graphics.beginFill(0);
			maskShape.graphics.drawRect(0,0,10,10);
			maskShape.graphics.endFill();
			addChild(maskShape);
			mask = maskShape;
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
		}
		
		// ---- public methods ----
		
		public function addItem(item:Object):DisplayObject {
			trace("addItem()");
			
			var iconURL:String = (item[iconField] != null) ? item[iconField] : "";
			var label:String = (item[labelField] != null) ? item[labelField] : "";
			
			var loader:Loader = new Loader();
			loader.addEventListener(MouseEvent.CLICK, itemClickHandler);
			loader.load(new URLRequest(iconURL));
			
			children.addItem(loader);
			
			return loader as DisplayObject;
		}
		
		// ---- event handlers ----
		
		private function mouseMoveHandler(event:MouseEvent):void {
			update();
		}
		
		private function mouseOverHandler(event:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Tweener.addTween(this, {effectPercentage:1, time:0.2, transition:Equations.easeInCubic, onUpdate:update});
		}
		
		private function mouseOutHandler(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Tweener.addTween(this, {effectPercentage:0, time:0.2, transition:Equations.easeInCubic, onUpdate:update});
		}
		
		private function itemClickHandler(event:MouseEvent):void {
			selectedIndex = children.getItemIndex(event.currentTarget);
		}
		
		// ---- private methods ----
		
		private function resizeChildren():void {
			measuredWidth = 0;
			measuredHeight = 0;
			
			if (direction == HORIZONTAL) resizeChildrenOverX();
			else if (direction == VERTICAL) resizeChildrenOverY();
			else throw new Error("cannot resize children: direction not set");
		}
		
		// smaller version, just for horizontal layout
		private function resizeChildrenOverX():void {
			
			for (var i:uint=0; i<children.length; i++) {
				var child:DisplayObject = children.getItemAt(i) as DisplayObject;
				
				// distance over x
				var dx:Number = Math.abs(mouseX - child.x - (child.width/2));
				
				// effect range (scalar) over x
				var ex:Number = (dx <= rangeX) ? 1 - dx/rangeX : 0;
				var w:Number = minWidth + lensFunction(ex, 0, maxWidth - minWidth, 1) * effectPercentage;
				
				// keepAspectRatio == true
				if (child === selectedDisplayItem) {
					if (animateUp) {
						child.width = child.height = Math.min(child.width, Math.min(w, selectedWidth));
						if (child.width >= w) animateUp = false;
					} else {
						//child.width = child.height = Math.max(w, selectedWidth);
					}
				} else if (child === prevSelectedDisplayItem) {
					if (animateDown) {
						if (child.width > w) {
							child.width = child.height = Math.max(w, child.width);
						} else {
							animateDown = false;
						}
					}
				} else {
					child.width = child.height = w;
				}
				
				measuredWidth += (i < children.length-1) ? w + spacing : w; // do not add spacing after last child
				measuredHeight = Math.max(measuredHeight, w);
				
				if (!focusItem) focusItem = child;
				
				// test if the child is the focusItem (item closest to the mouse)
				var fx:Number = Math.abs(mouseX - focusItem.x - (focusItem.width/2));
				focusItem = (dx <= fx) ? child : focusItem;
			}
			
			// now bring the top item under cursor to the front so it won't overlap other children
			if (focusItem) bringToFront(this, focusItem);
		}
		
		// smaller version, just for vertical layout
		private function resizeChildrenOverY():void {
			
			for (var i:uint=0; i<children.length; i++) {
				var child:DisplayObject = children.getItemAt(i) as DisplayObject;
				
				// distance over y
				var dy:Number = Math.abs(mouseY - child.y - (child.height/2));
				
				// effect range (scalar) over y
				var ey:Number = (dy <= rangeY) ? 1 - dy/rangeY : 0;
				var h:Number = minHeight + lensFunction(ey, 0, maxHeight - minHeight, 1) * effectPercentage;
				
				// keepAspectRatio == true
				if (child === selectedDisplayItem) {
					child.width = child.height = Math.max(h, selectedHeight);
				} else {
					child.width = child.height = h;
				}
				
				measuredWidth = Math.max(measuredWidth, h);
				measuredHeight += (i < children.length-1) ? h + spacing : h; // do not add spacing after last child
				
				if (!focusItem) focusItem = child;
				
				// test if the child is the focusItem (item closest to the mouse)
				var fy:Number = Math.abs(mouseY - focusItem.y - (focusItem.height/2));
				focusItem = (dy <= fy) ? child : focusItem;
			}
			
			// now bring the top item under cursor to the front so it won't overlap other children
			if (focusItem) bringToFront(this, focusItem);
		}
		
		private function arrangeChildren():void {
			var diff:Number;
			var pos:Number;
			var offsetX:Number = 0;
			var offsetY:Number = 0;
			var childOffsetX:Number = 0;
			var childOffsetY:Number = 0;
			
			// move all children to the opposite of the mouse when overflowing
			if (measuredWidth > width) {
				diff = measuredWidth - width;
				pos = Math.max(0, Math.min(mouseX/width, 1));
				offsetX = diff * horizontalAlignPercentage + (-diff * pos) * effectPercentage;
			}
			if (measuredHeight > height) {
				diff = measuredHeight - height;
				pos = Math.max(0, Math.min(mouseY/height, 1));
				offsetY = diff * verticalAlignPercentage + (-diff * pos) * effectPercentage;
			}
			
			for (var i:uint=0; i<children.length; i++) {
				var child:DisplayObject = children.getItemAt(i) as DisplayObject;
				
				// cap container boundaries
				var mw:Number = (direction == HORIZONTAL) ? width - measuredWidth : width - child.width;
				var ox:Number = mw * horizontalAlignPercentage; // offset over x by percentage
				
				// cap container boundaries
				var mh:Number = (direction == VERTICAL) ? height - measuredHeight : height - child.height;
				var oy:Number = mh * verticalAlignPercentage; // offset over y by percentage
				
				child.x = offsetX + childOffsetX + ox;
				child.y = offsetY + childOffsetY + oy;
				
				if (direction == HORIZONTAL) childOffsetX += child.width + spacing; // nevermind the added spacing at the last child
				if (direction == VERTICAL) childOffsetY += child.height + spacing;
			}
		}
		
		// ---- private methods ----
		
		private function update():void {
			if (children != null && children.length > 0) {
				resizeChildren();
				arrangeChildren();
			}
		}
		
		private function animateDownStart():void {
			animateDown = true;
		}
		
		private function animateUpStart():void {
			animateUp = true;
		}
		
		private function animateDownComplete():void {
			animateDown = false;
		}
		
		private function animateUpComplete():void {
			animateUp = false;
		}
		
		private function bringToFront(parent:UIComponent, child:DisplayObject):void {
			var index:int = parent.getChildIndex(child);
			if (index < parent.numChildren-1) {
				parent.setChildIndex(child, parent.numChildren-1);
			}
		}
		
		private function getItemIndex(arr:Array, item:Object):int {
			for (var i:uint=0; i<arr.length; i++) {
				if (arr[i] === item) return i;
			}
			return -1;
		}
		
		// ---- misc ----
		
		override protected function commitProperties():void {
			// its now safe to switch over to a new dataProvider.
			if(_pendingItems != null) {
				_items = _pendingItems;
				_pendingItems = null;
			}
			
			trace("dataProvider.length: "+dataProvider.length);
			if(itemsChanged) {
				children.removeAll(); // change into a compare method to only remove old, and add new items
				
				for (var i:uint = 0; i<dataProvider.length; i++) {
					//_pdata[i] = new FisheyeItem();
					//_mouseData[i] = new FisheyeItem();
					//trace("item: "+dataProvider[i]);
					
					var item:Object = dataProvider.getItemAt(i);
					trace("+ adding item: "+ObjectUtil.toString(item));
					
					addItem(item);
				}
			}
			
			itemsChanged = false;
			invalidateSize();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			graphics.clear();
			graphics.moveTo(0,0);
			graphics.beginFill(0,0);
			graphics.drawRect(0,0,unscaledWidth,unscaledHeight);
			
			// update the mask
			mask.width = unscaledWidth;
			mask.height = unscaledHeight;
			//animator.invalidateLayout();			
		}

		override public function styleChanged(styleProp:String):void {
			//if(styleProp == "animationSpeed") animator.animationSpeed = getStyle("animationSpeed");
			invalidateSize();
			invalidateDisplayList();
			//animator.invalidateLayout();
		}
		
		private function equalItems(oldItems:ArrayCollection, newItems:ArrayCollection):Boolean {
			trace("equalItems");
			if (oldItems.length == 0 && newItems.length == 0) {
				trace("both no items");
				return false;
			}
			
			if (oldItems.length != newItems.length) {
				return false;
			}
			
			//var largest:ArrayCollection = (oldItems.length > newItems.length) ? oldItems : newItems;
			for (var i:int=0; i<oldItems.length; i++) {
				if (oldItems.getItemAt(i) !== newItems.getItemAt(i)) {
					trace("unequal item found");
					return false;
				}
			}
			
			trace("equal");
			
			return true;
		}
		
	}
}
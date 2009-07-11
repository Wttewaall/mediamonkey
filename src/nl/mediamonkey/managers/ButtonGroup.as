package nl.mediamonkey.managers {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Button;
	import mx.core.IMXMLObject;
	
	[Event(name="added",			type="flash.events.Event")]
	[Event(name="change",			type="flash.events.Event")]
	[Event(name="removed",			type="flash.events.Event")]
	
	[DefaultProperty("items")]
	
	public class ButtonGroup extends EventDispatcher implements IMXMLObject {
		
		public var deselectOnDisabled		:Boolean;
		public var deselectable				:Boolean;
		
		protected var buttons				:ArrayCollection = new ArrayCollection();
		protected var prevSelection			:Button;
		protected var oldSelection			:Button; // var for temp. old selection
		protected var selectOnAddButton	:Button;
		
		private var document				:Object;
		
		// ---- getters & setters ----
		
		protected var _innerChildren:Array;
		protected var _enabled:Boolean = true;
		protected var _selection:Button = null;
		
		[Bindable]
		public function set items(value:Array):void {
			_innerChildren = value;
			assignInnerChildren();
		}
		
		public function get items():Array {
			return _innerChildren;
		}
		
		[Bindable(event="change")]
		public function get enabled():Boolean {
			var enabledButtons:int = 0;
			for (var i:uint=0; i<buttons.length; i++) {
				enabledButtons += (buttons.getItemAt(i) as Button).enabled;
			}
			
			return (enabledButtons > 0);
		}
		
		public function set enabled(value:Boolean):void {
			if (_enabled != value) {
				_enabled = value;
				
				if (deselectOnDisabled) {
					if (value == true) {
						if (!selection && prevSelection) selection = prevSelection;
						if (selection) selection.selected = true;
						prevSelection = null;
						
					} else {
						prevSelection = selection;
						if (selection) selection.selected = false;
						selection = null;
					}
				}
				
				for (var i:uint=0; i<buttons.length; i++) {
					(buttons.getItemAt(i) as Button).enabled = _enabled;
				}
				
				dispatchEvent(new Event("change"));
			}
		}
		
		[Bindable(event="change")]
		public function get selection():Button {
			return _selection;
		}
		
		public function set selection(value:Button):void {
			var hasButton:Boolean = buttons.contains(value);
			
			if (_selection == value && value != null) {
				_selection.selected = (deselectable) ? _selection.selected : true;
				_selection.toggle = true;
				return;
			}
			
			oldSelection = _selection;
			
			if (oldSelection != null) {
				oldSelection.selected = false;
				oldSelection.toggle = false;
			}
			
			if (value == null) {
				_selection = value;
				dispatchEvent(new Event("change"));
				
			} else if (hasButton) {
				_selection = value;
				_selection.selected = true;
				_selection.toggle = true;
				dispatchEvent(new Event("change"));
				
			} else {
				selectOnAddButton = value;
			}
			
			/*if (value == null) {
				
				oldSelection = _selection;
				if (oldSelection != null) {
					oldSelection.selected = false;
					oldSelection.toggle = false;
				}
				
				_selection = value;
				
				dispatchEvent(new Event("selectionChange"));
				
			} else if (_selection != value) {
				
				oldSelection = _selection;
				if (oldSelection != null) {
					oldSelection.selected = false;
					oldSelection.toggle = false;
				}
				
				_selection = value;
				_selection.selected = true;
				_selection.toggle = true;
				
				oldSelection = null;
				dispatchEvent(new Event("selectionChange"));
				
			} else {
				// do nothing
			}*/
			
			//trace("selection:", _selection.name);
		}
		
		public function get length():int {
			return buttons.length;
		}
		
		// ---- constructor ----
		
		public function ButtonGroup() {
		}
		
		public function initialized(document:Object, id:String):void {
			this.document = document;
			
			assignInnerChildren();
		}
		
		protected function assignInnerChildren():void {
			if (!items || items.length == 0) return;
			
			var item:Button;
			for(var i:int = 0;i<items.length;i++) {
				item = items[i] as Button;
				if (item) addButton(item);
			}
		}
		
		// ---- public methods ----
		
		public function addButton(button:Button):void {
			if (buttons.contains(button)) return;
			
			button.addEventListener(MouseEvent.CLICK, buttonClickHandler);
			button.toggle = true;
			buttons.addItem(button);
			
			if (selectOnAddButton === button) {
				selection = button;
				selectOnAddButton = null;
			}
			
			dispatchEvent(new Event(Event.ADDED));
		}
		
		public function getButtonAt(index:int):Button {
			return buttons.getItemAt(index) as Button;
		}
		
		public function removeButton(button:Button):void {
			if (!buttons.contains(button)) return;
			
			if (selection === button) selection = null;
			
			button.removeEventListener(MouseEvent.CLICK, buttonClickHandler);
			buttons.removeItemAt(buttons.getItemIndex(button));
			
			dispatchEvent(new Event(Event.REMOVED));
		}
		
		public function removeButtonAt(index:int):void {
			var button:Button = buttons.getItemAt(index) as Button;
			if (button) removeButton(button);
		}
		
		public function removeAll():void {
			var i:uint = buttons.length;
			while (i--) {
				removeButton(buttons.getItemAt(i) as Button);
			} 
		}
		
		// ---- event handlers ----
		
		protected function buttonClickHandler(event:Event):void {
			var button:Button = event.target as Button;
			selection = button;
			
			/*if (button.selected) {
				selection = button;
				
			} else {
				if (button != oldSelection && deselectable) {
					selection = null;
					
				} else {
					selection = button;
					//button.selected = true;
				}*/
				
				// button can toggle on deselectable
				/*if (selection == button && selection.toggle) {
					selection.toggle = false;
					selection.selected = (!deselectable);
				}
			}*/
		}
		
	}
}
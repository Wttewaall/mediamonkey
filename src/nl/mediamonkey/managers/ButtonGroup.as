package nl.mediamonkey.managers {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Button;
	import mx.events.FlexEvent;
	
	[Event(name="added",			type="flash.events.Event")]
	[Event(name="enabledChange",	type="flash.events.Event")]
	[Event(name="removed",			type="flash.events.Event")]
	[Event(name="selectionChange",	type="flash.events.Event")]
	
	public class ButtonGroup extends EventDispatcher {
		
		protected var buttons			:ArrayCollection = new ArrayCollection();
		protected var prevSelection		:Button;
		protected var oldSelection		:Button; // var for temp. old selection
		
		public var name					:String;
		public var deselectOnDisabled	:Boolean;
		public var deselectable			:Boolean;
		
		public function ButtonGroup(name:String=null) {
			this.name = name;
		}
		
		// ---- getters & setters ----
		
		protected var _enabled:Boolean = true;
		protected var _selection:Button = null;
		
		[Bindable(event="enabledChange")]
		public function get enabled():Boolean {
			var enabledButtons:int = 0;
			for (var i:uint=0; i<buttons.length; i++) {
				enabledButtons += buttons.getItemAt(i).enabled;
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
					Button(buttons.getItemAt(i)).enabled = _enabled;
				}
				
				dispatchEvent(new Event("enabledChange"));
			}
		}
		
		[Bindable(event="selectionChange")]
		public function get selection():Button {
			return _selection;
		}
		
		public function set selection(value:Button):void {
			if (value == null) {
				
				if (_selection) {
					oldSelection = _selection;
					_selection.selected = false;
					_selection.toggle = false;
				}
				
				_selection = value;
				
				oldSelection = null;
				dispatchEvent(new Event("selectionChange"));
				
			} else if (_selection != value) {
				
				if (_selection) {
					oldSelection = _selection;
					_selection.selected = false;
					_selection.toggle = false;
				}
				
				_selection = value;
				_selection.selected = true;
				_selection.toggle = true;
				
				oldSelection = null;
				dispatchEvent(new Event("selectionChange"));
				
			} else {
				// do nothing
			}
		}
		
		public function get numButtons():int {
			return buttons.length;
		}
		
		// ---- public methods ----
		
		public function addButton(button:Button):void {
			if (buttons.contains(button)) return;
			
			button.addEventListener(FlexEvent.VALUE_COMMIT, valueCommitHandler);
			button.toggle = true;
			buttons.addItem(button);
			
			dispatchEvent(new Event(Event.ADDED));
		}
		
		public function removeButton(button:Button):void {
			if (!buttons.contains(button)) return;
			
			button.removeEventListener(FlexEvent.VALUE_COMMIT, valueCommitHandler);
			buttons.removeItemAt(buttons.getItemIndex(button));
			
			dispatchEvent(new Event(Event.REMOVED));
		}
		
		// ---- event handlers ----
		
		protected function valueCommitHandler(event:Event):void {
			var button:Button = event.target as Button;
			
			//trace("button == oldSelection: "+(button != oldSelection));
			
			if (button.selected) {
				selection = button;
				
			} else {
				/*trace("--\ndeselecting button");
				if (button != oldSelection && deselectable) {
					selection = null;
				} else {
					button.selected = true;
				}*/
				
				// button can toggle on deselectable
				/*if (selection == button && selection.toggle) {
					selection.toggle = false;
					selection.selected = (!deselectable);
				}*/
			}
		}
		
	}
}
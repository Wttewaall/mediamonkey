package view.components {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	
	import mx.controls.TextInput;
	import mx.core.FlexVersion;
	import mx.core.IUITextField;
	import mx.core.UITextField;
	import mx.core.mx_internal;
	
	import nl.mediamonkey.enum.Key;
	import nl.mediamonkey.io.KeyPoll;
	
	use namespace mx_internal;
	
	public class KeyboardInput extends TextInput {
		
		protected var poll:KeyPoll;
		
		// ---- getters & setters ----
		
		private var _keys:Array = new Array();
		
		[Bindable]
		public function get keys():Array {
			return _keys;
		}
		
		public function set keys(value:Array):void {
			_keys = value;
			updateInput();
		}
		
		// ---- constructor ----
		
		public function KeyboardInput() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function init():void {
			poll = new KeyPoll(this.stage);
			poll.addEventListener(KeyboardEvent.KEY_DOWN, pollKeyDownHandler);
		}
		
		// ---- event handlers ----
		
		protected function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			init();
		}
		
		override protected function focusInHandler(event:FocusEvent):void {
	        super.focusInHandler(event);
			setSelection(0, text.length); // select all input
		}
		
		override protected function focusOutHandler(event:FocusEvent):void {
	        super.focusOutHandler(event);
			setSelection(0, 0); // deselect input
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.BACKSPACE: {
					event.stopPropagation();
					keys.pop(); // removes last key from input
					updateInput();
					break;
				}
				case Keyboard.ESCAPE: {
					focusManager.hideFocus(); // doesn't work?
					return;
				}
			}
	        
			// overrule text input by setting back previous text
	        var temp:String = text;
			text = "";
			text = temp;
	    }
		
		protected function pollKeyDownHandler(event:KeyboardEvent):void {
			keys = poll.getDownKeys();
			keys.sort(sortModifiersFirst);
			
			updateInput();
		}
		
		protected function updateInput():void {
			text = "";
			
			var output:String = "";
			var key:Key;
			
			for (var i:uint=0; i<keys.length; i++) {
				key = Key.getKeyByCode(keys[i]);
				output += (output.length > 0) ? "+" : "";
				output += (key.character) ? key.character : key.description;
			}
			
			text = output;
			setSelection(text.length, text.length);
		}
		
	    // ---- override mx_internal methods ----
	    
	    override mx_internal function createTextField(childIndex:int):void {
	        if (!textField) {
	            textField = IUITextField(createInFontContext(UITextField));
	
	            textField.autoSize = TextFieldAutoSize.NONE;
	            textField.enabled = enabled;
	            textField.ignorePadding = false;
	            textField.multiline = false;
	            textField.tabEnabled = true;
	            textField.wordWrap = false;
	            
	            if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0)
	                textField.styleName = this;
				
				/** disable all these listeners **/
	            /*textField.addEventListener(Event.CHANGE, textField_changeHandler);
	            textField.addEventListener(TextEvent.TEXT_INPUT, textField_textInputHandler);
	            textField.addEventListener(Event.SCROLL, textField_scrollHandler);
	            textField.addEventListener("textFieldStyleChange", textField_textFieldStyleChangeHandler);
	            textField.addEventListener("textFormatChange", textField_textFormatChangeHandler);
	            textField.addEventListener("textInsert", textField_textModifiedHandler);                                       
	            textField.addEventListener("textReplace", textField_textModifiedHandler);                                       
				textField.addEventListener("nativeDragDrop", textField_nativeDragDropHandler);*/
	            
				if (childIndex == -1)
					addChild(DisplayObject(textField));
				else
					addChildAt(DisplayObject(textField), childIndex);
	        }
	    }
		
		// ---- sort methods ----
		
		private function sortModifiersFirst(a:uint, b:uint):int {
			if (a == b) return 0; // same keyCode
			else if (isModifier(a) && !isModifier(b)) return -1; // modifier before non-modifier
			else if (!isModifier(a) && isModifier(b)) return 1; // modifier before non-modifier
			else if (isModifier(a) && isModifier(b)) return (isModifier(a) < isModifier(b)) ? -1 : 1;
			else return (a < b) ? -1 : 1; // non-modifiers: compare keyCode
		}
		
		private function isModifier(key:uint):int {
			if (key == Key.CONTROL.code) return 1;
			else if (key == Key.SHIFT.code) return 2;
			else if (key == Key.ALT.code) return 3;
			else return 0;
		}
		
	}
}
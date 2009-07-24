package nl.mediamonkey.enum {
	
	public class KeyCode {
		
		// Numeric keys
		public static const KEY_0					:KeyCode = new KeyCode("0", 48);
		public static const KEY_1					:KeyCode = new KeyCode("1", 49);
		public static const KEY_2					:KeyCode = new KeyCode("2", 50);
		public static const KEY_3					:KeyCode = new KeyCode("3", 51);
		public static const KEY_4					:KeyCode = new KeyCode("4", 52);
		public static const KEY_5					:KeyCode = new KeyCode("5", 53);
		public static const KEY_6					:KeyCode = new KeyCode("6", 54);
		public static const KEY_7					:KeyCode = new KeyCode("7", 55);
		public static const KEY_8					:KeyCode = new KeyCode("8", 56);
		public static const KEY_9					:KeyCode = new KeyCode("9", 57);
		
		// Alphanumeric keys
		public static const KEY_A					:KeyCode = new KeyCode("A", 65);
		public static const KEY_B					:KeyCode = new KeyCode("B", 66);
		public static const KEY_C					:KeyCode = new KeyCode("C", 67);
		public static const KEY_D					:KeyCode = new KeyCode("D", 68);
		public static const KEY_E					:KeyCode = new KeyCode("E", 69);
		public static const KEY_F					:KeyCode = new KeyCode("F", 70);
		public static const KEY_G					:KeyCode = new KeyCode("G", 71);
		public static const KEY_H					:KeyCode = new KeyCode("H", 72);
		public static const KEY_I					:KeyCode = new KeyCode("I", 73);
		public static const KEY_J					:KeyCode = new KeyCode("J", 74);
		public static const KEY_K					:KeyCode = new KeyCode("K", 75);
		public static const KEY_L					:KeyCode = new KeyCode("L", 76);
		public static const KEY_M					:KeyCode = new KeyCode("M", 77);
		public static const KEY_N					:KeyCode = new KeyCode("N", 78);
		public static const KEY_O					:KeyCode = new KeyCode("O", 79);
		public static const KEY_P					:KeyCode = new KeyCode("P", 80);
		public static const KEY_Q					:KeyCode = new KeyCode("Q", 81);
		public static const KEY_R					:KeyCode = new KeyCode("R", 82);
		public static const KEY_S					:KeyCode = new KeyCode("S", 83);
		public static const KEY_T					:KeyCode = new KeyCode("T", 84);
		public static const KEY_U					:KeyCode = new KeyCode("U", 85);
		public static const KEY_V					:KeyCode = new KeyCode("V", 86);
		public static const KEY_W					:KeyCode = new KeyCode("W", 87);
		public static const KEY_X					:KeyCode = new KeyCode("X", 88);
		public static const KEY_Y					:KeyCode = new KeyCode("Y", 89);
		public static const KEY_Z					:KeyCode = new KeyCode("Z", 90);
		
		// Function keys
		public static const KEY_F1					:KeyCode = new KeyCode("F1", 112);
		public static const KEY_F2					:KeyCode = new KeyCode("F2", 113);
		public static const KEY_F3					:KeyCode = new KeyCode("F3", 114);
		public static const KEY_F4					:KeyCode = new KeyCode("F4", 115);
		public static const KEY_F5					:KeyCode = new KeyCode("F5", 116);
		public static const KEY_F6					:KeyCode = new KeyCode("F6", 117);
		public static const KEY_F7					:KeyCode = new KeyCode("F7", 118);
		public static const KEY_F8					:KeyCode = new KeyCode("F8", 119);
		public static const KEY_F9					:KeyCode = new KeyCode("F9", 120);
		public static const KEY_F10					:KeyCode = new KeyCode("F10", 121);
		public static const KEY_F11					:KeyCode = new KeyCode("F11", 122);
		public static const KEY_F12					:KeyCode = new KeyCode("F12", 123);
		public static const KEY_F13					:KeyCode = new KeyCode("F13", 124);
		public static const KEY_F14					:KeyCode = new KeyCode("F14", 125);
		public static const KEY_F15					:KeyCode = new KeyCode("F15", 126);
		
		// Numpad keys
		public static const KEY_NUMPAD_0			:KeyCode = new KeyCode("Numpad_0", 96);
		public static const KEY_NUMPAD_1			:KeyCode = new KeyCode("Numpad_1", 97);
		public static const KEY_NUMPAD_2			:KeyCode = new KeyCode("Numpad_2", 98);
		public static const KEY_NUMPAD_3			:KeyCode = new KeyCode("Numpad_3", 99);
		public static const KEY_NUMPAD_4			:KeyCode = new KeyCode("Numpad_4", 100);
		public static const KEY_NUMPAD_5			:KeyCode = new KeyCode("Numpad_5", 101);
		public static const KEY_NUMPAD_6			:KeyCode = new KeyCode("Numpad_6", 102);
		public static const KEY_NUMPAD_7			:KeyCode = new KeyCode("Numpad_7", 103);
		public static const KEY_NUMPAD_8			:KeyCode = new KeyCode("Numpad_8", 104);
		public static const KEY_NUMPAD_9			:KeyCode = new KeyCode("Numpad_9", 105);
		public static const KEY_NUMPAD_MULTIPLY		:KeyCode = new KeyCode("Numpad_Multiply", 106); // *
		public static const KEY_NUMPAD_ADD			:KeyCode = new KeyCode("Numpad_Add", 107); // +
		public static const KEY_NUMPAD_ENTER		:KeyCode = new KeyCode("Numpad_Enter", 108); // Enter
		public static const KEY_NUMPAD_SUBTRACT		:KeyCode = new KeyCode("Numpad_Subtract", 109); // -
		public static const KEY_NUMPAD_DECIMAL		:KeyCode = new KeyCode("Numpad_Decimal", 110); // .
		public static const KEY_NUMPAD_DIVIDE		:KeyCode = new KeyCode("Numpad_Divide", 111); // /
		
		public static const KEY_BACKSPACE			:KeyCode = new KeyCode("Backspace", 8);//backspace
		public static const KEY_TAB					:KeyCode = new KeyCode("Tab", 9);//tab
		public static const KEY_ENTER				:KeyCode = new KeyCode("Enter", 13);//main ENTER
		public static const KEY_SHIFT				:KeyCode = new KeyCode("Shift", 16);//shift
		public static const KEY_CONTROL				:KeyCode = new KeyCode("Ctrl", 17);//ctrl
		public static const KEY_ESCAPE				:KeyCode = new KeyCode("Esc", 27);//esc
		public static const KEY_SPACE				:KeyCode = new KeyCode("Space", 32);//space
		
		// Lock keys
		public static const KEY_CAPS_LOCK			:KeyCode = new KeyCode("Cap", 20);//caps lock
		public static const KEY_NUM_LOCK			:KeyCode = new KeyCode("Num", 144);//num lock
		public static const KEY_SCROLL_LOCK			:KeyCode = new KeyCode("Scroll", 145);//scroll lock
		
		public static const KEY_PAUSE				:KeyCode = new KeyCode("Pause", 19);//pause / break
		public static const KEY_PAGE_UP				:KeyCode = new KeyCode("PageUp", 33);//page up
		public static const KEY_PAGE_DOWN			:KeyCode = new KeyCode("PageDown", 34);//page down
		public static const KEY_END					:KeyCode = new KeyCode("End", 35);//end
		public static const KEY_HOME				:KeyCode = new KeyCode("Home", 36);//home
		public static const KEY_INSERT				:KeyCode = new KeyCode("Insert", 45);//insert
		public static const KEY_DELETE				:KeyCode = new KeyCode("Delete", 46);//delete
		
		// Arrow keys
		public static const KEY_LEFT				:KeyCode = new KeyCode("Left", 37);//left arrow
		public static const KEY_UP					:KeyCode = new KeyCode("Up", 38);//up arrow
		public static const KEY_RIGHT				:KeyCode = new KeyCode("Right", 39);//right arrow
		public static const KEY_DOWN				:KeyCode = new KeyCode("Down", 40);//down arrow
		
		// Windows keys
		public static const KEY_WINDOWS				:KeyCode = new KeyCode("Win", 91);//windows
		public static const KEY_MENU				:KeyCode = new KeyCode("Menu", 93);//menu
		
		public var description:String;
		public var code:uint;
		
		/**
		 * Create a KeyCode with string and key code.
		 * Todo: add sequence, like [KEY_CONTROL, KEY_SHIFT, KEY_E] = CTRL+SHIFT+E
		 */
		public function KeyCode(description:String, code:uint){
			this.description = description;
			this.code = code;
		}
		
		public function getCodeSequence():Array{
			return [code];
		}
		
		public function toString():String{
			return "[KeyCode "+description+"]";
		}
		
	}
}
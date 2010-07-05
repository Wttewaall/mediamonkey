package nl.mediamonkey.io.data {
	
	import flash.utils.Dictionary;
	
	public class Key {
		
		// Numeric keys
		public static const NUM_0				:Key = new Key("0", 48);
		public static const NUM_1				:Key = new Key("1", 49);
		public static const NUM_2				:Key = new Key("2", 50);
		public static const NUM_3				:Key = new Key("3", 51);
		public static const NUM_4				:Key = new Key("4", 52);
		public static const NUM_5				:Key = new Key("5", 53);
		public static const NUM_6				:Key = new Key("6", 54);
		public static const NUM_7				:Key = new Key("7", 55);
		public static const NUM_8				:Key = new Key("8", 56);
		public static const NUM_9				:Key = new Key("9", 57);
		
		// Alphanumeric keys
		public static const A					:Key = new Key("A", 65);
		public static const B					:Key = new Key("B", 66);
		public static const C					:Key = new Key("C", 67);
		public static const D					:Key = new Key("D", 68);
		public static const E					:Key = new Key("E", 69);
		public static const F					:Key = new Key("F", 70);
		public static const G					:Key = new Key("G", 71);
		public static const H					:Key = new Key("H", 72);
		public static const I					:Key = new Key("I", 73);
		public static const J					:Key = new Key("J", 74);
		public static const K					:Key = new Key("K", 75);
		public static const L					:Key = new Key("L", 76);
		public static const M					:Key = new Key("M", 77);
		public static const N					:Key = new Key("N", 78);
		public static const O					:Key = new Key("O", 79);
		public static const P					:Key = new Key("P", 80);
		public static const Q					:Key = new Key("Q", 81);
		public static const R					:Key = new Key("R", 82);
		public static const S					:Key = new Key("S", 83);
		public static const T					:Key = new Key("T", 84);
		public static const U					:Key = new Key("U", 85);
		public static const V					:Key = new Key("V", 86);
		public static const W					:Key = new Key("W", 87);
		public static const X					:Key = new Key("X", 88);
		public static const Y					:Key = new Key("Y", 89);
		public static const Z					:Key = new Key("Z", 90);
		
		// Function keys
		public static const F1					:Key = new Key("F1", 112);
		public static const F2					:Key = new Key("F2", 113);
		public static const F3					:Key = new Key("F3", 114);
		public static const F4					:Key = new Key("F4", 115);
		public static const F5					:Key = new Key("F5", 116);
		public static const F6					:Key = new Key("F6", 117);
		public static const F7					:Key = new Key("F7", 118);
		public static const F8					:Key = new Key("F8", 119);
		public static const F9					:Key = new Key("F9", 120);
		public static const F10					:Key = new Key("F10", 121);
		public static const F11					:Key = new Key("F11", 122);
		public static const F12					:Key = new Key("F12", 123);
		public static const F13					:Key = new Key("F13", 124);
		public static const F14					:Key = new Key("F14", 125);
		public static const F15					:Key = new Key("F15", 126);
		
		// Numpad keys
		public static const NUMPAD_0			:Key = new Key("Numpad_0", 96);
		public static const NUMPAD_1			:Key = new Key("Numpad_1", 97);
		public static const NUMPAD_2			:Key = new Key("Numpad_2", 98);
		public static const NUMPAD_3			:Key = new Key("Numpad_3", 99);
		public static const NUMPAD_4			:Key = new Key("Numpad_4", 100);
		public static const NUMPAD_5			:Key = new Key("Numpad_5", 101);
		public static const NUMPAD_6			:Key = new Key("Numpad_6", 102);
		public static const NUMPAD_7			:Key = new Key("Numpad_7", 103);
		public static const NUMPAD_8			:Key = new Key("Numpad_8", 104);
		public static const NUMPAD_9			:Key = new Key("Numpad_9", 105);
		public static const NUMPAD_MULTIPLY		:Key = new Key("Numpad_Multiply", 106, "*");
		public static const NUMPAD_ADD			:Key = new Key("Numpad_Add", 107, "+");
		public static const NUMPAD_ENTER		:Key = new Key("Numpad_Enter", 108);
		public static const NUMPAD_SUBTRACT		:Key = new Key("Numpad_Subtract", 109, "-");
		public static const NUMPAD_DECIMAL		:Key = new Key("Numpad_Decimal", 110, ".");
		public static const NUMPAD_DIVIDE		:Key = new Key("Numpad_Divide", 111, "/");
		
		public static const BACKSPACE			:Key = new Key("Backspace", 8);
		public static const TAB					:Key = new Key("Tab", 9);
		public static const ENTER				:Key = new Key("Enter", 13);
		public static const SHIFT				:Key = new Key("Shift", 16);
		public static const CONTROL				:Key = new Key("Ctrl", 17);
		public static const ALT					:Key = new Key("Alt", 18);
		public static const ESCAPE				:Key = new Key("Esc", 27);
		public static const SPACE				:Key = new Key("Space", 32);
		
		// Lock keys
		public static const CAPS_LOCK			:Key = new Key("Caps", 20);
		public static const NUM_LOCK			:Key = new Key("Num", 144);
		public static const SCROLL_LOCK			:Key = new Key("Scroll", 145);
		
		public static const PAUSE				:Key = new Key("Pause", 19);
		public static const PAGE_UP				:Key = new Key("PageUp", 33);
		public static const PAGE_DOWN			:Key = new Key("PageDown", 34);
		public static const END					:Key = new Key("End", 35);
		public static const HOME				:Key = new Key("Home", 36);
		public static const INSERT				:Key = new Key("Insert", 45);
		public static const DELETE				:Key = new Key("Delete", 46);
		
		// Arrow keys
		public static const LEFT				:Key = new Key("Left", 37);
		public static const UP					:Key = new Key("Up", 38);
		public static const RIGHT				:Key = new Key("Right", 39);
		public static const DOWN				:Key = new Key("Down", 40);
		
		// Windows keys
		public static const WINDOWS				:Key = new Key("Win", 91);
		public static const MENU				:Key = new Key("Menu", 93);
		
		public static const SEMICOLON			:Key = new Key("Semicolon", 186, ";");
		public static const EQUAL				:Key = new Key("Equal", 187, "=");
		public static const COMMA				:Key = new Key("Comma", 188, ",");
		public static const MINUS				:Key = new Key("Minus", 189, "-");
		public static const DOT					:Key = new Key("Dot", 190, ".");
		public static const SLASH				:Key = new Key("Slash", 191, "/");
		public static const GRAVE				:Key = new Key("Grave", 192, "`");
		
		public static const OPENBRACKET			:Key = new Key("Openbracket", 219, "[");
		public static const BACKSLASH			:Key = new Key("Backslash", 220, "\\");
		public static const CLOSEBRACKET		:Key = new Key("Closebracket", 221, "]");
		public static const QUOTE				:Key = new Key("Quote", 222, "'");
		
		// ---- static variables ----
		
		protected static var codemap				:Dictionary;
		
		// ---- getters & setters ----
		
		private var _description				:String;
		private var _code						:uint;
		private var _character					:String;
		
		public function get description():String {
			return _description;
		}
		
		public function get code():uint {
			return _code;
		}
		
		public function get character():String {
			return _character;
		}
		
		// ---- constructor ----
		
		public function Key(description:String, code:uint, character:String=null){
			// add to codemap by code (overwrites double entries)
			if (!codemap) codemap = new Dictionary();
			codemap[code] = this;
			
			_description = description;
			_code = code;
			_character = character;
		}
		
		public static function getKeyByCode(code:uint):Key {
			return Key.codemap[code];
		}
		
		public static function getKeyByDescription(description:String):Key {
			var key:Key;
			for each (key in codemap) {
				if (key.description == description) return key;
			}
			return null;
		}
		
		public static function getKeyByCharacter(character:String):Key {
			var key:Key;
			for each (key in codemap) {
				if (key.character != null && key.character == character) return key;
			}
			return getKeyByDescription(character);
		}
		
		public function toString():String{
			return "[Key "+description+"]";
		}
		
	}
}
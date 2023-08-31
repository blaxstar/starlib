package net.blaxstar.starlib.input {
	/**
	 * ...
	 * @author Deron Decamp
	 */
	public class KeyboardKeys {
		// keycode variable mapping
		public const NAMES:Vector.<String>  = new Vector.<String>(250);
		// letters
		public const A:uint                       = 65;
		public const B:uint                       = 66;
		public const C:uint                       = 67;
		public const D:uint                       = 68;
		public const E:uint                       = 69;
		public const F:uint                       = 70;
		public const G:uint                       = 71;
		public const H:uint                       = 72;
		public const I:uint                       = 73;
		public const J:uint                       = 74;
		public const K:uint                       = 75;
		public const L:uint                       = 76;
		public const M:uint                       = 77;
		public const N:uint                       = 78;
		public const O:uint                       = 79;
		public const P:uint                       = 80;
		public const Q:uint                       = 81;
		public const R:uint                       = 82;
		public const S:uint                       = 83;
		public const T:uint                       = 84;
		public const U:uint                       = 85;
		public const V:uint                       = 86;
		public const W:uint                       = 87;
		public const X:uint                       = 88;
		public const Y:uint                       = 89;
		public const Z:uint                       = 90;
		
		// (this doin) numbers
		public const ZERO:uint                    = 48;
		public const ONE:uint                     = 49;
		public const TWO:uint                     = 50;
		public const THREE:uint                   = 51;
		public const FOUR:uint                    = 52;
		public const FIVE:uint                    = 53;
		public const SIX:uint                     = 54;
		public const SEVEN:uint                   = 55;
		public const EIGHT:uint                   = 56;
		public const NINE:uint                    = 57;
		
		// numpad
		public const NUMPAD_0:uint                = 96;
		public const NUMPAD_1:uint                = 97;
		public const NUMPAD_2:uint                = 98;
		public const NUMPAD_3:uint                = 99;
		public const NUMPAD_4:uint                = 100;
		public const NUMPAD_5:uint                = 101;
		public const NUMPAD_6:uint                = 102;
		public const NUMPAD_7:uint                = 103;
		public const NUMPAD_8:uint                = 104;
		public const NUMPAD_9:uint                = 105;
		public const NUMPAD_MULTIPLY:uint         = 106;
		public const NUMPAD_ADD:uint              = 107;
		public const NUMPAD_ENTER:uint            = 108;
		public const NUMPAD_SUBTRACT:uint         = 109;
		public const NUMPAD_DECIMAL:uint          = 110;
		public const NUMPAD_DIVIDE:uint           = 111;
		
		// fn keys
		public const F1:uint                      = 112;
		public const F2:uint                      = 113;
		public const F3:uint                      = 114;
		public const F4:uint                      = 115;
		public const F5:uint                      = 116;
		public const F6:uint                      = 117;
		public const F7:uint                      = 118;
		public const F8:uint                      = 119;
		public const F9:uint                      = 120;
		public const F10:uint                     = 121;
		public const F11:uint                     = 122;
		public const F12:uint                     = 123;
		public const F13:uint                     = 124;
		public const F14:uint                     = 125;
		public const F15:uint                     = 126;
		
		// symbols
		public const COLON:uint                   = 186;
		public const EQUALS:uint                  = 187;
		public const UNDERSCORE:uint              = 189;
		public const QUESTION_MARK:uint           = 191;
		public const TILDE:uint                   = 192;
		public const OPEN_BRACKET:uint            = 219;
		public const BACKWARD_SLASH:uint          = 220;
		public const CLOSED_BRACKET:uint          = 221;
		public const QUOTES:uint                  = 222;
		public const LESS_THAN:uint               = 188;
		public const GREATER_THAN:uint            = 190;
		
		// others
		public const BACKSPACE:uint               = 8;
		public const TAB:uint                     = 9;
		public const CLEAR:uint                   = 12;
		public const ENTER:uint                   = 13;
		public const SHIFT:uint                   = 16;
		public const CONTROL:uint                 = 17;
		public const ALT:uint                     = 18;
		public const CAPS_LOCK:uint               = 20;
		public const ESC:uint                     = 27;
		public const SPACEBAR:uint                = 32;
		public const PAGE_UP:uint                 = 33;
		public const PAGE_DOWN:uint               = 34;
		public const END:uint                     = 35;
		public const HOME:uint                    = 36;
		public const LEFT:uint                    = 37;
		public const UP:uint                      = 38;
		public const RIGHT:uint                   = 39;
		public const DOWN:uint                    = 40;
		public const INSERT:uint                  = 45;
		public const DELETE:uint                  = 46;
		public const HELP:uint                    = 47;
		public const NUM_LOCK:uint                = 144;
		
		public function KeyboardKeys() {
			NAMES[A] = "A";
			NAMES[B] = "B";
			NAMES[C] = "C";
			NAMES[D] = "D";
			NAMES[E] = "E";
			NAMES[F] = "F";
			NAMES[G] = "G";
			NAMES[H] = "H";
			NAMES[I] = "I";
			NAMES[J] = "J";
			NAMES[K] = "K";
			NAMES[L] = "L";
			NAMES[M] = "M";
			NAMES[N] = "N";
			NAMES[O] = "O";
			NAMES[P] = "P";
			NAMES[Q] = "Q";
			NAMES[R] = "R";
			NAMES[S] = "S";
			NAMES[T] = "T";
			NAMES[U] = "U";
			NAMES[V] = "V";
			NAMES[W] = "W";
			NAMES[X] = "X";
			NAMES[Y] = "Y";
			NAMES[Z] = "Z";

			// numbers
			NAMES[ZERO] = "0";
			NAMES[ONE] = "1";
			NAMES[TWO] = "2";
			NAMES[THREE] = "3";
			NAMES[FOUR] = "4";
			NAMES[FIVE] = "5";
			NAMES[SIX] = "6";
			NAMES[SEVEN] = "7";
			NAMES[EIGHT] = "8";
			NAMES[NINE] = "9";

			// numpad
			NAMES[NUMPAD_0] = "0";
			NAMES[NUMPAD_1] = "1";
			NAMES[NUMPAD_2] = "2";
			NAMES[NUMPAD_3] = "3";
			NAMES[NUMPAD_4] = "4";
			NAMES[NUMPAD_5] = "5";
			NAMES[NUMPAD_6] = "6";
			NAMES[NUMPAD_7] = "7";
			NAMES[NUMPAD_8] = "8";
			NAMES[NUMPAD_9] = "9";
			NAMES[NUMPAD_MULTIPLY] = "Numpad multiply";
			NAMES[NUMPAD_ADD] = "Numpad add";
			NAMES[NUMPAD_ENTER] = "Numpad enter";
			NAMES[NUMPAD_SUBTRACT] = "Numpad subtract";
			NAMES[NUMPAD_DECIMAL] = "Numpad decimal";
			NAMES[NUMPAD_DIVIDE] = "Numpad divide";

			// fn keys
			NAMES[F1] = "F1";
			NAMES[F2] = "F2";
			NAMES[F3] = "F3";
			NAMES[F4] = "F4";
			NAMES[F5] = "F5";
			NAMES[F6] = "F6";
			NAMES[F7] = "F7";
			NAMES[F8] = "F8";
			NAMES[F9] = "F9";
			NAMES[F10] = "F10";
			NAMES[F11] = "F11";
			NAMES[F12] = "F12";
			NAMES[F13] = "F13";
			NAMES[F14] = "F14";
			NAMES[F15] = "F15";

			// symbols
			NAMES[COLON] = ":";
			NAMES[EQUALS] = "=";
			NAMES[UNDERSCORE] = "_";
			NAMES[QUESTION_MARK] = "?";
			NAMES[TILDE] = "~";
			NAMES[OPEN_BRACKET] = "[";
			NAMES[BACKWARD_SLASH] = "\\";
			NAMES[CLOSED_BRACKET] = "]";
			NAMES[QUOTES] = "\"";
			NAMES[LESS_THAN] = "<";
			NAMES[GREATER_THAN] = ">";

			// others
			NAMES[BACKSPACE] = "Backspace";
			NAMES[TAB] = "Tab";
			NAMES[CLEAR] = "Clear";
			NAMES[ENTER] = "Enter";
			NAMES[SHIFT] = "Shift";
			NAMES[CONTROL] = "CTRL";
			NAMES[ALT] = "ALT";
			NAMES[CAPS_LOCK] = "Caps Lock";
			NAMES[ESC] = "Esc";
			NAMES[SPACEBAR] = "Spacebar";
			NAMES[PAGE_UP] = "Page Up";
			NAMES[PAGE_DOWN] = "Page Down";
			NAMES[END] = "End";
			NAMES[HOME] = "Home";
			NAMES[LEFT] = "Left Arrow";
			NAMES[UP] = "Up Arrow";
			NAMES[RIGHT] = "Right Arrow";
			NAMES[DOWN] = "Down Arrow";
			NAMES[INSERT] = "Insert";
			NAMES[DELETE] = "Delete";
			NAMES[HELP] = "Help";
			NAMES[NUM_LOCK] = "Num Lock";
		}
		
	}

}
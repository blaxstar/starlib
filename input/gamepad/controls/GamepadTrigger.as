package net.blaxstar.starlib.input.gamepad.controls {
import flash.ui.GameInputControl;

import net.blaxstar.starlib.input.gamepad.types.Gamepad;

public class GamepadTrigger extends GamepadButton {
		public function GamepadTrigger(device:Gamepad, control:GameInputControl) {
			super(device, control);
		}
		
		public function get distance():Number {
			return value;
		}
	}
}

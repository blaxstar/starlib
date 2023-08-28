package net.blaxstar.input.gamepad.controls {
import flash.ui.GameInputControl;

import net.blaxstar.input.gamepad.types.Gamepad;

public class GamepadDPadButton {
		public var up:GamepadButton;
		public var down:GamepadButton;
		public var left:GamepadButton;
		public var right:GamepadButton;
		
		public function GamepadDPadButton(device:Gamepad, up:GameInputControl, down:GameInputControl, left:GameInputControl, right:GameInputControl) {
			this.up = new GamepadButton(device, up);
			this.down = new GamepadButton(device, down);
			this.left = new GamepadButton(device, left);
			this.right = new GamepadButton(device, right);
		}
		
		public function reset():void {
			up.reset();
			down.reset();
			left.reset();
			right.reset();
		}
	}
}

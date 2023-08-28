package net.blaxstar.input.gamepad.controls {
import flash.ui.GameInputControl;

import net.blaxstar.input.gamepad.types.Gamepad;

public class GamepadJoystick extends GamepadButton {
		private static const JOYSTICK_THRESHOLD:Number = 0.5;
		
		private var xAxis:GameControl;
		private var yAxis:GameControl;
		
		public var left:GamepadButton;
		public var right:GamepadButton;
		public var up:GamepadButton;
		public var down:GamepadButton;
		
		private var reversedY:Boolean;
		
		public function GamepadJoystick(device:Gamepad, xAxis:GameInputControl, yAxis:GameInputControl, joystickButton:GameInputControl, reversedY:Boolean = false) {
			super(device, joystickButton);
			
			this.xAxis = new GameControl(device, xAxis);
			this.yAxis = new GameControl(device, yAxis);
			
			this.left = new GamepadButton(device, xAxis, -1, -JOYSTICK_THRESHOLD);
			this.right = new GamepadButton(device, xAxis, JOYSTICK_THRESHOLD, 1);
			
			if (reversedY) {
				this.down = new GamepadButton(device, yAxis, JOYSTICK_THRESHOLD, 1);
				this.up = new GamepadButton(device, yAxis, -1, -JOYSTICK_THRESHOLD);
			} else {
				this.up = new GamepadButton(device, yAxis, JOYSTICK_THRESHOLD, 1);
				this.down = new GamepadButton(device, yAxis, -1, -JOYSTICK_THRESHOLD);
			}
			
			this.reversedY = reversedY;
		}
		
		public function get x():Number {
			return xAxis.value;
		}
		
		public function get y():Number {
			return reversedY ? -yAxis.value : yAxis.value;
		}
		
		/**
		 * Returns the angle of the joystick in radians.
		 *
		 * @return The rotation of the joystick in radians.
		 */
		public function get angle():Number {
			return Math.atan2(y, x);
		}
		
		/**
		 * Returns a flash-friendly value for this stick's position in degrees.
		 *
		 * @return The rotation of the joystick in degrees.
		 */
		public function get rotation():Number {
			return (Math.atan2(-y, x) + (Math.PI / 2)) * 180 / Math.PI;
		}
		
		public function get distance():Number {
			return Math.min(1, Math.sqrt(x * x + y * y));
		}
	}
}

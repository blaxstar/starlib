package net.blaxstar.starlib.input.gamepad.controls {
import flash.ui.GameInputControl;

import net.blaxstar.starlib.input.gamepad.types.Gamepad;

public class GamepadJoystick extends GamepadButton {
		private static const JOYSTICK_THRESHOLD:Number = 0.5;
		
		private var _x_axis:GameControl;
		private var _y_axis:GameControl;
		
		public var left:GamepadButton;
		public var right:GamepadButton;
		public var up:GamepadButton;
		public var down:GamepadButton;
		
		private var _y_axis_is_reversed:Boolean;
		
		public function GamepadJoystick(device:Gamepad, x_axis:GameInputControl, y_axis:GameInputControl, joystick_button:GameInputControl, reverse_y_axis:Boolean = false) {
			super(device, joystick_button);
			
			this._x_axis = new GameControl(device, x_axis);
			this._y_axis = new GameControl(device, y_axis);
			
			this.left = new GamepadButton(device, x_axis, -1, -JOYSTICK_THRESHOLD);
			this.right = new GamepadButton(device, x_axis, JOYSTICK_THRESHOLD, 1);
			
			if (reverse_y_axis) {
				this.down = new GamepadButton(device, y_axis, JOYSTICK_THRESHOLD, 1);
				this.up = new GamepadButton(device, y_axis, -1, -JOYSTICK_THRESHOLD);
			} else {
				this.up = new GamepadButton(device, y_axis, JOYSTICK_THRESHOLD, 1);
				this.down = new GamepadButton(device, y_axis, -1, -JOYSTICK_THRESHOLD);
			}
			
			this._y_axis_is_reversed = reverse_y_axis;
		}
		
		public function get x():Number {
			return _x_axis.value;
		}
		
		public function get y():Number {
			return _y_axis_is_reversed ? -_y_axis.value : _y_axis.value;
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

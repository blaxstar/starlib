package net.blaxstar.input.gamepad.types {
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;

import net.blaxstar.input.gamepad.controls.GamepadButton;
import net.blaxstar.input.gamepad.controls.GamepadDPadButton;
import net.blaxstar.input.gamepad.controls.GamepadJoystick;
import net.blaxstar.input.gamepad.controls.GamepadTrigger;

/**
	 * A class containing the bindings for a single Ouya controller.
	 */
	public class OuyaGamepad extends Gamepad {
		/** The O face button. */
		public var o:GamepadButton;
		/** The U face button. */
		public var u:GamepadButton;
		/** The Y face button. */
		public var y:GamepadButton;
		/** The A face button. */
		public var a:GamepadButton;
		/** Left shoulder button. */
		public var lb:GamepadButton;
		/** Left shoulder trigger. */
		public var lt:GamepadTrigger;
		/** Left joystick. */
		public var leftStick:GamepadJoystick;
		/** Right shoulder button. */
		public var rb:GamepadButton;
		/** Right shoulder trigger. */
		public var rt:GamepadTrigger;
		/** Right joystick. */
		public var rightStick:GamepadJoystick;
		
		/** Directional pad. */
		public var dpad:GamepadDPadButton;
		
		/** Creates a new Ouya controller */
		public function OuyaGamepad(device:GameInputDevice) {
			_type = GamepadType.OUYA;
			super(device);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function bindControls():void {
			var controlMap:Object = {};
			for (var i:uint = 0; i < device.numControls; i++) {
				var control:GameInputControl = device.getControlAt(i);
				controlMap[control.id] = control;
			}
			
			if (controlMap['BUTTON_100'] != null) {
				// Bindings on Ouya
				o = new GamepadButton(this, controlMap['BUTTON_96']);
				u = new GamepadButton(this, controlMap['BUTTON_99']);
				y = new GamepadButton(this, controlMap['BUTTON_100']);
				a = new GamepadButton(this, controlMap['BUTTON_97']);
				
				lb = new GamepadButton(this, controlMap['BUTTON_102']);
				rb = new GamepadButton(this, controlMap['BUTTON_103']);
				lt = new GamepadTrigger(this, controlMap['BUTTON_104']);
				rt = new GamepadTrigger(this, controlMap['BUTTON_105']);
				
				leftStick = new GamepadJoystick(this, controlMap['AXIS_0'], controlMap['AXIS_1'], controlMap['BUTTON_106'], true);
				rightStick = new GamepadJoystick(this, controlMap['AXIS_11'], controlMap['AXIS_14'], controlMap['BUTTON_107'], true);
				
				dpad = new GamepadDPadButton(this, controlMap['BUTTON_19'], controlMap['BUTTON_20'], controlMap['BUTTON_21'], controlMap['BUTTON_22']);
			} else {
				// Bindings on PC
				o = new GamepadButton(this, controlMap['BUTTON_6']);
				u = new GamepadButton(this, controlMap['BUTTON_7']);
				y = new GamepadButton(this, controlMap['BUTTON_8']);
				a = new GamepadButton(this, controlMap['BUTTON_9']);
				
				lb = new GamepadButton(this, controlMap['BUTTON_10']);
				rb = new GamepadButton(this, controlMap['BUTTON_11']);
				lt = new GamepadTrigger(this, controlMap['BUTTON_18']);
				rt = new GamepadTrigger(this, controlMap['BUTTON_19']);
				
				leftStick = new GamepadJoystick(this, controlMap['AXIS_0'], controlMap['AXIS_1'], controlMap['BUTTON_12'], true);
				rightStick = new GamepadJoystick(this, controlMap['AXIS_3'], controlMap['AXIS_4'], controlMap['BUTTON_13'], true);
				
				dpad = new GamepadDPadButton(this, controlMap['BUTTON_14'], controlMap['BUTTON_15'], controlMap['BUTTON_16'], controlMap['BUTTON_17']);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function reset():void {
			a.reset();
			o.reset();
			y.reset();
			a.reset();
			lb.reset();
			rb.reset();
			lt.reset();
			rt.reset();
			leftStick.reset();
			rightStick.reset();
			dpad.reset();
		}
	}
}

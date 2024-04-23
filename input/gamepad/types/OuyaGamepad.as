package net.blaxstar.starlib.input.gamepad.types {
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;

import net.blaxstar.starlib.input.gamepad.controls.GamepadButton;
import net.blaxstar.starlib.input.gamepad.controls.GamepadDPadButton;
import net.blaxstar.starlib.input.gamepad.controls.GamepadJoystick;
import net.blaxstar.starlib.input.gamepad.controls.GamepadTrigger;
import flash.utils.Dictionary;

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
		public var left_stick:GamepadJoystick;
		/** Right shoulder button. */
		public var rb:GamepadButton;
		/** Right shoulder trigger. */
		public var rt:GamepadTrigger;
		/** Right joystick. */
		public var right_stick:GamepadJoystick;
		
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
		override protected function bind_controls():void {
			var control_map:Dictionary = new Dictionary();
			for (var i:uint = 0; i < device.numControls; i++) {
				var control:GameInputControl = device.getControlAt(i);
				control_map[control.id] = control;
			}
			
			if (control_map['BUTTON_100'] != null) {
				// Bindings on Ouya
				o = new GamepadButton(this, control_map['BUTTON_96']);
				u = new GamepadButton(this, control_map['BUTTON_99']);
				y = new GamepadButton(this, control_map['BUTTON_100']);
				a = new GamepadButton(this, control_map['BUTTON_97']);
				
				lb = new GamepadButton(this, control_map['BUTTON_102']);
				rb = new GamepadButton(this, control_map['BUTTON_103']);
				lt = new GamepadTrigger(this, control_map['BUTTON_104']);
				rt = new GamepadTrigger(this, control_map['BUTTON_105']);
				
				left_stick = new GamepadJoystick(this, control_map['AXIS_0'], control_map['AXIS_1'], control_map['BUTTON_106'], true);
				right_stick = new GamepadJoystick(this, control_map['AXIS_11'], control_map['AXIS_14'], control_map['BUTTON_107'], true);
				
				dpad = new GamepadDPadButton(this, control_map['BUTTON_19'], control_map['BUTTON_20'], control_map['BUTTON_21'], control_map['BUTTON_22']);
			} else {
				// Bindings on PC
				o = new GamepadButton(this, control_map['BUTTON_6']);
				u = new GamepadButton(this, control_map['BUTTON_7']);
				y = new GamepadButton(this, control_map['BUTTON_8']);
				a = new GamepadButton(this, control_map['BUTTON_9']);
				
				lb = new GamepadButton(this, control_map['BUTTON_10']);
				rb = new GamepadButton(this, control_map['BUTTON_11']);
				lt = new GamepadTrigger(this, control_map['BUTTON_18']);
				rt = new GamepadTrigger(this, control_map['BUTTON_19']);
				
				left_stick = new GamepadJoystick(this, control_map['AXIS_0'], control_map['AXIS_1'], control_map['BUTTON_12'], true);
				right_stick = new GamepadJoystick(this, control_map['AXIS_3'], control_map['AXIS_4'], control_map['BUTTON_13'], true);
				
				dpad = new GamepadDPadButton(this, control_map['BUTTON_14'], control_map['BUTTON_15'], control_map['BUTTON_16'], control_map['BUTTON_17']);
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
			left_stick.reset();
			right_stick.reset();
			dpad.reset();
		}
	}
}

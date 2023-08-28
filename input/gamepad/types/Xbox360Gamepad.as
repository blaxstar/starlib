package net.blaxstar.input.gamepad.types {
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;
import flash.utils.Dictionary;

import net.blaxstar.input.gamepad.controls.GamepadButton;
import net.blaxstar.input.gamepad.controls.GamepadDPadButton;
import net.blaxstar.input.gamepad.controls.GamepadJoystick;
import net.blaxstar.input.gamepad.controls.GamepadTrigger;

/** a class containing the bindings for a single Xbox 360 controller. */
	public class Xbox360Gamepad extends Gamepad {
		/** the A face button. */
		public var a:GamepadButton;
		/** the B face button. */
		public var b:GamepadButton;
		/** the X face button. */
		public var x:GamepadButton;
		/** the Y face button. */
		public var y:GamepadButton;
		/** left shoulder button. */
		public var lb:GamepadButton;
		/** left shoulder trigger. */
		public var lt:GamepadTrigger;
		/** left joystick. */
		public var leftStick:GamepadJoystick;
		/** right shoulder button. */
		public var rb:GamepadButton;
		/** right shoulder trigger. */
		public var rt:GamepadTrigger;
		/** right joystick. */
		public var rightStick:GamepadJoystick;
		/** directional pad. */
		public var dpad:GamepadDPadButton;
		
		public var back:GamepadButton;
		public var start:GamepadButton;
		
		public function Xbox360Gamepad(device:GameInputDevice) {
			_type = GamepadType.XBOX;
			super(device);
		}
		
		override protected function bindControls():void {
			var controlMap:Dictionary = new Dictionary();
			for (var i:uint = 0; i < device.numControls; i++) {
				var control:GameInputControl = device.getControlAt(i);
				controlMap[control.id] = control;
			}
			
			a = new GamepadButton(this, controlMap['BUTTON_4']);
			b = new GamepadButton(this, controlMap['BUTTON_5']);
			x = new GamepadButton(this, controlMap['BUTTON_6']);
			y = new GamepadButton(this, controlMap['BUTTON_7']);
			
			lb = new GamepadButton(this, controlMap['BUTTON_8']);
			rb = new GamepadButton(this, controlMap['BUTTON_9']);
			lt = new GamepadTrigger(this, controlMap['BUTTON_10']);
			rt = new GamepadTrigger(this, controlMap['BUTTON_11']);
			
			leftStick = new GamepadJoystick(this, controlMap['AXIS_0'], controlMap['AXIS_1'], controlMap['BUTTON_14']);
			rightStick = new GamepadJoystick(this, controlMap['AXIS_2'], controlMap['AXIS_3'], controlMap['BUTTON_15']);
			
			dpad = new GamepadDPadButton(this, controlMap['BUTTON_16'], controlMap['BUTTON_17'], controlMap['BUTTON_18'], controlMap['BUTTON_19']);
			
			back = new GamepadButton(this, controlMap['BUTTON_12']);
			start = new GamepadButton(this, controlMap['BUTTON_13']);
		}
		
		override public function reset():void {
			a.reset();
			b.reset();
			x.reset();
			y.reset();
			lb.reset();
			rb.reset();
			lt.reset();
			rt.reset();
			leftStick.reset();
			rightStick.reset();
			dpad.reset();
			back.reset();
			start.reset();
		}
	}
}

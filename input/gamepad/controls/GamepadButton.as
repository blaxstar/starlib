package net.blaxstar.starlib.input.gamepad.controls {
import flash.events.Event;
import flash.ui.GameInputControl;

import net.blaxstar.starlib.input.gamepad.GamepadBus;
import net.blaxstar.starlib.input.gamepad.types.Gamepad;

public class GamepadButton extends GameControl {
		private var changed:Boolean = false;
		private var minimum:Number;
		private var maximum:Number;
		
		public function GamepadButton(device:Gamepad, control:GameInputControl, minimum:Number = 0.5, maximum:Number = 1) {
			super(device, control);
			this.minimum = minimum;
			this.maximum = maximum;
		}
		
		public function get pressed():Boolean {
			return updatedAt >= GamepadBus.previous && held && changed;
		}
		
		public function get released():Boolean {
			return updatedAt >= GamepadBus.previous && !held && changed;
		}
		
		public function get held():Boolean {
			return value >= minimum && value <= maximum;
		}
		
		override protected function onChange(event:Event):void {
			var beforeHeld:Boolean = held;
			super.onChange(event);
			changed = held != beforeHeld;
		}
	}
}

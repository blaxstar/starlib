package net.blaxstar.input.gamepad.controls {
import flash.events.Event;
import flash.ui.GameInputControl;

import net.blaxstar.input.gamepad.GamepadBus;
import net.blaxstar.input.gamepad.types.Gamepad;

public class GameControl {
		private var _parentGamepad:Gamepad;
		private var _hardwareControl:GameInputControl;
		
		public var value:Number   = 0;
		public var updatedAt:uint = 0;
		
		public function GameControl(device:Gamepad, control:GameInputControl) {
			this._parentGamepad = device;
			this._hardwareControl = control;
			
			if (control != null) {
				this._hardwareControl.addEventListener(Event.CHANGE, onChange);
			}
		}
		
		public function reset():void {
			value = 0;
			updatedAt = 0;
		}
		
		protected function onChange(event:Event):void {
			value = (event.target as GameInputControl).value;
			updatedAt = GamepadBus.now;
		}
	}
}

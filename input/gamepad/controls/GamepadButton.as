package net.blaxstar.starlib.input.gamepad.controls {
    import flash.events.Event;
    import flash.ui.GameInputControl;

    import net.blaxstar.starlib.input.gamepad.GamepadBus;
    import net.blaxstar.starlib.input.gamepad.types.Gamepad;

    public class GamepadButton extends GameControl {
        private var _changed:Boolean = false;
        private var _minimum:Number;
        private var _maximum:Number;

        public function GamepadButton(device:Gamepad, device_input:GameInputControl, minimum:Number = 0.5, maximum:Number = 1) {
            super(device, device_input);
            this._minimum = minimum;
            this._maximum = maximum;
        }

        public function get pressed():Boolean {
            return update_time >= GamepadBus.previous && held && _changed;
        }

        public function get released():Boolean {
            return update_time >= GamepadBus.previous && !held && _changed;
        }

        public function get held():Boolean {
            return value >= _minimum && value <= _maximum;
        }

        override protected function on_controller_status_change(event:Event):void {
            var previous_input_status:Boolean = held;
            super.on_controller_status_change(event);
            _changed = held != previous_input_status;
        }
    }
}

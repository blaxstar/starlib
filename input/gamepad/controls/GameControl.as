package net.blaxstar.starlib.input.gamepad.controls {
    import flash.events.Event;
    import flash.ui.GameInputControl;

    import net.blaxstar.starlib.input.gamepad.GamepadBus;
    import net.blaxstar.starlib.input.gamepad.types.Gamepad;

    public class GameControl {
        private var _parent_gamepad:Gamepad;
        private var _hardware_control:GameInputControl;

        public var value:Number = 0;
        public var update_time:uint = 0;

        public function GameControl(device:Gamepad, device_input:GameInputControl) {
            this._parent_gamepad = device;
            this._hardware_control = device_input;

            if (device_input != null) {
                this._hardware_control.addEventListener(Event.CHANGE, on_controller_status_change);
            }
        }

        public function reset():void {
            value = 0;
            update_time = 0;
        }

        protected function on_controller_status_change(event:Event):void {
            value = (event.target as GameInputControl).value;
            update_time = GamepadBus.now;
        }
    }
}

package net.blaxstar.starlib.input.gamepad {
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.GameInputEvent;
    import flash.events.KeyboardEvent;
    import flash.ui.GameInput;
    import flash.ui.GameInputDevice;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;

    import net.blaxstar.starlib.input.gamepad.types.Gamepad;
    import net.blaxstar.starlib.input.gamepad.types.OuyaGamepad;
    import net.blaxstar.starlib.input.gamepad.types.Xbox360Gamepad;

    /**
     * A class for reading input from controllers. Allows you to pull ready controllers from a queue of controllers that have been initialized, to allow input from as many controllers as you need.
     */
    public class GamepadBus {
        public static var controllers:Vector.<Gamepad> = new Vector.<Gamepad>;
        public static var ready_controllers:Vector.<Gamepad> = new Vector.<Gamepad>;
        public static var removed_controllers:Vector.<Gamepad> = new Vector.<Gamepad>;
        public static var is_initialized:Boolean = false;
        public static var now:uint = getTimer();
        public static var previous:uint = now;

        private static var _custom_listener:Function;
        private static var _game_input:GameInput;

        /**
         * Initializes the library, adding event listeners as needed. The passed stage is used to add event listeners for entering frame and for keyboard events.
         *
         * @param stage A reference to the root flash stage.
         */
        public static function initialize(stage:DisplayObject, gamepadConnectListener:Function = null):void {
            _game_input = new GameInput;
            _game_input.addEventListener(GameInputEvent.DEVICE_ADDED, on_device_attached);
            if (gamepadConnectListener != null)
                _custom_listener = gamepadConnectListener;
            _game_input.addEventListener(GameInputEvent.DEVICE_REMOVED, on_device_detached);

            stage.addEventListener(Event.ENTER_FRAME, on_enter_frame);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, on_key_down);

            for (var i:uint = 0; i < GameInput.numDevices; i++) {
                attach(GameInput.getDeviceAt(i));
            }
            is_initialized = true;
        }

        /**
         * Returns the active controller with the passed index.
         *
         * @param index The index of the controller to grab.
         * @return An active controller.
         */
        public static function controller(index:uint):Gamepad {
            return controllers[index];
        }

        /**
         * Returns the number of active controllers that are connected and taking input.
         *
         * @return The number of active controllers.
         */
        public static function num_total_controllers():uint {
            return controllers.length;
        }

        /**
         * Returns the number of ready controllers that are connected, but are not yet active. Use getReadyController() in order to get a ready controller and make it active.
         *
         * @return The number of ready controllers.
         */
        public static function num_ready_controllers():uint {
            return ready_controllers.length;
        }

        /**
         * Returns whether or not there is a controller that is ready to be polled for input.
         *
         * @return Whether there is a ready controller or not.
         */
        public static function has_ready_controller():Boolean {
            return ready_controllers.length > 0;
        }

        /**
         * Returns a ready controller and activates it (allowing it to be polled for input). This moves the controller from the "ready controllers" queue to the list of active "controllers".
         *
         * @return The controller, now in a ready state.
         */
        public static function get_ready_controller():Gamepad {
            var readyController:Gamepad = ready_controllers.shift();
            readyController.enable();
            controllers.push(readyController);
            return readyController;
        }

        /**
         * Returns whether or not one of the currently used controllers has been disconnected. You can check this queue in order to handle this case gracefully. Also, you can check if the "removed" property
         * of the controller is true, which also signifies that the controller has been detached from the system and can no longer be read for input.
         *
         * @return Whether or not there is a detached controller.
         */
        public static function has_removed_controller():Boolean {
            return removed_controllers.length > 0;
        }

        /**
         * Similar to reading a newly ready controller, this allows you to read a removed controller and handle it however you'd like.
         *
         * @return The removed controller.
         */
        public static function get_removed_controller():Gamepad {
            var removedController:Gamepad = removed_controllers.shift();
            removedController.disable();
            return removedController;
        }

        /**
         * Callback when a device is attached.
         *
         * @param event The GameInputEvent containing the attached deviced.
         */
        private static function on_device_attached(event:GameInputEvent):void {
            attach(event.device);
        }

        /**
         * Attaches a game device by creating a class that corresponds to the device type and adding it to the ready controllers list.
         */
        private static function attach(device:GameInputDevice):void {
            if (device == null) {
                return;
            }
            var controllerClass:Class = parse_controller_type(device.name);
            if (controllerClass == null) {
                // Unknown device
                return;
            }
            ready_controllers.push(new controllerClass(device));
            _custom_listener();
        }

        /**
         * Callback when a device is detached.
         *
         * @param event The GameInputEvent containing the detached deviced.
         */
        private static function on_device_detached(event:GameInputEvent):void {
            detach(event.device);
        }

        /**
         * Detaches a device by setting the removed attribute to true, removing it from the controllers list, and adding to the removed controllers list.
         */
        private static function detach(device:GameInputDevice):void {
            if (device == null) {
                return;
            }
            var detachedController:Gamepad = find_and_remove_device(controllers, device) || find_and_remove_device(ready_controllers, device);
            if (detachedController == null) {
                return;
            }
            detachedController.remove();
            removed_controllers.push(detachedController);
        }

        /**
         * Helper method that takes a group and a target device, removes the device from the group and returns it. If the controller was not present in the group, returns null instead.
         *
         * @param source The group to remove the controller from.
         * @param target The game input device to remove and return.
         * @return The removed controller corresponding to the device, or null if it wasn't present.
         */
        private static function find_and_remove_device(source:Vector.<Gamepad>, target:GameInputDevice):Gamepad {
            var result:Gamepad = null;
            for each (var controller:Gamepad in source) {
                if (controller.device == target) {
                    result = controller;
                    break;
                }
            }

            if (result != null) {
                source.splice(source.indexOf(result), 1);
                return result;
            }

            return null;
        }

        /**
         * Sets up timers on enter frame in order to keep track of whether a button is pressed or held.
         *
         * @param event The enter frame event.
         */
        private static function on_enter_frame(event:Event):void {
            previous = now;
            now = getTimer();
        }

        /**
         * Given the name of a device, returns the supported class for that device. If the device isn't supported by AS3 Controller Input, returns null.
         *
         * @param name The name of the device.
         * @return The controller class corresponding to the device name.
         */
        private static function parse_controller_type(name:String):Class {
            if (name.toLowerCase().indexOf("xbox 360") != -1) {
                return Xbox360Gamepad;
            } else if (name.toLowerCase().indexOf("ouya") != -1) {
                return OuyaGamepad;
            }

            return null;
        }

        /**
         * Callback for keyboard events that catches the back and escape keys so that stupid bindings don't exit the application.
         *
         * @param event The keyboard event.
         */
        private static function on_key_down(event:KeyboardEvent):void {
            if (event.keyCode == 27 || event.keyCode == Keyboard.BACK) {
                event.preventDefault();
            }
        }
    }
}

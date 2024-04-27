package net.blaxstar.starlib.input {
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;

    import net.blaxstar.starlib.debug.DebugDaemon;
    import net.blaxstar.starlib.input.gamepad.GamepadBus;
    import net.blaxstar.starlib.input.gamepad.types.Gamepad;
    import net.blaxstar.starlib.input.gamepad.types.GamepadType;
    import net.blaxstar.starlib.input.gamepad.types.OuyaGamepad;
    import net.blaxstar.starlib.input.gamepad.types.Xbox360Gamepad;
    import flash.events.IEventDispatcher;
    import flash.events.TextEvent;

    /**
     * Enumerated type holding all the key code values and their names.
     * @author Deron Decamp	(decamp.deron@gmail.com)
     *
     */
    public class InputEngine extends Sprite {
        // const
        static public const KEYUP:uint = 0;
        static public const KEYDOWN:uint = 1;
        static private const _KEYS:KeyboardKeys = new KeyboardKeys();

        // static
        static private var _key_states:Vector.<uint> = new Vector.<uint>(250);
        static private var _gamepads:Vector.<Gamepad> = new Vector.<Gamepad>(4);
        static private var _pending_actions:Array;
        static private var _left_mouse_state:uint;
        static private var _right_mouse_state:uint;
        static private var _scroll_button_state:uint;
        static private var _scroll_delta:int;
        static private var _init_names:Boolean;
        static private var _keyboard_initialized:Boolean;
        static private var _mouse_initialized:Boolean;
        static private var _gamepad_initialized:Boolean;
        static private var _instance:InputEngine;

        // * CONSTRUCTOR * /////////////////////////////////////////////////////////
        /**
         * instantiates a logical engine for handling user input (keyboard, gamepad, mouse).
         * @param stage a `Stage` object, which references the main stage. this allows for input processing from anywhere in the current native window.
         * @param init_keyboard boolean value to initialize keyboard input listeners.
         * @param init_mouse boolean value to initialize mouse input listeners.
         * @param init_gamepad boolean value to initialize gamepad input listeners.
         */
        public function InputEngine(stage:Stage = null, init_keyboard:Boolean = false, init_mouse:Boolean = false, init_gamepad:Boolean = false) {
            if (!_instance) {
                super();
                if (stage) {
                    stage.addChild(this);
                    init(stage, init_keyboard, init_mouse, init_gamepad);
                }
                _instance = this;
            } else {
              DebugDaemon.write_error("input engine is a singleton, please use InputEngine.instance()!");
            }
        }

        static public function instance():InputEngine {
            if (!_instance) {
                _instance = new InputEngine();
            }
            return _instance;
        }

        // * PUBLIC * //////////////////////////////////////////////////////////////

        /**
         * initializes listeners on the stage for input events.
         * NOTE: instantiating this class with the constructor and a non-null stage
         * will result in an automatic call to this method. this method is mainly
         * for dependency injection.
         * @param stage
         * @param init_keyboard boolean value to initialize keyboard input listeners.
         * @param init_mouse boolean value to initialize mouse input listeners.
         * @param init_gamepad boolean value to initialize gamepad input listeners.
         */
        public function init(stage:Stage, init_keyboard:Boolean = false, init_mouse:Boolean = false, init_gamepad:Boolean = false):void {
            // the stage is needed for these listeners, so if it hasn't been instantiated yet, then return
            if (!stage) {
                return;
            }
            // if none of the init flags are set, then there's no point
            if (init_keyboard == init_mouse == init_gamepad == false) {
                return;
            }

            // conditionally activate listeners based on the flags, we won't always want all of them simultaneously
            if (init_keyboard) {
                this.init_keyboard();
            }

            if (init_mouse) {
                this.init_mouse();
            }

            if (init_gamepad) {
                this.init_gamepad();
            }
        }

        /**
         * returns the controller that corresponds to `player_id`. if the referenced gamepad is not found, this returns null.
         * @param player_id the controller's id.
         * @return a gamepad object for managing a specific controller if found; null otherwise.
         */
        public function get_controller(player_id:uint):Gamepad {
            // first check the number of gamepads available
            var controllers:uint = num_controllers();
            // if there are none connected (or detected by the system)...
            if (controllers > 0) {
                // and the controller with the referenced id doesn't exist...
                if (player_id > controllers) {
                    // then just throw an error.
                    DebugDaemon.write_warning("controller #%s not detected!", player_id);
                    return null;
                } else {
                    // otherwise, return the gamepad at the referenced index.
                    // TODO: might need to wildcard the return type.
                    var gp:Gamepad = _gamepads[player_id];
                    if (gp.type == GamepadType.OUYA) {
                        return gp as OuyaGamepad;
                    } else if (gp.type == GamepadType.XBOX_360) {
                        return gp as Xbox360Gamepad;
                    }
                }
            } else {
                // otherwise
                trace("no gamepads found!");
                init_gamepad();
            }
            return null;
        }

        /**
         * get the number of game controllers connected to the current machine.
         * @return
         */
        public function num_controllers():uint {
            if (!_gamepad_initialized || !_gamepads.length < 1) {
                return 0;
            }
            return _gamepads.length;
        }

        /**
         * returns the name of a key, given the keycode.
         * @param key the keycode to perform a name lookup on.
         * @return name of the key referenced by `key`.
         */
        public function get_key_name(key:Number):String {
            // key codes 0-7 are reserved and do not represent any physical keys on a typical keyboard.
            if (key <= 7 || !_KEYS.NAMES[key])
                return "NONE";
            return _KEYS.NAMES[key];
        }

        /**
         * checks if a modifier key is being pressed on the keyboard (CTRL, ALT, or SHIFT).
         * @return boolean value indicating if a mod key is down.
         */
        public function mod_is_down():Boolean {
            return (key_is_down(_KEYS.CONTROL) || key_is_down(_KEYS.ALT) || key_is_down(_KEYS.SHIFT));
        }

        /**
         * checks if a key is currently being pressed on the keyboard.
         * @param keyCode value of the key to check.
         * @return boolean value indicating if the key is being pressed.
         */
        public function key_is_down(keyCode:uint):Boolean {
            // dont bother checking if the keyboard listeners are not initialized, just initialize the keyboard, write a debug message, and return false
            if (!_keyboard_initialized) {
                init_keyboard();
                DebugDaemon.write_log("the keyboard is not yet initialized! initializing keyboard.", DebugDaemon.WARN);
                return false;
            }
            // otherwise return the state of the key with the specified keycode
            return _key_states[keyCode] == 1;
        }

        /**
         * adds a mouse listener to the main stage.
         * @param listener_type the string name of the type of listener to add.
         * @param delegate the delegate function to fire when the listener's event is dispatched.
         * @return void
         */
        public function add_mouse_listener(listener_type:String, delegate:Function):void {
            // lets double check the stage is available just in case, and write a log if it isn't, for easy debugging.
            if (!stage) {
                DebugDaemon.write_log("the stage is not available, could not add mouse listener!", DebugDaemon.WARN);
            } else {
                // otherwise, make sure the provided listener name actually refers to an existing MouseEvent type, then add it.
                if (MouseEvent[listener_type]) {
                    stage.addEventListener(listener_type, delegate);
                }
            }
        }

        /**
         * adds a delegate to the internal keyboard listener that fires based on `key_event_trigger`.
         * @param delegate the function to be called when `key_event_trigger`'s associated event is dispatched.
         * @param key_event_trigger the keyboard event type to use as a trigger for `delegate`.
         * @return void
         */
        public function add_keyboard_delegate(delegate:Function, key_event_trigger:uint = 0):void {
            // if the stage is not available then there's nothing we can do
            if (!stage) {
                DebugDaemon.write_log("the stage is not available, could not add keyboard listener!", DebugDaemon.WARN);
            } else {
                // otherwise lets add listeners based on the trigger
                if (key_event_trigger == KEYDOWN) {
                    stage.addEventListener(KeyboardEvent.KEY_DOWN, delegate);
                } else if (key_event_trigger == KEYUP) {
                    stage.addEventListener(KeyboardEvent.KEY_UP, delegate);
                }
            }
        }

        /**
         * remove previously set delegates from the stage.
         * @param delegate the delegate to remove.
         */
        public function remove_keyboard_delegates(delegate:Function):void {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, delegate);
            stage.removeEventListener(KeyboardEvent.KEY_UP, delegate);
        }

        // * DELEGATE FUNCTIONS * //////////////////////////////////////////////////

        private function on_key_up(e:KeyboardEvent):void {
            _key_states[e.keyCode] = 0;
        }

        private function on_key_down(e:KeyboardEvent):void {
            _key_states[e.keyCode] = 1;
        }

        private function on_mouse_up(e:MouseEvent):void {
            _left_mouse_state = 0;
        }

        private function on_mouse_down(e:MouseEvent):void {
            _left_mouse_state = 1;
        }

        private function on_right_mouse_up(e:MouseEvent):void {
            _right_mouse_state = 0;
        }

        private function on_right_mouse_down(e:MouseEvent):void {
            _right_mouse_state = 1;
        }

        private function on_scroll_button_up(e:MouseEvent):void {
            _scroll_button_state = 0;
        }

        private function on_scroll_button_down(e:MouseEvent):void {
            _scroll_button_state = 1;
        }

        private function on_scroll_wheel_move(e:MouseEvent):void {
            _scroll_delta = e.delta;
            dispatchEvent(e);
        }

        /**
         * initializes the keyboard listeners on the main stage.
         * @param e event for listener
         */
        private function init_keyboard(e:Event = null):void {
            if (stage) {
                removeEventListener(Event.ADDED_TO_STAGE, init_keyboard);
                stage.addEventListener(KeyboardEvent.KEY_DOWN, on_key_down);
                stage.addEventListener(KeyboardEvent.KEY_UP, on_key_up);
            } else {
                addEventListener(Event.ADDED_TO_STAGE, this.init_keyboard);
            }

        }

        /**
         * initializes the mouse listeners on the main stage.
         * @param e event for listener
         */
        private function init_mouse(e:Event = null):void {
            if (stage) {
                stage.addEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down);
                stage.addEventListener(MouseEvent.MOUSE_UP, on_mouse_up);
                stage.addEventListener(MouseEvent.CLICK, on_mouse_up);
                stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, on_scroll_button_down);
                stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, on_scroll_button_up);
                stage.addEventListener(MouseEvent.MOUSE_WHEEL, on_scroll_wheel_move);
                stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, on_right_mouse_down);
                stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, on_right_mouse_up);
            } else {
                addEventListener(Event.ADDED_TO_STAGE, init_mouse);
            }
        }

        /**
         * initializes the gamepad listeners on the main stage.
         * @param e event for listener
         */
        private function init_gamepad(e:Event = null):void {
            if (stage) {
                if (!GamepadBus.is_initialized) {
                    GamepadBus.initialize(stage, init_gamepad);
                }
                while (GamepadBus.has_ready_controller()) {
                    _gamepads.push(GamepadBus.get_ready_controller());
                }
            } else {
                addEventListener(Event.ADDED_TO_STAGE, init_gamepad);
            }

        }

        // * GETTERS, SETTERS * ////////////////////////////////////////////////////

        public function get keys():KeyboardKeys {
            return _KEYS;
        }

        public function get left_mouse_down():Boolean {
            return _left_mouse_state == 1;
        }

        public function get right_mouse_down():Boolean {
            return _right_mouse_state == 1;
        }

        public function get scroll_button_down():Boolean {
            return _scroll_button_state == 1;
        }

        public function get scroll_delta():int {
            return _scroll_delta;
        }
    }
}

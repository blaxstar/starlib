package net.blaxstar.input {
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IEventDispatcher;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.utils.clearInterval;
  import flash.utils.setInterval;

  import net.blaxstar.input.gamepad.GamepadBus;
  import net.blaxstar.input.gamepad.types.Gamepad;
  import net.blaxstar.input.gamepad.types.GamepadType;
  import net.blaxstar.input.gamepad.types.OuyaGamepad;
  import net.blaxstar.input.gamepad.types.Xbox360Gamepad;
  import flash.display.Stage;
  import debug.DebugDaemon;

  /**
   * Enumerated type holding all the key code values and their names.
   * @author Deron Decamp	(decamp.deron@gmail.com)
   *
   */
  public class InputEngine extends Sprite {
    // const
    static public const KEYUP:uint = 0;
    static public const KEYDOWN:uint = 1;
    static private const KEYS:KeyboardKeys = new KeyboardKeys();

    // static
    static private var _keyStates:Vector.<uint> = new Vector.<uint>(250);
    static private var _gamepads:Vector.<Gamepad> = new Vector.<Gamepad>(4);
    static private var _pendingActions:Array;
    static private var _mouseState:uint;
    static private var _initNames:Boolean;
    static private var _initKeyboard:Boolean;
    static private var _initMouse:Boolean;
    static private var _initGamepad:Boolean;

    public function InputEngine(stage:Stage, initKeyboard:Boolean = false, initMouse:Boolean = false, initGamepad:Boolean = false) {
      super();
      if (!stage) {
        DebugDaemon.write_log("failed to instantiate InputEngine: stage is null, use init() first.", DebugDaemon.ERROR_IO);
      } else {
        stage.addChild(this);
      }
    }

    public function init(initKeyboard:Boolean = false, initMouse:Boolean = false, initGamepad:Boolean = false):void {
      if (!(initKeyboard == initMouse == initGamepad == false)) {
        return;
      }

      if (initKeyboard) {
        _initKeyboard = true;

        if (stage) {
          this.initKeyboard();
        }
        else {
          addEventListener(Event.ADDED_TO_STAGE, this.initKeyboard);
        }
      }

      if (initMouse) {
        _initMouse = true;

        if (stage) {
          this.initMouse();
        }
        else {
          addEventListener(Event.ADDED_TO_STAGE, this.initMouse);
        }
      }

      if (initGamepad) {
        _initGamepad = true;

        if (stage) {
          this.initGamepad();
        }
        else {
          addEventListener(Event.ADDED_TO_STAGE, this.initGamepad);
        }
      }
    }

    // public

    public function getController(playerID:uint):Gamepad {
      if (_initGamepad) {
        if (playerID > _gamepads.length) {
          throw "controller #" + playerID + " not detected!";
        }
        else {
          var gp:Gamepad = _gamepads[playerID];
          if (gp.type == GamepadType.OUYA) {
            return gp as OuyaGamepad;
          }
          else if (gp.type == GamepadType.XBOX) {
            return gp as Xbox360Gamepad;
          }
        }
      }
      else {
        trace("no gamepads found!");
        initGamepad();
      }
      return null;
    }

    public function getKeyName(key:Number):String {
      if (key <= 7 || !KEYS.NAMES[key])
        return "NONE";
      return KEYS.NAMES[key];
    }

    public function modIsDown():Boolean {
      return (keyIsDown(KEYS.CONTROL) || keyIsDown(KEYS.ALT));
    }

    public function keyIsDown(keyCode:uint):Boolean {
      if (!_initKeyboard) {
        initKeyboard();
        return false;
      }
      return _keyStates[keyCode] == 1;
    }

    public function addMouseListener(listenerType:String, delegate:Function):void {
      var interval:uint = 0;
      var intervalSet:uint = 0;

      if (!stage) {
        if (!hasEventListener(Event.ADDED_TO_STAGE)) {
          interval = setInterval(addMouseListener, 1000, listenerType, delegate);
          intervalSet = 1;
        }
      }
      else {
        if (intervalSet)
          clearInterval(interval);
        if (MouseEvent[listenerType]) {
          stage.addEventListener(listenerType, delegate);
        }
      }
    }

    public function addKeyboardDelegate(delegate:Function, keyEventTrigger:uint = 0):void {
      if (!stage) {
        _pendingActions = [delegate];
        addEventListener(Event.ADDED_TO_STAGE, addKbdDelegateInternal);
      }
      else {
        if (keyEventTrigger == KEYDOWN) {
          stage.addEventListener(KeyboardEvent.KEY_DOWN, delegate);
        }
        else if (keyEventTrigger == KEYUP) {
          stage.addEventListener(KeyboardEvent.KEY_UP, delegate);
        }
      }
    }

    public function removeKeyboardDelegates(delegate:Function):void {
      stage.removeEventListener(KeyboardEvent.KEY_DOWN, delegate);
      stage.removeEventListener(KeyboardEvent.KEY_UP, delegate);
    }

    private function addKbdDelegateInternal(e:Event):void {
      IEventDispatcher(e.currentTarget).removeEventListener(Event.ADDED_TO_STAGE, addKbdDelegateInternal);
      addKeyboardDelegate(_pendingActions[0]);
    }

    public function keys():KeyboardKeys {
      return KEYS;
    }

    // delegate functions

    private function onKeyUp(e:KeyboardEvent):void {
      _keyStates[e.keyCode] = 0;
    }

    private function onKeyDown(e:KeyboardEvent):void {
      _keyStates[e.keyCode] = 1;
    }

    private function onMouseUp(e:MouseEvent):void {
      _mouseState = 0;
    }

    private function onMouseDown(e:MouseEvent):void {
      _mouseState = 1;
    }

    private function onClick(e:MouseEvent):void {
      _mouseState = 0;
    }

    private function initKeyboard(e:Event = null):void {
      removeEventListener(Event.ADDED_TO_STAGE, initKeyboard);
      stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
      stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    }

    private function initMouse(e:Event = null):void {
      stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
      stage.addEventListener(MouseEvent.CLICK, onMouseDown);
    }

    private function initGamepad(e:Event = null):void {
      if (!GamepadBus.isInitialized) {
        GamepadBus.initialize(stage, initGamepad);
      }
      while (GamepadBus.hasReadyController()) {
        _gamepads.push(GamepadBus.getReadyController());
      }
    }

  }
}

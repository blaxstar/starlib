package net.blaxstar.starlib.debug.console {
  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.display.Stage;
  import flash.events.Event;
  import flash.events.FocusEvent;
  import flash.events.KeyboardEvent;
  import flash.filesystem.File;
  import flash.utils.Dictionary;

  import net.blaxstar.starlib.components.InputTextField;
  import net.blaxstar.starlib.components.PlainText;
  import net.blaxstar.starlib.debug.console.commands.ConsoleCommand;
  import net.blaxstar.starlib.input.InputEngine;
  import net.blaxstar.starlib.io.IOUtil;
  import net.blaxstar.starlib.style.Color;
  import net.blaxstar.starlib.utils.StringUtil;
  import net.blaxstar.starlib.io.XLoader;
  import net.blaxstar.starlib.io.URL;

  public class DebugConsole extends Sprite {
    static private var _data:Dictionary;
    private var _save_file:URL;
    private var _filePath:String;

    private var _input_engine:InputEngine;
    private var _input_field:InputTextField;
    private var _loader:XLoader;
    private var _outputField:PlainText;
    private var _prefixText:PlainText;
    private var _command_history_length:Number;
    private var _current_history_index:int;
    private var _tmpHistorySave:String;
    private var _isShowing:Boolean;
    private var _navigatingHistory:Boolean;

    // * CONSTRUCTOR * /////////////////////////////////////////////////////////
    public function DebugConsole(stage:Stage) {

      _filePath = File.applicationDirectory.nativePath;
      _save_file = new URL(new File(_filePath).resolvePath('console.dat').toString());
      _input_engine = new InputEngine(stage);
      _loader = new XLoader();

      _tmpHistorySave = "";
      _current_history_index = -1;
      _command_history_length = 0;
      _navigatingHistory = false;
      _isShowing = false;

      if (saveExists)
        loadSave();
      else
        create_save();

      _prefixText = new PlainText(this, 0, 0, 'debug | ');
      _prefixText.color = Color.PRODUCT_RED.value;
      _outputField = new PlainText(this, 0, 0);
      _outputField.color = Color.PRODUCT_GREEN.value;
      _input_field = new InputTextField(this, _prefixText.x + _prefixText.textWidth, 0, '');
      _input_field.color = Color.EGGSHELL.value;
      _input_field.showing_underline = false;

      _input_field.addEventListener(FocusEvent.FOCUS_OUT, onConsoleFocusOut);
      _input_field.addEventListener(Event.CHANGE, onTextFieldChange);

      hide_console();

      var addcom:ConsoleCommand = new ConsoleCommand('add', add);
      var subcom:ConsoleCommand = new ConsoleCommand('sub', subtract);
      var grepcom:ConsoleCommand = new ConsoleCommand('grep', grep);
      var clhscom:ConsoleCommand = new ConsoleCommand('clearhs', clear_history);
      addCommand(addcom);
      addCommand(subcom);
      addCommand(grepcom);
      addCommand(clhscom);

      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    // * PUBLIC * //////////////////////////////////////////////////////////

    public function addCommand(com:ConsoleCommand):void {
      commandDictionary[com.name] = com;
    }

    public function add_input_to_history(command:String):void {
      var trimmedCommand:String = StringUtil.trim(command);
      var commandIndex:int = command_history.indexOf(trimmedCommand);

      if (_navigatingHistory && _command_history_length) {
        command_history.removeAt(_current_history_index);
      }

      if (command_history.length > historyMax) {
        command_history.shift();
      }

      _data.command_history.push(trimmedCommand);
      _command_history_length = command_history.length;

      writeSave();
    }

    public function toggle_console():void {
      if (_isShowing) {
        hide_console();
      }
      else {
        show_console();
      }
    }

    public function show_console():void {
      if (!visible) {

        visible = true;
        stage.stageFocusRect = false;
        stage.focus = _input_field.input_target;

        _input_engine.add_keyboard_delegate(onKeyPressInConsole, InputEngine.KEYDOWN);
      }
    }
    public function hide_console():void {
      if (visible) {
        visible = false;
        _input_engine.remove_keyboard_delegates(onKeyPressInConsole);
        resetHistoryNavigation();
      }
    }

    public function clearConsole():void {
      _input_field.text = "";
    }

    public function loadSave():void {
      _loader.queue_files(_save_file);
      _loader.ON_COMPLETE.add(function ():void {
          _command_history_length = command_history.length;
          _data = _loader.get_loaded_data(_save_file.name) as Dictionary;
        });

    }
    public function writeSave():void {
      IOUtil.exportFile(_data, 'console', '.dat', _filePath, null);
    }

    public function clearSave():void {
      for (var key:String in _data) {
        delete _data[key];
      }
      create_save();
    }

    // * PRIVATE * /////////////////////////////////////////////////////////////

    private function create_save():void {

      _data ||= new Dictionary();
      _data.command_dictionary = new Dictionary();
      _data.command_history = [];

      historyMax = 100;
      openKey = _input_engine.keys.TILDE;
      execute_key = _input_engine.keys.ENTER;
      prevHistoryKey = _input_engine.keys.UP;
      nextHistoryKey = _input_engine.keys.DOWN;

      writeSave();
    }

    private function add(...args):Number {
      var sum:Number = 0;
      for (var i:uint = 0;i < args.length;i++) {
        var parsedNumber:Number = parseFloat(args[i]);
        if (isNaN(parsedNumber))
          continue;
        else
          sum = sum + parsedNumber;
      }
      return sum;
    }

    private function subtract(...args):Number {
      var diff:Number = args[0];

      for (var i:uint = 1;i < args.length;i++) {
        var parsedNumber:Number = parseFloat(args[i]);
        if (isNaN(parsedNumber))
          continue;
        else
          diff = diff - parsedNumber;
      }
      return diff;
    }

    private function grep(...args):String {
      var textInput:String = args.pop() as String;
      var pattern:String = args.pop() as String;
      var regex:RegExp = new RegExp(pattern);

      return regex.exec(textInput)[0];

    }

    private function clear_history():void {
      _current_history_index = -1;
      _command_history_length = 0;
      command_history = [];
      hide_console();
      writeSave();
    }

    private function print_to_console(...rest):void {
      var outString:String = "";
      if (rest[0] is Array) {
        rest = rest[0];
      }
      for (var i:uint = 0;i < rest.length;i++) {
        outString += rest[i];
      }
      _outputField.text = outString;
    }

    private function resetHistoryNavigation():void {
      _current_history_index = -1;
      _navigatingHistory = false;
      clearConsole();
      _tmpHistorySave = "";
    }

    // * GETTERS, SETTERS * ////////////////////////////////////////////////////

    public function get previousCommand():String {
      if (_current_history_index < 0) {
        _current_history_index = _command_history_length - 1;
        return current_command;
      }

      _current_history_index--;
      return current_command;
    }

    public function get nextCommand():String {
      if (_current_history_index >= _command_history_length - 1) {
        _current_history_index = -1;
        _navigatingHistory = false;
        return current_command;
      }

      _current_history_index++;
      return current_command;
    }

    public function get current_command():String {
      if (_current_history_index >= 0 && _current_history_index < _command_history_length) {
        return command_history[_current_history_index];
      }
      return _tmpHistorySave;
    }

    static public function get commandDictionary():Dictionary {
      return _data.command_dictionary as Dictionary;
    }

    static public function get command_history():Array {
      return _data.command_history;
    }

    static public function set command_history(val:Array):void {
      _data.command_history = val;
    }

    public function get historyMax():uint {
      return _data.history_max;
    }

    public function set historyMax(val:uint):void {
      _data.history_max = val;
    }

    public function get openKey():uint {
      return _data.open_key;
    }

    public function set openKey(val:uint):void {
      _data.open_key = val;
    }

    public function get execute_key():uint {
      return _data.execute_key;
    }

    public function set execute_key(val:uint):void {
      _data.execute_key = val;
    }

    public function get prevHistoryKey():uint {
      return _data.previous_history_key;
    }

    public function set prevHistoryKey(val:uint):void {
      _data.previous_history_key = val;
    }

    public function get nextHistoryKey():uint {
      return _data.next_history_key;
    }

    public function set nextHistoryKey(val:uint):void {
      _data.next_history_key = val;
    }
    public function get saveExists():Boolean {
      return _save_file.exists;
    }

    // DELEGATES ///////////////////////////////////////
    private function on_save_loaded(e:Event):void {}

    private function onKeyPressInConsole(e:KeyboardEvent):void {
      if (e.keyCode == execute_key) {
        if (_input_field.text.replace(" ", "") == "") {
          return;
        }

        add_input_to_history(_input_field.text.toLowerCase());

        var pipeline:Pipe = new Pipe();
        pipeline.parse_commands_from_string(_input_field.text.toLowerCase());
        print_to_console(pipeline.run());

        resetHistoryNavigation();
      }
      else if (e.keyCode == prevHistoryKey) {
        if (_current_history_index == 0) {
          print_to_console(_current_history_index);
          return;
        }
        _navigatingHistory = true;
        _input_field.text = previousCommand;
        print_to_console(_current_history_index);
      }
      else if (e.keyCode == nextHistoryKey) {
        if (_current_history_index == -1) {
          print_to_console(_current_history_index);
          _navigatingHistory = false;
          return;
        }
        _navigatingHistory = true;
        _input_field.text = nextCommand;
        print_to_console(_current_history_index);
      }
    }

    private function onAddedToStage(event:Event):void {

      var g:Graphics = this.graphics;

      g.beginFill(Color.DARK_GREY.value, 1);
      g.drawRect(0, 0, stage.stageWidth, 60);
      g.endFill();

      _input_field.width = _outputField.width = stage.stageWidth;
      _outputField.move(10, _input_field.height);

      _input_engine.add_keyboard_delegate(onToggleKeyPress, InputEngine.KEYDOWN);
    }

    private function onConsoleFocusOut(event:FocusEvent):void {
      hide_console();
    }

    private function onToggleKeyPress(e:KeyboardEvent):void {
      if (e.keyCode == openKey) {
        if (!visible)
          e.preventDefault();
        toggle_console();
      }
    }

    private function onTextFieldChange(e:Event):void {
      if (!_navigatingHistory) {
        _tmpHistorySave = _input_field.text;
      }
    }
  }
}

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

  public class DebugConsole extends Sprite {
    static private var _data:Dictionary;
    private var _saveFile:File;
    private var _filePath:String;

    private var _inputField:InputTextField;
    private var _outputField:PlainText;
    private var _prefixText:PlainText;
    private var _inputEngine:InputEngine;
    private var _commandHistoryLength:Number;
    private var _currentHistoryIndex:int;
    private var _tmpHistorySave:String;
    private var _isShowing:Boolean;
    private var _navigatingHistory:Boolean;

    public function DebugConsole(stage:Stage) {

      _filePath = File.applicationDirectory.nativePath;
      _saveFile = new File(_filePath).resolvePath('console.dat');
      _inputEngine = new InputEngine(stage);
      _isShowing = false;
      _currentHistoryIndex = -1;
      _commandHistoryLength = 0;
      _tmpHistorySave = "";
      _navigatingHistory = false;

      if (saveExists)
        loadSave();
      else
        createSave();

      _prefixText = new PlainText(this, 0, 0, 'debug | ');
      _prefixText.color = Color.PRODUCT_RED.value;
      _outputField = new PlainText(this, 0, 0);
      _outputField.color = Color.PRODUCT_GREEN.value;
      _inputField = new InputTextField(this, _prefixText.x + _prefixText.textWidth, 0, '');
      _inputField.color = Color.EGGSHELL.value;
      _inputField.showingUnderline = false;

      _inputField.addEventListener(FocusEvent.FOCUS_OUT, onConsoleFocusOut);
      _inputField.addEventListener(Event.CHANGE, onTextFieldChange);

      hideConsole();

      var addcom:ConsoleCommand = new ConsoleCommand('add', add);
      var subcom:ConsoleCommand = new ConsoleCommand('sub', subtract);
      var grepcom:ConsoleCommand = new ConsoleCommand('grep', grep);
      var clhscom:ConsoleCommand = new ConsoleCommand('clearhs', clearHistory);
      addCommand(addcom);
      addCommand(subcom);
      addCommand(grepcom);
      addCommand(clhscom);

      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    public function addCommand(com:ConsoleCommand):void {
      commandDictionary[com.name] = com;
    }

    public function addInputToHistory(command:String):void {
      var trimmedCommand:String = StringUtil.trim(command);
      var commandIndex:int = commandHistory.indexOf(trimmedCommand);

      if (_navigatingHistory && _commandHistoryLength) {
        commandHistory.removeAt(_currentHistoryIndex);
      }

      if (commandHistory.length > historyMax) {
        commandHistory.shift();
      }

      _data.commandHistory.push(trimmedCommand);
      _commandHistoryLength = commandHistory.length;

      writeSave();
    }

    public function toggleConsole():void {
      if (_isShowing) {
        hideConsole();
      }
      else {
        showConsole();
      }
    }

    public function showConsole():void {
      if (!visible) {

        visible = true;
        stage.stageFocusRect = false;
        stage.focus = _inputField.input;

        _inputEngine.addKeyboardDelegate(onKeyPressInConsole, InputEngine.KEYDOWN);
      }
    }
    public function hideConsole():void {
      if (visible) {
        visible = false;
        _inputEngine.removeKeyboardDelegates(onKeyPressInConsole);
        resetHistoryNavigation();
      }
    }

    public function clearConsole():void {
      _inputField.text = "";
    }

    public function loadSave():void {
      _data = IOUtil.loadFile(_saveFile, false).readObject() as Dictionary;
      _commandHistoryLength = commandHistory.length;

    }
    public function writeSave():void {
      IOUtil.exportFile(_data, 'console', '.dat', _filePath, null, true);
    }

    public function clearSave():void {
      for (var key:String in _data) {
        delete _data[key];
      }
      createSave();
    }

    // PRIVATE //////////////////////////////////////////////////

    private function createSave():void {

      _data ||= new Dictionary();
      _data.commandDictionary = new Dictionary();
      _data.commandHistory = [];

      historyMax = 100;
      openKey = InputEngine.KEYS.TILDE;
      executeKey = InputEngine.KEYS.ENTER;
      prevHistoryKey = InputEngine.KEYS.UP;
      nextHistoryKey = InputEngine.KEYS.DOWN;

      writeSave();
    }

    private function add(...args):Number {
      var sum:Number = 0;
      for (var i:uint = 0; i < args.length; i++) {
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

      for (var i:uint = 1; i < args.length; i++) {
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

    private function clearHistory():void {
      _currentHistoryIndex = -1;
      _commandHistoryLength = 0;
      commandHistory = [];
      hideConsole();
      writeSave();
    }

    private function printToConsole(...rest):void {
      var outString:String = "";
      if (rest[0] is Array) {
        rest = rest[0];
      }
      for (var i:uint = 0; i < rest.length; i++) {
        outString += rest[i];
      }
      _outputField.text = outString;
    }

    private function resetHistoryNavigation():void {
      _currentHistoryIndex = -1;
      _navigatingHistory = false;
      clearConsole();
      _tmpHistorySave = "";
    }

    // GETTERS, SETTERS ///////////////////////////////////////////

    public function get previousCommand():String {
      if (_currentHistoryIndex < 0) {
        _currentHistoryIndex = _commandHistoryLength - 1;
        return currentCommand;
      }

      _currentHistoryIndex--;
      return currentCommand;
    }

    public function get nextCommand():String {
      if (_currentHistoryIndex >= _commandHistoryLength - 1) {
        _currentHistoryIndex = -1;
        _navigatingHistory = false;
        return currentCommand;
      }

      _currentHistoryIndex++;
      return currentCommand;
    }

    public function get currentCommand():String {
      if (_currentHistoryIndex >= 0 && _currentHistoryIndex < _commandHistoryLength) {
        return commandHistory[_currentHistoryIndex];
      }
      return _tmpHistorySave;
    }

    static public function get commandDictionary():Dictionary {
      return _data.commandDictionary as Dictionary;
    }

    static public function get commandHistory():Array {
      return _data.commandHistory;
    }

    static public function set commandHistory(val:Array):void {
      _data.commandHistory = val;
    }

    public function get historyMax():uint {
      return _data.historyMax;
    }

    public function set historyMax(val:uint):void {
      _data.historyMax = val;
    }

    public function get openKey():uint {
      return _data.openKey;
    }

    public function set openKey(val:uint):void {
      _data.openKey = val;
    }

    public function get executeKey():uint {
      return _data.executeKey;
    }

    public function set executeKey(val:uint):void {
      _data.executeKey = val;
    }

    public function get prevHistoryKey():uint {
      return _data.prevHistoryKey;
    }

    public function set prevHistoryKey(val:uint):void {
      _data.prevHistoryKey = val;
    }

    public function get nextHistoryKey():uint {
      return _data.nextHistoryKey;
    }

    public function set nextHistoryKey(val:uint):void {
      _data.nextHistoryKey = val;
    }
    public function get saveExists():Boolean {
      return _saveFile.exists;
    }

    // DELEGATES ///////////////////////////////////////

    private function onKeyPressInConsole(e:KeyboardEvent):void {
      if (e.keyCode == executeKey) {
        if (_inputField.text.replace(" ", "") == "") {
          return;
        }

        addInputToHistory(_inputField.text.toLowerCase());

        var pipeline:Pipe = new Pipe();
        pipeline.parseCommandsFromString(_inputField.text.toLowerCase());
        printToConsole(pipeline.run());

        resetHistoryNavigation();
      }
      else if (e.keyCode == prevHistoryKey) {
        if (_currentHistoryIndex == 0) {
          printToConsole(_currentHistoryIndex);
          return;
        }
        _navigatingHistory = true;
        _inputField.text = previousCommand;
        printToConsole(_currentHistoryIndex);
      }
      else if (e.keyCode == nextHistoryKey) {
        if (_currentHistoryIndex == -1) {
          printToConsole(_currentHistoryIndex);
          _navigatingHistory = false;
          return;
        }
        _navigatingHistory = true;
        _inputField.text = nextCommand;
        printToConsole(_currentHistoryIndex);
      }
    }

    private function onAddedToStage(event:Event):void {

      var g:Graphics = this.graphics;

      g.beginFill(Color.DARK_GREY.value, 1);
      g.drawRect(0, 0, stage.stageWidth, 60);
      g.endFill();

      _inputField.width = _outputField.width = stage.stageWidth;
      _outputField.move(10, _inputField.height);

      _inputEngine.addKeyboardDelegate(onToggleKeyPress, InputEngine.KEYDOWN);
    }

    private function onConsoleFocusOut(event:FocusEvent):void {
      hideConsole();
    }

    private function onToggleKeyPress(e:KeyboardEvent):void {
      if (e.keyCode == openKey) {
        if (!visible)
          e.preventDefault();
        toggleConsole();
      }
    }

    private function onTextFieldChange(e:Event):void {
      if (!_navigatingHistory) {
        _tmpHistorySave = _inputField.text;
      }
    }
  }
}
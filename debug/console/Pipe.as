package net.blaxstar.debug.console {
  import flash.utils.Dictionary;
  import net.blaxstar.debug.console.commands.ConsoleCommand;

  /**
   * ...
   * @author SnaiLegacy (Psycho)
   */
  public class Pipe extends Object {
    static private const COMMAND:RegExp = /(^[ ]*[a-zA-Z.0-9]+)/;
    static private const SWITCHES:RegExp = /([-0-9+.]+[0-9+])|([+0-9+])|(-[a-zA-Z]+)|(\|[a-zA-Z]+)|(\|\s[a-zA-Z]+)/g;
    static private const PIPES:RegExp = /\|/g;
    static private const cmdLookup:Dictionary = DebugConsole.commandDictionary;

    private var _commands:Array;
    private var _commandObjects:Vector.<ConsoleCommand>;
    private var _result:*;

    public function parseCommandsFromString(pipelineString:String):void {
      _commands = pipelineString.split(PIPES);
      _commandObjects = new Vector.<ConsoleCommand>();

      for (var i:int = 0; i < _commands.length; i++) {
        var currPipeline:String = _commands[i];
        var cmd:String = currPipeline.match(COMMAND)[0].replace(" ", "");
        var args:Array = currPipeline.match(SWITCHES);

        var currentCommand:ConsoleCommand = cmdLookup[cmd];

        if (currentCommand != null) {
          _commandObjects.push(currentCommand);
          currentCommand.setArgs(args);
        }
        else {
          trace("Invalid command: " + cmd);
        }
      }

    }

    public function run():* {
      if (!_commandObjects) return;
      if (_commandObjects.length > 1) {
        for (var i:uint = 1; i < _commandObjects.length; i++) {
          _result = connect(_commandObjects[i - 1], _commandObjects[i]);
        }
        return _result;
      } else if (_commandObjects.length > 0) {
        return _commandObjects[0].execute();
      }
    }

    static private function connect(prevCommand:ConsoleCommand, nextCommand:ConsoleCommand):* {
      var prevFunc:Function = prevCommand.func;
      var nextFunc:Function = nextCommand.func;
      var com1out:* = prevFunc.apply(null, prevCommand.argArray);
      var allArgs:Array = [];

      allArgs = nextCommand.argArray;
      allArgs.push(com1out);

      return nextFunc.apply(null, allArgs);
    }

    public function get result():* {
      return (result == undefined || result == null) ? run() : _result;
    }
  }

}
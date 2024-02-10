package net.blaxstar.starlib.debug.console {
  import flash.utils.Dictionary;
  import net.blaxstar.starlib.debug.console.commands.ConsoleCommand;

  /**
   * ...
   * @author SnaiLegacy (Psycho)
   */
  public class Pipe extends Object {
    static private const COMMAND:RegExp = /(^[ ]*[a-zA-Z.0-9]+)/;
    static private const SWITCHES:RegExp = /([-0-9+.]+[0-9+])|([+0-9+])|(-[a-zA-Z]+)|(\|[a-zA-Z]+)|(\|\s[a-zA-Z]+)/g;
    static private const PIPES:RegExp = /\|/g;

    private var _commands:Array;
    private var _command_objects:Vector.<ConsoleCommand>;
    private var _result:*;
    private var _command_dictionary:Dictionary;

    public function Pipe(dictionary:Dictionary) {
      _command_dictionary = dictionary;
    }

    public function parse_commands_from_string(pipelineString:String):void {
      _commands = pipelineString.split(PIPES);
      _command_objects = new Vector.<ConsoleCommand>();

      for (var i:int = 0; i < _commands.length; i++) {
        var current_pipeline:String = _commands[i];
        var cmd:String = current_pipeline.match(COMMAND)[0].replace(" ", "");
        var args:Array = current_pipeline.match(SWITCHES);

        var current_command:ConsoleCommand = _command_dictionary[cmd];

        if (current_command != null) {
          _command_objects.push(current_command);
          
          if (current_command.argument_array.length) {
            if (args.length) {
              current_command.push_args(args);
            }
          } else {
            if (args.length) {
              current_command.set_args(args);
            }
          }
        }
        else {
          trace("Invalid command: " + cmd);
        }
      }

    }

    public function run():* {
      if (!_command_objects) return;
      if (_command_objects.length > 1) {
        for (var i:uint = 1; i < _command_objects.length; i++) {
          _result = connect(_command_objects[i - 1], _command_objects[i]);
        }
        return _result;
      } else if (_command_objects.length > 0) {
        return _command_objects[0].execute();
      }
    }

    static private function connect(prevCommand:ConsoleCommand, nextCommand:ConsoleCommand):* {
      var prevFunc:Function = prevCommand.func;
      var nextFunc:Function = nextCommand.func;
      var com1out:* = prevFunc.apply(null, prevCommand.argument_array);
      var allArgs:Array = [];

      allArgs = nextCommand.argument_array;
      allArgs.push(com1out);

      return nextFunc.apply(null, allArgs);
    }

    public function get result():* {
      return (result == undefined || result == null) ? run() : _result;
    }
  }

}

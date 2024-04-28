package net.blaxstar.starlib.debug.terminal.commands {


  public class TerminalCommand {
    protected var _name:String;
    protected var _delegateFunction:Function;
    protected var _args:Array;

    public function TerminalCommand(name:String="", func:Function=null, ...args) {
      if (name != "") {
        _name = name;
      }
      if (func) {
        _delegateFunction = func;
      }

      set_args(args);
    }

    public function execute():* {
      var output:*;

      try {
        output = _delegateFunction.apply(null, argument_array);
        _args.length = 0;
      }
      catch (e:Error) {
        // if there's an argument count mismatch,
        // get the number of args required from the error message, and run the function again. otherwise just return the error as a string
        if (argument_array.length == 0) {
          return "no input";
        } else if (e.errorID == 1063) {
          catch1063(e);
        } else {
          output = String("error " + e.errorID + ": " + e.message);
        }
        
      } 
      return output;
    }

    public function set_args(args:Array):void {
      _args = args;
    }

    public function push_args(...rest):void {
      for (var i:uint = 0; i < rest.length; i++) {
        if (rest[i] is Array) {
          rest[i].forEach(function(item:String, index:int, array:Array):void {
            push_args(item);
          });
        } else {
          _args.push(rest[i]);
        }
      }
    }

    // catch argument count mismatch error
    protected function catch1063(e:Error):void {
      if (e.errorID == 1063) {
          var expected:uint = parseInt(e.message.slice(e.message.indexOf("Expected ") + 9, e.message.lastIndexOf(",")));
          var lessArgs:Array = argument_array.slice(0, expected);
          _delegateFunction.apply(this, lessArgs);
        }
    }

    public function get name():String {
      return _name;
    }

    public function set name(val:String):void {
      _name = val;
    }

    public function get func():Function {
      return _delegateFunction;
    }

    public function set func(val:Function):void {
      _delegateFunction = val;
    }

    public function get argument_array():Array {
      return _args;
    }
  }
}
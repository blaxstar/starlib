package net.blaxstar.debug.console.commands {
  public class ConsoleCommand {
    protected var _name:String;
    protected var _delegateFunction:Function;
    protected var _args:Array;

    public function ConsoleCommand(name:String, func:Function, ...args) {
      _name = name;
      _delegateFunction = func;
      _args = [];
      setArgs(args);

    }

    public function execute():* {
      var output:*;

      try {
        output = _delegateFunction.apply(null, argArray);
      }
      catch (e:ArgumentError) {
        // if there's an argument count mismatch,
        // get the number of args required from the error message, and run the function again
        catch1063(e);
        
      }
      return output;
    }

    public function setArgs(args:Array):void {
      _args.length = 0;
      _args = args;
    }

    protected function catch1063(e:Error):void {
      if (e.errorID == 1063) {
          var expected:uint = parseInt(e.message.slice(e.message.indexOf("Expected ") + 9, e.message.lastIndexOf(",")));
          var lessArgs:Array = argArray.slice(0, expected);
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

    public function get argArray():Array {
      return _args;
    }
  }
}
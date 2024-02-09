package net.blaxstar.starlib.debug.console.commands
{
  public class ArithmeticSubCommand extends ConsoleCommand {
    
    public function ArithmeticSubCommand() {
      super();
      _name = "sub";
      _delegateFunction = subtract;
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
  }
}
package net.blaxstar.starlib.debug.terminal.commands
{
  public class ArithmeticSubCommand extends TerminalCommand {
    
    public function ArithmeticSubCommand() {
      super("sub", subtract);
    }

    private function subtract(...args):Number {
      var diff:Number = parseFloat(args[0]);

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
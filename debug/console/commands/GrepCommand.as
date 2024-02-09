package net.blaxstar.starlib.debug.console.commands
{
  public class GrepCommand extends ConsoleCommand {
    
    public function GrepCommand() {
      super();
      _name = "grep";
      _delegateFunction = grep;
    }

    private function grep(...args):String {
      var textInput:String = args.pop() as String;
      var pattern:String = args.pop() as String;
      var regex:RegExp = new RegExp(pattern);

      return regex.exec(textInput)[0];
    }
  }
}
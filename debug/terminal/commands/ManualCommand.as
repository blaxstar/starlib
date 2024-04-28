package net.blaxstar.starlib.debug.terminal.commands
{
  import flash.utils.Dictionary;
  import net.blaxstar.starlib.debug.printf;
  import thirdparty.org.osflash.signals.Signal;
  import net.blaxstar.starlib.utils.Strings;

  public class ManualCommand extends TerminalCommand {
    static private var _manual_dictionary:Dictionary;
    static public var on_access:Signal = new Signal();

    public function ManualCommand() {
      _manual_dictionary = new Dictionary();
      super("man", man);
    }

    private function man(command_name:String):String {
      var manual_string:String;
      command_name = Strings.trim(command_name);
      if (_manual_dictionary.hasOwnProperty(command_name)) {
        manual_string = String(_manual_dictionary[command_name] + "\n\npress the toggle key or type any other non-man command to revert back to normal size.");
      } else {
        manual_string = printf("no manpage found for '%s' command.", command_name);
      }
      on_access.dispatch();
      return manual_string;
    }

    static public function register_manual(command_name:String, command_manual:String):void {
        _manual_dictionary[command_name] = command_manual;
    }
  }
}
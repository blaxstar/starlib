package net.blaxstar.starlib.debug.terminal.commands {

    import net.blaxstar.starlib.Starlib;
    import net.blaxstar.starlib.utils.Strings;

    public class PrintCommand extends TerminalCommand {

        public function PrintCommand() {
            super("print", print);
        }

        private function print(... args):String {
            var full_string:String = "";

            for each(var string:String in args) {
              if (Strings.trim(string) === "-v") {
                return Starlib.VERSION_STRING;
              }
              full_string = full_string.concat(string);
            }

            
            return full_string;
        }
    }
}

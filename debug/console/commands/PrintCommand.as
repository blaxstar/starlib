package net.blaxstar.starlib.debug.console.commands {

    public class PrintCommand extends ConsoleCommand {

        public function PrintCommand() {
            super("print", print);
        }

        private function print(... args):String {
            var full_string:String = "";

            for (var i:uint = 0; i < args.length; i++) {
                full_string = full_string.concat(args[i] + " ");
            }

            return full_string;
        }
    }
}
